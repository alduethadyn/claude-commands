#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'
require 'base64'

# V2 Markdown formatter that uses JIRA's REST API for markdown to ADF conversion
# This leverages JIRA's native conversion capabilities instead of manual parsing
module JiraMarkdownFormatterV2
  class ConversionError < StandardError; end
  class AuthenticationError < StandardError; end
  class APIError < StandardError; end

  # Convert markdown text to ADF using JIRA's REST API
  # @param markdown_text [String] The markdown content to convert
  # @param jira_base_url [String] The base URL of your JIRA instance (e.g., 'https://company.atlassian.net')
  # @param auth_token [String] JIRA API token or basic auth credentials
  # @param auth_email [String] Email for API token authentication (optional if using basic auth)
  # @return [Hash] ADF document structure
  def self.convert_markdown_to_adf(markdown_text, jira_base_url: nil, auth_token: nil, auth_email: nil)
    return { type: "doc", version: 1, content: [] } if markdown_text.strip.empty?

    # Get authentication details from environment or parameters
    base_url = jira_base_url || ENV['JIRA_BASE_URL'] || 'https://zendesk.atlassian.net'
    token = auth_token || ENV['JIRA_ACCESS_TOKEN']
    email = auth_email || ENV['JIRA_EMAIL']

    raise AuthenticationError, "JIRA_ACCESS_TOKEN is required" unless token
    raise AuthenticationError, "JIRA_EMAIL is required for API token auth" unless email

    # Prepare the API request
    uri = URI("#{base_url}/rest/api/3/contentbody/convert/markdown")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    # Create the request
    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'

    # Set up authentication (API token)
    auth_string = Base64.encode64("#{email}:#{token}").strip
    request['Authorization'] = "Basic #{auth_string}"

    # Request body - convert markdown to ADF
    request_body = {
      representation: 'markdown',
      value: markdown_text
    }
    request.body = request_body.to_json

    # Make the API call
    begin
      response = http.request(request)

      case response.code.to_i
      when 200
        result = JSON.parse(response.body)
        return result['value'] if result['value']
        raise ConversionError, "No ADF content returned from API"
      when 401, 403
        raise AuthenticationError, "Authentication failed: #{response.body}"
      when 400
        error_details = JSON.parse(response.body) rescue { 'errorMessages' => [response.body] }
        raise APIError, "Bad request: #{error_details['errorMessages']&.join(', ') || response.body}"
      else
        raise APIError, "API request failed with status #{response.code}: #{response.body}"
      end

    rescue JSON::ParserError => e
      raise ConversionError, "Failed to parse API response: #{e.message}"
    rescue Net::TimeoutError, Net::OpenTimeout => e
      raise APIError, "Request timeout: #{e.message}"
    rescue SocketError => e
      raise APIError, "Network error: #{e.message}"
    end
  end

  # Fallback method that uses the original v1 formatter if API conversion fails
  # This provides a backup conversion method
  def self.convert_with_fallback(markdown_text, jira_base_url: nil, auth_token: nil, auth_email: nil)
    begin
      convert_markdown_to_adf(markdown_text, 
                            jira_base_url: jira_base_url, 
                            auth_token: auth_token, 
                            auth_email: auth_email)
    rescue => e
      warn "JIRA API conversion failed (#{e.message}), falling back to local conversion"

      # Load the original formatter if available
      formatter_path = File.join(File.dirname(__FILE__), 'jira_markdown_formatter.rb')
      require_relative 'jira_markdown_formatter' if File.exist?(formatter_path)

      if defined?(JiraMarkdownFormatter)
        JiraMarkdownFormatter.convert_markdown_to_adf(markdown_text)
      else
        raise ConversionError, "API conversion failed and no fallback available: #{e.message}"
      end
    end
  end

  # Test the connection and authentication to JIRA
  # @param jira_base_url [String] The base URL of your JIRA instance
  # @param auth_token [String] JIRA API token
  # @param auth_email [String] Email for API token authentication
  # @return [Boolean] true if connection is successful
  def self.test_connection(jira_base_url: nil, auth_token: nil, auth_email: nil)
    base_url = jira_base_url || ENV['JIRA_BASE_URL']
    token = auth_token || ENV['JIRA_API_TOKEN']
    email = auth_email || ENV['JIRA_EMAIL']

    return false unless base_url && token && email

    # Test with a simple markdown conversion
    test_markdown = "# Test\n\nThis is a **test** conversion."

    begin
      result = convert_markdown_to_adf(test_markdown, 
                                     jira_base_url: base_url, 
                                     auth_token: token, 
                                     auth_email: email)
      return result.is_a?(Hash) && result['type'] == 'doc'
    rescue => e
      puts "Connection test failed: #{e.message}"
      return false
    end
  end

  # Get environment variable setup instructions
  def self.setup_instructions
    <<~INSTRUCTIONS
      To use JiraMarkdownFormatterV2, set these environment variables:

      export JIRA_BASE_URL="https://your-company.atlassian.net"
      export JIRA_EMAIL="your-email@company.com"
      export JIRA_API_TOKEN="your-api-token"

      Get your API token from: https://id.atlassian.com/manage-profile/security/api-tokens

      Or pass them as parameters to convert_markdown_to_adf():
      JiraMarkdownFormatterV2.convert_markdown_to_adf(
        markdown_text,
        jira_base_url: "https://your-company.atlassian.net",
        auth_token: "your-api-token",
        auth_email: "your-email@company.com"
      )
    INSTRUCTIONS
  end
end

# CLI usage when run directly
if __FILE__ == $0
  if ARGV.length == 0
    puts JiraMarkdownFormatterV2.setup_instructions
    puts "\nUsage: ruby jira_markdown_formatter_v2.rb <markdown_file>"
    puts "       ruby jira_markdown_formatter_v2.rb test-connection"
    exit 1
  end

  case ARGV[0]
  when 'test-connection'
    if JiraMarkdownFormatterV2.test_connection
      puts "✅ Connection to JIRA successful!"
    else
      puts "❌ Connection to JIRA failed!"
      puts JiraMarkdownFormatterV2.setup_instructions
      exit 1
    end
  else
    markdown_file = ARGV[0]

    unless File.exist?(markdown_file)
      puts "Error: File '#{markdown_file}' not found"
      exit 1
    end

    begin
      markdown_content = File.read(markdown_file)
      adf_result = JiraMarkdownFormatterV2.convert_markdown_to_adf(markdown_content)
      puts JSON.pretty_generate(adf_result)
    rescue => e
      puts "Error: #{e.message}"
      exit 1
    end
  end
end