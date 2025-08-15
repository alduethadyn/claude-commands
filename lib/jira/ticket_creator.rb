#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'base64'
require_relative 'markdown_formatter'
require_relative 'markdown_template_parser'
require_relative 'adf_validator'

module Jira
  # Class to create JIRA tickets (story or task) from markdown templates
  class TicketCreator
    def initialize
      @access_token = ENV.fetch('JIRA_ACCESS_TOKEN', nil)
      @jira_email = ENV['JIRA_EMAIL'] || 'abeckwith@zendesk.com'
      @jira_base_url = 'https://zendesk.atlassian.net'

      raise ArgumentError, 'JIRA_ACCESS_TOKEN environment variable is not set' if @access_token.nil? || @access_token.empty?

      return unless @jira_email.nil? || @jira_email.empty?

      raise ArgumentError, 'JIRA_EMAIL environment variable is not set'
    end

    def create_ticket(issue_type, template_file)
      raise ArgumentError, "Template file '#{template_file}' not found" unless File.exist?(template_file)

      template_content = File.read(template_file)
      ticket_data = build_ticket_data_from_template(template_content, issue_type)

      uri = URI("#{@jira_base_url}/rest/api/3/issue")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      credentials = Base64.strict_encode64("#{@jira_email}:#{@access_token}")
      request['Authorization'] = "Basic #{credentials}"
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'
      request.body = ticket_data.to_json

      begin
        response = http.request(request)

        case response.code
        when '201'
          ticket_response = JSON.parse(response.body)
          success_response(ticket_response)
        when '400'
          error_response = JSON.parse(response.body)
          # Check if it's a components permission error and retry without components
          if error_response['errors'] && error_response['errors']['components']&.include?('permission')
            puts 'Warning: No permission to set components. Retrying without components...'
            # Remove components and retry
            ticket_data[:fields].delete(:components)

            retry_request = Net::HTTP::Post.new(uri)
            retry_request['Authorization'] = "Basic #{credentials}"
            retry_request['Accept'] = 'application/json'
            retry_request['Content-Type'] = 'application/json'
            retry_request.body = ticket_data.to_json

            retry_response = http.request(retry_request)
            if retry_response.code == '201'
              ticket_response = JSON.parse(retry_response.body)
              return success_response(ticket_response)
            end
          end

          raise StandardError, "Bad request: #{JSON.pretty_generate(error_response)}"
        when '401'
          raise StandardError, 'Authentication failed. Please check your JIRA_ACCESS_TOKEN'
        when '403'
          raise StandardError, 'Permission denied. You may not have permission to create tickets in this project'
        else
          raise StandardError, "HTTP #{response.code} - #{response.message}\n#{response.body}"
        end
      rescue StandardError => e
        raise StandardError, "Error creating ticket: #{e.message}"
      end
    end

    private

    def build_ticket_data_from_template(content, issue_type)
      # Use the common parser to extract template information
      parsed = Jira::MarkdownTemplateParser.parse_template(content, issue_type)

      # Build full description with all sections
      full_description = Jira::MarkdownTemplateParser.build_full_description(
        parsed[:description_section],
        parsed[:references_section],
        parsed[:acceptance_criteria_section]
      )

      # Convert markdown description to ADF (Atlassian Document Format)
      description_adf = Jira::MarkdownFormatter.convert_with_fallback(full_description)

      # Validate ADF before creating ticket
      validation_result = Jira::ADFValidator.validate_with_details(description_adf)
      unless validation_result[:valid]
        puts 'Warning: Generated ADF may have validation issues:'
        validation_result[:errors].each { |error| puts "  - #{error}" }
        puts 'Proceeding with ticket creation anyway...'
      end

      # Build the ticket data structure
      ticket_data = {
        fields: {
          project: {
            key: parsed[:project_key]
          },
          summary: parsed[:title],
          description: description_adf,
          issuetype: {
            name: issue_type.capitalize
          },
          priority: {
            name: parsed[:priority]
          }
        }
      }

      # Add optional fields if provided
      ticket_data[:fields][:labels] = parsed[:labels] unless parsed[:labels].empty?

      # Only add components if not empty and not using placeholder values
      unless parsed[:components].empty? || parsed[:components].join(',').include?('component1')
        ticket_data[:fields][:components] = parsed[:components].map { |comp| { name: comp } }
      end

      ticket_data[:fields][:assignee] = { emailAddress: parsed[:assignee] } if parsed[:assignee] && !parsed[:assignee].empty?

      # Add parent issue if specified
      ticket_data[:fields][:parent] = { key: parsed[:parent_issue] } if parsed[:parent_issue] && !parsed[:parent_issue].empty?

      ticket_data
    end

    def success_response(ticket_response)
      {
        success: true,
        ticket_key: ticket_response['key'],
        ticket_id: ticket_response['id'],
        url: "#{@jira_base_url}/browse/#{ticket_response['key']}"
      }
    end
  end
end
