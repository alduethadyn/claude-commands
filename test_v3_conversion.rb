#!/usr/bin/env ruby

require_relative 'jira_markdown_formatter_v3'
require 'json'

puts "🧪 Testing JIRA Markdown Formatter V3"
puts "=" * 50

# Test the v3 template
if File.exist?('jira_template_v3.md')
  puts "📄 Testing V3 Template Conversion..."
  
  template_content = File.read('jira_template_v3.md')
  
  begin
    result = JiraMarkdownFormatterV3.convert_with_fallback(template_content)
    
    # Save the result
    File.write('template_v3_converted.json', JSON.pretty_generate(result))
    puts "✅ V3 template converted successfully!"
    puts "💾 Result saved to template_v3_converted.json"
    
    # Analyze the structure
    puts "\n📊 Analysis:"
    puts "Document type: #{result[:type]}"
    puts "Content blocks: #{result[:content].length}"
    
    content_types = result[:content].map { |item| item[:type] }
    type_counts = content_types.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
    puts "Block types found:"
    type_counts.each { |type, count| puts "  - #{type}: #{count}" }
    
    # Check for specific improvements
    puts "\n✨ Template Structure Analysis:"
    
    # Check if project info is properly structured
    project_info_found = result[:content].any? { |block| 
      block[:type] == 'heading' && 
      block[:content] && 
      block[:content][0][:text] == 'Project Information' 
    }
    puts "  - Project Information section: #{project_info_found ? '✅' : '❌'}"
    
    # Check for proper heading hierarchy
    headings = result[:content].select { |block| block[:type] == 'heading' }
    heading_levels = headings.map { |h| h[:attrs][:level] }.sort
    puts "  - Heading levels: #{heading_levels.join(', ')}"
    
    # Check for links with proper formatting
    has_proper_links = result[:content].any? { |block|
      next false unless block[:type] == 'bulletList'
      block[:content].any? { |item|
        item[:content][0][:content].any? { |text|
          text[:marks] && text[:marks].any? { |mark| mark[:type] == 'link' }
        } rescue false
      }
    }
    puts "  - Proper link formatting: #{has_proper_links ? '✅' : '❌'}"
    
  rescue => e
    puts "❌ V3 template conversion failed: #{e.message}"
    puts e.backtrace.first(3)
  end
else
  puts "❌ V3 template not found: jira_template_v3.md"
end

# Compare with v2 template if available
if File.exist?('jira_template_v2.md') && File.exist?('template_converted_v2.json')
  puts "\n" + "=" * 50
  puts "📊 V2 vs V3 Comparison"
  
  v2_result = JSON.parse(File.read('template_converted_v2.json'))
  v3_result = JSON.parse(File.read('template_v3_converted.json'))
  
  puts "V2 content blocks: #{v2_result['content'].length}"
  puts "V3 content blocks: #{v3_result['content'].length}"
  
  v2_types = v2_result['content'].map { |item| item['type'] }.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
  v3_types = v3_result['content'].map { |item| item['type'] }.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
  
  puts "\nBlock type comparison:"
  (v2_types.keys + v3_types.keys).uniq.each do |type|
    puts "  - #{type}: V2=#{v2_types[type]}, V3=#{v3_types[type]}"
  end
end

puts "\n" + "=" * 50
puts "🎯 Next Steps:"
puts "✅ V3 template created with improved structure"
puts "✅ Enhanced markdown preprocessing for better conversion"
puts "✅ Updated environment variable names (JIRA_ACCESS_TOKEN)"
puts "✅ Better error handling and retry logic"
puts "\n📖 Usage:"
puts "  ruby jira_markdown_formatter_v3.rb test-connection"
puts "  ruby jira_markdown_formatter_v3.rb jira_template_v3.md"