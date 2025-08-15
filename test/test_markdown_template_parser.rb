#!/usr/bin/env ruby

require_relative 'test_helper'
require_relative '../lib/jira/markdown_template_parser'

class TestMarkdownTemplateParser < Minitest::Test
  include TestHelper
  
  def setup
    @parser = Jira::MarkdownTemplateParser
  end
  
  def test_parses_basic_template_structure
    result = @parser.parse_template(sample_markdown)
    
    assert result.is_a?(Hash)
    assert result.has_key?(:title)
    assert result.has_key?(:project_key)
    assert result.has_key?(:priority)
    assert result.has_key?(:labels)
    assert result.has_key?(:description_section)
    assert result.has_key?(:references_section)
    assert result.has_key?(:acceptance_criteria_section)
  end
  
  def test_extracts_title_from_first_heading
    markdown = <<~MD
      ## Remove email_log_inbound_mail_rate_limit feature flag
      
      Content here...
    MD
    
    result = @parser.parse_template(markdown)
    assert_equal 'Remove email_log_inbound_mail_rate_limit feature flag', result[:title]
  end
  
  def test_extracts_project_information
    result = @parser.parse_template(sample_markdown)
    
    assert_equal 'EM', result[:project_key]
    assert_equal 'Medium', result[:priority]
    assert_equal ['test', 'automation'], result[:labels]
  end
  
  def test_extracts_description_section
    result = @parser.parse_template(sample_markdown)
    
    description = result[:description_section].join("\n")
    assert description.include?('This is a test description')
    assert description.include?('inline code')
    assert description.include?('bold text')
    assert description.include?('The description continues')
  end
  
  def test_extracts_references_section
    result = @parser.parse_template(sample_markdown)
    
    references = result[:references_section].join("\n")
    assert references.include?('Code Context')
    assert references.include?('test_file.rb#L1-L10')
    assert references.include?('Testing Considerations')
    assert references.include?('Unit tests required')
  end
  
  def test_extracts_acceptance_criteria_section
    result = @parser.parse_template(sample_markdown)
    
    criteria = result[:acceptance_criteria_section].join("\n")
    assert criteria.include?('Clear testable condition 1')
    assert criteria.include?('Clear testable condition 2')
    assert criteria.include?('Feature behavior validation')
    assert criteria.include?('Error handling')
  end
  
  def test_handles_missing_project_information
    markdown = <<~MD
      ## Test Title
      
      ## Description
      
      Just a description without project info.
      
      ## Acceptance Criteria
      
      * Some criteria
    MD
    
    result = @parser.parse_template(markdown)
    
    assert_equal 'Test Title', result[:title]
    assert_equal 'EM', result[:project_key] # Default value
    assert_equal 'Medium', result[:priority] # Default value
    assert_equal [], result[:labels] # Default empty array
  end
  
  def test_handles_minimal_template
    markdown = <<~MD
      ## Simple Title
      
      ## Description
      
      Basic description here.
    MD
    
    result = @parser.parse_template(markdown)
    
    assert_equal 'Simple Title', result[:title]
    assert result[:description_section].join("\n").include?('Basic description')
    assert_equal [], result[:references_section]
    assert_equal [], result[:acceptance_criteria_section]
  end
  
  def test_parses_different_project_keys
    markdown = <<~MD
      ## Test Title
      
      ### Project Information
      **Project:** TALK
      **Priority:** High
      **Labels:** urgent, bug-fix
      
      ## Description
      Content here.
    MD
    
    result = @parser.parse_template(markdown)
    
    assert_equal 'TALK', result[:project_key]
    assert_equal 'High', result[:priority]
    assert_equal ['urgent', 'bug-fix'], result[:labels]
  end
  
  def test_parse_for_description_builds_full_description
    full_description = @parser.parse_for_description(sample_markdown)
    
    # Should contain all sections combined
    assert full_description.include?('This is a test description')
    assert full_description.include?('Code Context')
    assert full_description.include?('Testing Considerations')
    assert full_description.include?('Clear testable condition 1')
    
    # Should be structured with proper markdown headings
    # Note: Description content is included directly without header
    assert full_description.include?('## References and Notes')
    assert full_description.include?('## Acceptance Criteria')
  end
  
  def test_handles_empty_sections_gracefully
    markdown = <<~MD
      ## Test Title
      
      ### Project Information
      **Project:** EM
      
      ## Description
      
      Some description.
      
      ## References and Notes
      
      ## Acceptance Criteria
    MD
    
    result = @parser.parse_template(markdown)
    
    assert_equal 'Test Title', result[:title]
    assert result[:description_section].join("\n").include?('Some description')
    # Empty sections may contain empty strings after parsing
    assert result[:references_section].empty? || result[:references_section] == [""]
    assert result[:acceptance_criteria_section].empty? || result[:acceptance_criteria_section] == [""]
  end
  
  def test_preserves_markdown_formatting_in_sections
    markdown = <<~MD
      ## Test Title
      
      ## Description
      
      This has **bold text** and `code` and [links](https://example.com).
      
      * List item 1
      * List item 2
        * Nested item
      
      ## Acceptance Criteria
      
      * Criterion with `code_reference`
      * Another with **emphasis**
    MD
    
    result = @parser.parse_template(markdown)
    
    description = result[:description_section].join("\n")
    assert description.include?('**bold text**')
    assert description.include?('`code`')
    assert description.include?('[links](https://example.com)')
    assert description.include?('* List item 1')
    assert description.include?('  * Nested item')
    
    criteria = result[:acceptance_criteria_section].join("\n")
    assert criteria.include?('`code_reference`')
    assert criteria.include?('**emphasis**')
  end
  
  def test_extracts_metadata_with_various_formats
    markdown = <<~MD
      ## Test Title
      
      ### Project Information
      **Project:**   TALK   
      **Priority:** Low  
      **Labels:**    cleanup,   technical-debt  
      **Parent:** TALK-123
      **Assignee:** john@example.com
      
      ## Description
      Content.
    MD
    
    result = @parser.parse_template(markdown)
    
    assert_equal 'TALK', result[:project_key]
    assert_equal 'Low', result[:priority]
    assert_equal ['cleanup', 'technical-debt'], result[:labels] # Splits and trims
    assert result.has_key?(:parent_issue)
    assert result.has_key?(:assignee)
  end
  
  def test_section_extraction_is_case_insensitive
    markdown = <<~MD
      ## Test Title
      
      ## description
      
      Lower case section header.
      
      ## ACCEPTANCE CRITERIA
      
      Upper case section header.
      
      ## References and notes
      
      Mixed case section header.
    MD
    
    result = @parser.parse_template(markdown)
    
    assert result[:description_section].join("\n").include?('Lower case section header')
    assert result[:acceptance_criteria_section].join("\n").include?('Upper case section header')
    assert result[:references_section].join("\n").include?('Mixed case section header')
  end
end