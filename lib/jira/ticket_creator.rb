#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'
require 'base64'
require_relative 'markdown_formatter'

module Jira
  # Class to create JIRA tickets (story or task) from markdown templates
  class TicketCreator
    def initialize
      @access_token = ENV['JIRA_ACCESS_TOKEN']
      @jira_email = ENV['JIRA_EMAIL'] || 'abeckwith@zendesk.com'
      @jira_base_url = 'https://zendesk.atlassian.net'

      if @access_token.nil? || @access_token.empty?
        raise ArgumentError, 'JIRA_ACCESS_TOKEN environment variable is not set'
      end

      if @jira_email.nil? || @jira_email.empty?
        raise ArgumentError, 'JIRA_EMAIL environment variable is not set'
      end
    end

    def create_ticket(issue_type, template_file)
      unless File.exist?(template_file)
        raise ArgumentError, "Template file '#{template_file}' not found"
      end

      template_content = File.read(template_file)
      ticket_data = parse_template(template_content, issue_type)

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
          return success_response(ticket_response)
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

    def parse_template(content, issue_type)
      # Parse markdown template and extract ticket information
      lines = content.split("\n")

      title = ""
      project_key = "EM" # Default project, can be overridden in template
      priority = "Medium"
      labels = []
      components = []
      assignee = nil
      parent_issue = nil

      # Sections for structured content
      description_section = []
      background_section = []
      solution_section = []
      references_section = []
      acceptance_criteria_section = []

      current_section = nil
      in_metadata = true

      lines.each do |line|
        original_line = line
        line = line.strip

        # Extract title from first # or ## header
        if (line.start_with?('# ') || line.start_with?('## ')) && title.empty?
          title = line.gsub(/^(\#{1,2})\s*/, '').strip
          next
        end

        # Handle metadata fields (before first ## section or in ### Project Information)
        if in_metadata || current_section == 'project information'
          if line.start_with?('**Project:**')
            value = extract_metadata_value(line)
            project_key = value unless value.nil? || value.include?('PROJECT_KEY')
          elsif line.start_with?('**Priority:**')
            value = extract_metadata_value(line)
            priority = value unless value.nil? || value.include?('|')
          elsif line.start_with?('**Labels:**')
            value = extract_metadata_value(line)
            if value && !value.include?('label1')
              labels = value.split(',').map(&:strip)
            end
          elsif line.start_with?('**Components:**')
            value = extract_metadata_value(line)
            if value && !value.include?('component1')
              components = value.split(',').map(&:strip)
            end
          elsif line.start_with?('**Assignee:**')
            value = extract_metadata_value(line)
            if value && !value.include?('user@example.com') && !value.include?('ENV[') && !value.include?('Unassigned')
              assignee = value
            else
              assignee = nil # Default to Unassigned
            end
          elsif line.start_with?('**Parent:**')
            value = extract_metadata_value(line)
            if value && !value.empty? && !value.include?('PARENT-KEY')
              parent_issue = value
            end
          elsif line.start_with?('## ')
            in_metadata = false
            current_section = line[3..-1].strip.downcase
          elsif line.start_with?('### ')
            current_section = line[4..-1].strip.downcase
          end
        else
          # Handle content sections
          if line.start_with?('## ')
            current_section = line[3..-1].strip.downcase
          elsif line.start_with?('### ')
            # Keep subsection headers in the content
            case current_section
            when 'description'
              description_section << original_line
            when 'references and notes'
              references_section << original_line
            when 'acceptance criteria'
              acceptance_criteria_section << original_line
            end
          else
            # Add content to appropriate section
            case current_section
            when 'description'
              description_section << original_line
            when 'references and notes'
              references_section << original_line
            when 'acceptance criteria'
              acceptance_criteria_section << original_line
            end
          end
        end
      end

      # Build full description with all sections
      full_description = build_full_description(description_section, references_section, acceptance_criteria_section)

      # Convert markdown description to ADF (Atlassian Document Format)
      description_adf = Jira::MarkdownFormatter.convert_with_fallback(full_description)

      # Build the ticket data structure
      ticket_data = {
        fields: {
          project: {
            key: project_key
          },
          summary: title,
          description: description_adf,
          issuetype: {
            name: issue_type.capitalize
          },
          priority: {
            name: priority
          }
        }
      }

      # Add optional fields if provided
      unless labels.empty?
        ticket_data[:fields][:labels] = labels
      end

      # Only add components if not empty and not using placeholder values
      unless components.empty? || components.join(',').include?('component1')
        ticket_data[:fields][:components] = components.map { |comp| { name: comp } }
      end

      if assignee && !assignee.empty?
        ticket_data[:fields][:assignee] = { emailAddress: assignee }
      end

      # Add parent issue if specified
      if parent_issue && !parent_issue.empty?
        ticket_data[:fields][:parent] = { key: parent_issue }
      end

      ticket_data
    end

    def extract_metadata_value(line)
      return nil unless line.include?(':')

      value = line.split(':', 2)[1].strip
      return nil if value.empty?

      # Remove markdown formatting
      value = value.gsub(/^\*\*\s*/, '').gsub(/\s*\*\*$/, '')

      value
    end

    def build_full_description(description_section, references_section, acceptance_criteria_section)
      sections = []

      unless description_section.empty?
        sections << description_section.join("\n")
      end

      unless references_section.empty?
        sections << "## References and Notes\n\n" + references_section.join("\n")
      end

      unless acceptance_criteria_section.empty?
        sections << "## Acceptance Criteria\n\n" + acceptance_criteria_section.join("\n")
      end

      sections.join("\n\n")
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