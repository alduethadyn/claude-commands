#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'base64'

module Jira
  # Class to fetch JIRA ticket information
  class TicketFetcher
    def initialize
      @access_token = ENV.fetch('JIRA_ACCESS_TOKEN', nil)
      @jira_email = 'abeckwith@zendesk.com'
      @jira_base_url = 'https://zendesk.atlassian.net'

      raise ArgumentError, 'JIRA_ACCESS_TOKEN environment variable is not set' if @access_token.nil? || @access_token.empty?

      return unless @jira_email.nil? || @jira_email.empty?

      raise ArgumentError, 'JIRA_EMAIL environment variable is not set'
    end

    def fetch_ticket(ticket_key)
      ticket_key = ticket_key.upcase

      uri = URI("#{@jira_base_url}/rest/api/3/issue/#{ticket_key}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      credentials = Base64.strict_encode64("#{@jira_email}:#{@access_token}")
      request['Authorization'] = "Basic #{credentials}"
      request['Accept'] = 'application/json'

      begin
        response = http.request(request)

        case response.code
        when '200'
          ticket_data = JSON.parse(response.body)
          parse_ticket_info(ticket_data)
        when '401'
          raise StandardError, 'Authentication failed. Please check your JIRA_ACCESS_TOKEN'
        when '403'
          raise StandardError, 'Permission denied. You may not have permission to view this ticket'
        when '404'
          raise StandardError, "Ticket #{ticket_key} not found"
        else
          raise StandardError, "HTTP #{response.code} - #{response.message}\n#{response.body}"
        end
      rescue StandardError => e
        raise StandardError, "Error fetching ticket: #{e.message}"
      end
    end

    private

    def parse_ticket_info(ticket_data)
      fields = ticket_data['fields']

      # Extract basic information
      ticket_info = {
        key: ticket_data['key'],
        id: ticket_data['id'],
        url: "#{@jira_base_url}/browse/#{ticket_data['key']}",
        summary: fields['summary'],
        description: extract_description_text(fields['description']),
        status: fields['status']['name'],
        issue_type: fields['issuetype']['name'],
        priority: fields['priority']['name'],
        project: fields['project']['key'],
        assignee: extract_assignee(fields['assignee']),
        reporter: extract_assignee(fields['reporter']),
        created: fields['created'],
        updated: fields['updated']
      }

      # Add labels if present
      ticket_info[:labels] = fields['labels'] if fields['labels'] && !fields['labels'].empty?

      # Add components if present
      if fields['components'] && !fields['components'].empty?
        ticket_info[:components] = fields['components'].map { |comp| comp['name'] }
      end

      # Add parent if present (for subtasks)
      if fields['parent']
        ticket_info[:parent] = {
          key: fields['parent']['key'],
          summary: fields['parent']['fields']['summary']
        }
      end

      ticket_info
    end

    def extract_description_text(description_adf)
      return '' unless description_adf && description_adf['content']

      # Simple ADF to text conversion - extracts text content
      text_parts = []
      extract_text_from_adf(description_adf['content'], text_parts)
      text_parts.join(' ').strip
    end

    def extract_text_from_adf(content, text_parts)
      return unless content.is_a?(Array)

      content.each do |node|
        case node['type']
        when 'text'
          text_parts << node['text']
        when 'paragraph', 'heading', 'listItem', 'bulletList', 'orderedList'
          extract_text_from_adf(node['content'], text_parts) if node['content']
        end
      end
    end

    def extract_assignee(assignee_data)
      return nil unless assignee_data

      {
        account_id: assignee_data['accountId'],
        display_name: assignee_data['displayName'],
        email: assignee_data['emailAddress']
      }
    end
  end
end
