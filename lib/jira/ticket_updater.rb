#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'
require 'base64'
require_relative 'markdown_formatter'

module Jira
  # Class to update JIRA ticket status, assignee, and other fields
  class TicketUpdater
    def initialize
      @access_token = ENV['JIRA_ACCESS_TOKEN']
      @jira_email = ENV['JIRA_EMAIL'] || 'abeckwith@zendesk.com'
      @jira_base_url = 'https://zendesk.atlassian.net'

      if @access_token.nil? || @access_token.empty?
        raise ArgumentError, 'JIRA_ACCESS_TOKEN environment variable is not set'
      end

      # @jira_email now has a fallback, so no need to exit if ENV var is not set
      puts "Using JIRA email: #{@jira_email}" if ENV['DEBUG']
    end

    def update_ticket(ticket_key, options = {})
      ticket_key = ticket_key.upcase

      # Build the update payload
      update_fields = {}

      # Handle assignee update
      if options[:assignee]
        if options[:assignee].downcase == 'me' || options[:assignee] == @jira_email
          # Get my account ID for assignment
          my_account_id = get_my_account_id
          update_fields[:assignee] = { accountId: my_account_id } if my_account_id
        else
          # For other users, try to get their account ID by email
          account_id = get_account_id_by_email(options[:assignee])
          update_fields[:assignee] = { accountId: account_id } if account_id
        end
      end

      # Handle description update from markdown file
      if options[:description_file]
        unless File.exist?(options[:description_file])
          raise ArgumentError, "Description file '#{options[:description_file]}' not found"
        end
        
        markdown_content = File.read(options[:description_file])
        description_adf = Jira::MarkdownFormatter.convert_with_fallback(markdown_content)
        update_fields[:description] = description_adf
      end

      # Handle sprint assignment
      if options[:sprint]
        if options[:sprint].downcase == 'current'
          sprint_id = get_current_active_sprint
          if sprint_id
            # Sprint field for this Jira instance
            update_fields[:customfield_10009] = sprint_id
          else
            puts "Warning: No active sprint found"
          end
        else
          update_fields[:customfield_10009] = options[:sprint].to_i
        end
      end

      # Handle status transition
      transition_id = nil
      if options[:status]
        transition_id = get_transition_id(ticket_key, options[:status])
        unless transition_id
          raise StandardError, "Unable to transition to status '#{options[:status]}'"
        end
      end

      # Update fields if any
      unless update_fields.empty?
        update_ticket_fields(ticket_key, update_fields)
      end

      # Transition status if specified
      if transition_id
        transition_ticket(ticket_key, transition_id)
      end

      {
        success: true,
        message: "Ticket #{ticket_key} updated successfully!",
        url: "#{@jira_base_url}/browse/#{ticket_key}"
      }
    end

    def mark_ready_for_review(ticket_key, assignee = nil)
      assignee ||= @jira_email

      options = {
        assignee: assignee,
        status: 'Ready for Review'
      }

      puts "Marking #{ticket_key} as Ready for Review and assigning to #{assignee}..."
      update_ticket(ticket_key, options)
    end

    private

    def get_current_active_sprint
      # Get the board ID for the project using hardcoded mapping
      board_info = get_board_info_for_project('EM')
      return nil unless board_info
      
      board_id = board_info[:id]
      board_type = board_info[:type]
      
      # Kanban boards don't support sprints
      if board_type == 'kanban'
        puts "Warning: Project uses Kanban board which doesn't support sprints"
        return nil
      end

      uri = URI("#{@jira_base_url}/rest/agile/1.0/board/#{board_id}/sprint?state=active")

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
          sprints_data = JSON.parse(response.body)
          active_sprints = sprints_data['values'].select { |sprint| sprint['state'] == 'active' }

          if active_sprints.any?
            return active_sprints.first['id']
          else
            puts "No active sprint found for board #{board_id}"
            return nil
          end
        else
          puts "Error getting active sprint: HTTP #{response.code}"
          return nil
        end
      rescue StandardError => e
        puts "Error getting active sprint: #{e.message}"
        return nil
      end
    end

    def get_my_account_id
      # Hardcode my account ID for performance, or fetch it dynamically
      return '557058:07381840-3d1a-4550-9471-c35b6b77ab9d' if @jira_email == 'abeckwith@zendesk.com'
      
      # Fallback to API call
      uri = URI("#{@jira_base_url}/rest/api/3/myself")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri)
      credentials = Base64.strict_encode64("#{@jira_email}:#{@access_token}")
      request['Authorization'] = "Basic #{credentials}"
      request['Accept'] = 'application/json'
      
      begin
        response = http.request(request)
        if response.code == '200'
          user_data = JSON.parse(response.body)
          return user_data['accountId']
        else
          puts "Error getting account ID: HTTP #{response.code}"
          return nil
        end
      rescue StandardError => e
        puts "Error getting account ID: #{e.message}"
        return nil
      end
    end

    def get_account_id_by_email(email)
      # This could be implemented to search for users by email
      # For now, return nil to indicate we can't find the account ID
      puts "Warning: Cannot resolve account ID for email #{email}. Use accountId directly instead."
      return nil
    end

    def get_board_info_for_project(project_key)
      # Hardcoded board mappings for known projects
      board_mappings = {
        'EM' => { id: 3170, name: 'Email Processing', type: 'scrum' }
        # Add more project mappings as needed
      }
      
      if board_mappings.key?(project_key)
        return board_mappings[project_key]
      end
      
      # Fallback to API discovery if not in hardcoded mappings
      return get_board_for_project_with_type(project_key)
    end

    def get_board_for_project_with_type(project_key)
      # This method returns both board ID and type via API discovery
      uri = URI("#{@jira_base_url}/rest/agile/1.0/board?projectKeyOrId=#{project_key}")

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
          boards_data = JSON.parse(response.body)
          if boards_data['values'].any?
            first_board = boards_data['values'].first
            return {
              id: first_board['id'],
              type: first_board['type']
            }
          else
            puts "No boards found for project #{project_key}"
            return nil
          end
        else
          puts "Error getting board for project: HTTP #{response.code}"
          return nil
        end
      rescue StandardError => e
        puts "Error getting board for project: #{e.message}"
        return nil
      end
    end

    def update_ticket_fields(ticket_key, fields)
      uri = URI("#{@jira_base_url}/rest/api/3/issue/#{ticket_key}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Put.new(uri)
      credentials = Base64.strict_encode64("#{@jira_email}:#{@access_token}")
      request['Authorization'] = "Basic #{credentials}"
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'

      payload = { fields: fields }
      request.body = payload.to_json

      begin
        response = http.request(request)

        case response.code
        when '204'
          # Success - no content returned
          return true
        when '400'
          error_details = JSON.parse(response.body)
          raise StandardError, "Bad request when updating ticket fields: #{JSON.pretty_generate(error_details)}"
        when '401'
          raise StandardError, 'Authentication failed. Please check your JIRA_ACCESS_TOKEN'
        when '403'
          raise StandardError, 'Permission denied. You may not have permission to update this ticket'
        when '404'
          raise StandardError, "Ticket #{ticket_key} not found"
        else
          raise StandardError, "HTTP #{response.code} - #{response.message}\n#{response.body}"
        end
      rescue StandardError => e
        raise StandardError, "Error updating ticket fields: #{e.message}"
      end
    end

    def get_transition_id(ticket_key, status_name)
      uri = URI("#{@jira_base_url}/rest/api/3/issue/#{ticket_key}/transitions")

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
          transitions = JSON.parse(response.body)['transitions']

          # Find transition by name (case-insensitive)
          transition = transitions.find do |t| 
            t['to']['name'].downcase == status_name.downcase ||
            t['name'].downcase == status_name.downcase
          end

          if transition
            return transition['id']
          else
            available_transitions = transitions.map { |t| "#{t['name']} (to: #{t['to']['name']})" }
            raise StandardError, "Available transitions: #{available_transitions.join(', ')}"
          end
        else
          raise StandardError, "Error getting transitions: HTTP #{response.code}"
        end
      rescue StandardError => e
        raise StandardError, "Error getting transitions: #{e.message}"
      end
    end

    def transition_ticket(ticket_key, transition_id)
      uri = URI("#{@jira_base_url}/rest/api/3/issue/#{ticket_key}/transitions")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      credentials = Base64.strict_encode64("#{@jira_email}:#{@access_token}")
      request['Authorization'] = "Basic #{credentials}"
      request['Accept'] = 'application/json'
      request['Content-Type'] = 'application/json'

      payload = {
        transition: {
          id: transition_id
        }
      }
      request.body = payload.to_json

      begin
        response = http.request(request)

        case response.code
        when '204'
          return true
        when '400'
          error_details = JSON.parse(response.body)
          raise StandardError, "Bad request when transitioning ticket: #{JSON.pretty_generate(error_details)}"
        when '401'
          raise StandardError, 'Authentication failed. Please check your JIRA_ACCESS_TOKEN'
        when '403'
          raise StandardError, 'Permission denied. You may not have permission to transition this ticket'
        when '404'
          raise StandardError, "Ticket #{ticket_key} not found"
        else
          raise StandardError, "HTTP #{response.code} - #{response.message}\n#{response.body}"
        end
      rescue StandardError => e
        raise StandardError, "Error transitioning ticket: #{e.message}"
      end
    end
  end
end