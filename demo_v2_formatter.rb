#!/usr/bin/env ruby

require_relative 'jira_markdown_formatter_v2'
require_relative 'jira_markdown_formatter'
require 'json'

puts "🚀 JIRA Markdown Formatter V2 Demo"
puts "=" * 50

# Demo 1: Basic fallback functionality (no JIRA credentials needed)
puts "\n📝 Demo 1: Basic Conversion (using fallback)"
markdown_sample = <<~MARKDOWN
  ## Project Overview
  
  This is a sample **ticket description** with various formatting:
  
  * Important feature with `code reference`
  * Link to [GitHub](https://github.com/zendesk/project)
    * Nested requirement
    * Another nested item
  * Final bullet point
  
  ### Technical Details
  
  The implementation involves *multiple components*.
MARKDOWN

puts "Input Markdown:"
puts markdown_sample
puts "\n" + "-" * 30

begin
  result = JiraMarkdownFormatterV2.convert_with_fallback(markdown_sample)
  puts "✅ Conversion successful using fallback!"
  puts "ADF Structure:"
  puts JSON.pretty_generate(result)
rescue => e
  puts "❌ Conversion failed: #{e.message}"
end

# Demo 2: Template file conversion
puts "\n" + "=" * 50
puts "📄 Demo 2: Template File Conversion"

if File.exist?('jira_template_v2.md')
  template_content = File.read('jira_template_v2.md')
  puts "Converting jira_template_v2.md..."
  
  begin
    result = JiraMarkdownFormatterV2.convert_with_fallback(template_content)
    puts "✅ Template converted successfully!"
    
    # Save the result
    File.write('template_converted_v2.json', JSON.pretty_generate(result))
    puts "💾 Result saved to template_converted_v2.json"
    
    # Show summary
    content_types = result[:content].map { |item| item[:type] }.uniq
    puts "📊 Content types found: #{content_types.join(', ')}"
    puts "📊 Total content blocks: #{result[:content].length}"
    
  rescue => e
    puts "❌ Template conversion failed: #{e.message}"
  end
else
  puts "❌ Template file not found: jira_template_v2.md"
end

# Demo 3: API usage example (requires credentials)
puts "\n" + "=" * 50
puts "🔌 Demo 3: JIRA API Usage Example"

if ENV['JIRA_BASE_URL'] && ENV['JIRA_API_TOKEN'] && ENV['JIRA_EMAIL']
  puts "✅ JIRA credentials found in environment"
  puts "Testing API connection..."
  
  if JiraMarkdownFormatterV2.test_connection
    puts "✅ JIRA API connection successful!"
    
    # Try API conversion
    simple_markdown = "## API Test\n\nThis is a **test** of the JIRA API conversion."
    
    begin
      api_result = JiraMarkdownFormatterV2.convert_markdown_to_adf(simple_markdown)
      puts "✅ API conversion successful!"
      puts "API Result:"
      puts JSON.pretty_generate(api_result)
    rescue => e
      puts "❌ API conversion failed: #{e.message}"
    end
  else
    puts "❌ JIRA API connection failed"
  end
else
  puts "⚠️  JIRA credentials not found in environment"
  puts "To test API functionality, set these environment variables:"
  puts JiraMarkdownFormatterV2.setup_instructions
end

puts "\n" + "=" * 50
puts "🎯 Summary"
puts "=" * 50
puts "✅ V2 formatter created with JIRA REST API integration"
puts "✅ Fallback to V1 formatter when API unavailable"
puts "✅ Comprehensive error handling and authentication"
puts "✅ CLI interface for testing and conversion"
puts "\n📖 Usage Examples:"
puts "  ruby jira_markdown_formatter_v2.rb test-connection"
puts "  ruby jira_markdown_formatter_v2.rb your_file.md"
puts "  ruby demo_v2_formatter.rb"