#!/usr/bin/env ruby

require_relative 'jira_markdown_formatter_v2'
require_relative 'jira_markdown_formatter'

puts "Testing fallback functionality..."
markdown = "# Test\n\nThis is **bold** text with `code`."

begin
  result = JiraMarkdownFormatterV2.convert_with_fallback(markdown)
  puts "✅ Conversion successful!"
  puts "Result: #{result.inspect}"
  
  if result && result['content']
    puts "Content items: #{result['content'].length}"
  end
  
  # Test empty content
  puts "\nTesting empty content..."
  empty_result = JiraMarkdownFormatterV2.convert_with_fallback("")
  puts "✅ Empty content result: #{empty_result.inspect}"
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(3)
end