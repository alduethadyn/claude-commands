#!/usr/bin/env ruby

require_relative 'jira_markdown_formatter_v2'
require 'json'

class JiraFormatterV2Tester
  def initialize
    @test_results = []
  end

  def run_all_tests
    puts "🧪 Testing JIRA Markdown Formatter V2"
    puts "=" * 50

    # Test connection first
    test_connection

    # Test with template file
    test_template_conversion

    # Test specific markdown features
    test_markdown_features

    # Test error handling
    test_error_handling

    # Print summary
    print_summary
  end

  private

  def test_connection
    puts "\n📡 Testing JIRA API Connection..."
    
    if JiraMarkdownFormatterV2.test_connection
      record_result("Connection Test", true, "Successfully connected to JIRA API")
    else
      record_result("Connection Test", false, "Failed to connect to JIRA API")
      puts "⚠️  Skipping API tests - check your environment variables:"
      puts JiraMarkdownFormatterV2.setup_instructions
    end
  end

  def test_template_conversion
    puts "\n📄 Testing Template Conversion..."
    
    template_file = 'jira_template_v2.md'
    
    unless File.exist?(template_file)
      record_result("Template Conversion", false, "Template file not found: #{template_file}")
      return
    end

    begin
      markdown_content = File.read(template_file)
      
      # Test with API
      begin
        adf_result = JiraMarkdownFormatterV2.convert_markdown_to_adf(markdown_content)
        
        if validate_adf_structure(adf_result)
          record_result("Template API Conversion", true, "Template converted successfully via API")
          save_test_output("template_api_result.json", adf_result)
        else
          record_result("Template API Conversion", false, "Invalid ADF structure returned")
        end
      rescue => e
        record_result("Template API Conversion", false, "API conversion failed: #{e.message}")
      end

      # Test with fallback
      begin
        adf_result = JiraMarkdownFormatterV2.convert_with_fallback(markdown_content)
        
        if validate_adf_structure(adf_result)
          record_result("Template Fallback Conversion", true, "Template converted successfully with fallback")
          save_test_output("template_fallback_result.json", adf_result)
        else
          record_result("Template Fallback Conversion", false, "Invalid ADF structure returned")
        end
      rescue => e
        record_result("Template Fallback Conversion", false, "Fallback conversion failed: #{e.message}")
      end

    rescue => e
      record_result("Template Conversion", false, "Failed to read template: #{e.message}")
    end
  end

  def test_markdown_features
    puts "\n✨ Testing Markdown Features..."

    test_cases = [
      {
        name: "Headers",
        markdown: "## Main Header\n\n### Sub Header\n\nContent here."
      },
      {
        name: "Bold and Italic",
        markdown: "This is **bold** and this is *italic* text."
      },
      {
        name: "Code Blocks",
        markdown: "Here's some `inline code` in text."
      },
      {
        name: "Links",
        markdown: "Check out [GitHub](https://github.com) for code."
      },
      {
        name: "Bullet Lists",
        markdown: "* First item\n* Second item\n  * Nested item\n  * Another nested item\n* Third item"
      },
      {
        name: "Complex Mixed Content",
        markdown: "## Overview\n\n**Important**: This is a test with `code` and [links](https://example.com).\n\n* Item one with **bold**\n* Item two with *italic*\n  * Nested with `code`"
      }
    ]

    test_cases.each do |test_case|
      puts "  Testing: #{test_case[:name]}"
      
      begin
        # Test API conversion
        adf_result = JiraMarkdownFormatterV2.convert_markdown_to_adf(test_case[:markdown])
        
        if validate_adf_structure(adf_result)
          record_result("#{test_case[:name]} API", true, "Converted successfully")
          save_test_output("#{test_case[:name].downcase.gsub(/\s+/, '_')}_api.json", adf_result)
        else
          record_result("#{test_case[:name]} API", false, "Invalid ADF structure")
        end
      rescue => e
        record_result("#{test_case[:name]} API", false, "Conversion failed: #{e.message}")
        
        # Try fallback
        begin
          adf_result = JiraMarkdownFormatterV2.convert_with_fallback(test_case[:markdown])
          record_result("#{test_case[:name]} Fallback", validate_adf_structure(adf_result), "Fallback conversion")
        rescue => fallback_error
          record_result("#{test_case[:name]} Fallback", false, "Fallback failed: #{fallback_error.message}")
        end
      end
    end
  end

  def test_error_handling
    puts "\n🚨 Testing Error Handling..."

    # Test empty content
    begin
      result = JiraMarkdownFormatterV2.convert_with_fallback("")
      expected_empty = { "type" => "doc", "version" => 1, "content" => [] }
      
      if result == expected_empty
        record_result("Empty Content", true, "Correctly handles empty markdown")
      else
        record_result("Empty Content", false, "Unexpected result for empty content: #{result.inspect}")
      end
    rescue => e
      record_result("Empty Content", false, "Error handling empty content: #{e.message}")
    end

    # Test invalid credentials (only if we have some credentials set)
    if ENV['JIRA_BASE_URL']
      begin
        JiraMarkdownFormatterV2.convert_markdown_to_adf("# Test", 
                                                       jira_base_url: ENV['JIRA_BASE_URL'],
                                                       auth_token: "invalid-token",
                                                       auth_email: "invalid@email.com")
        record_result("Invalid Auth", false, "Should have failed with invalid credentials")
      rescue JiraMarkdownFormatterV2::AuthenticationError
        record_result("Invalid Auth", true, "Correctly caught authentication error")
      rescue => e
        record_result("Invalid Auth", true, "Caught error as expected: #{e.class}")
      end
    end
  end

  def validate_adf_structure(adf)
    return false unless adf.is_a?(Hash)
    return false unless adf['type'] == 'doc'
    return false unless adf['version']
    return false unless adf['content'].is_a?(Array)
    
    true
  end

  def save_test_output(filename, content)
    File.write("test_outputs/#{filename}", JSON.pretty_generate(content))
  rescue => e
    # Create directory if it doesn't exist
    Dir.mkdir('test_outputs') unless Dir.exist?('test_outputs')
    File.write("test_outputs/#{filename}", JSON.pretty_generate(content))
  rescue => e
    puts "    ⚠️  Could not save test output: #{e.message}"
  end

  def record_result(test_name, success, message)
    @test_results << {
      name: test_name,
      success: success,
      message: message
    }
    
    status = success ? "✅" : "❌"
    puts "    #{status} #{test_name}: #{message}"
  end

  def print_summary
    puts "\n" + "=" * 50
    puts "📊 Test Summary"
    puts "=" * 50

    passed = @test_results.count { |r| r[:success] }
    total = @test_results.length

    puts "Total Tests: #{total}"
    puts "Passed: #{passed}"
    puts "Failed: #{total - passed}"
    puts "Success Rate: #{total > 0 ? (passed.to_f / total * 100).round(1) : 0}%"

    if total - passed > 0
      puts "\n❌ Failed Tests:"
      @test_results.select { |r| !r[:success] }.each do |result|
        puts "  - #{result[:name]}: #{result[:message]}"
      end
    end

    puts "\n🎯 Next Steps:"
    if ENV['JIRA_BASE_URL'] && ENV['JIRA_API_TOKEN'] && ENV['JIRA_EMAIL']
      puts "  - Review test outputs in test_outputs/ directory"
      puts "  - Compare API vs fallback conversion results"
      puts "  - Test with your actual JIRA content"
    else
      puts "  - Set up JIRA environment variables to test API functionality"
      puts "  - Run: ruby jira_markdown_formatter_v2.rb test-connection"
    end
  end
end

# Run tests when script is executed directly
if __FILE__ == $0
  tester = JiraFormatterV2Tester.new
  tester.run_all_tests
end