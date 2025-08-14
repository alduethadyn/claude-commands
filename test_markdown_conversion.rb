#!/usr/bin/env ruby

require_relative 'jira_markdown_formatter_v2'
require 'json'

# Test comprehensive markdown conversion
markdown_content = File.read('markdown_test_elements.md')

begin
  result = JiraMarkdownFormatterV2.convert_with_fallback(markdown_content)
  File.write('markdown_test_output.json', JSON.pretty_generate(result))
  puts "✅ Conversion successful - saved to markdown_test_output.json"
  
  # Analyze the result
  puts "\n📊 Analysis:"
  puts "Document type: #{result[:type]}"
  puts "Content blocks: #{result[:content].length}"
  
  content_types = result[:content].map { |item| item[:type] }
  type_counts = content_types.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
  puts "Block types found:"
  type_counts.each { |type, count| puts "  - #{type}: #{count}" }
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(3)
end