#!/usr/bin/env ruby

# Test helper for Claude JIRA integration tests
require 'minitest/autorun'
require 'json'

# Add lib directory to load path
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

# Test utilities
module TestHelper
  # Create temporary markdown file for testing
  def create_temp_markdown(content, filename = 'test.md')
    path = File.join('/tmp', filename)
    File.write(path, content)
    path
  end
  
  # Clean up temporary files
  def cleanup_temp_files(*paths)
    paths.each { |path| File.delete(path) if File.exist?(path) }
  end
  
  # Sample markdown content for testing
  def sample_markdown
    <<~MARKDOWN
      ## Test Title
      
      ### Project Information
      **Project:** EM
      **Priority:** Medium
      **Labels:** test, automation
      
      ## Description
      
      This is a test description with `inline code` and **bold text**.
      
      The description continues with more content.
      
      ## References and Notes
      
      ### Code Context
      * [test_file.rb#L1-L10](https://github.com/zendesk/zendesk/blob/main/test_file.rb#L1-L10) - Test file reference
      * [another_file.rb#L20-L30](https://github.com/zendesk/zendesk/blob/main/another_file.rb#L20-L30) - Another reference
      
      ### Testing Considerations
      * Unit tests required for `TestClass`
      * Integration test scenarios
      * Performance testing for **large datasets**
      
      ## Acceptance Criteria
      
      * Clear testable condition 1
      * Clear testable condition 2 with `code_reference`
      * Feature behavior validation
      * Error handling with **proper validation**
    MARKDOWN
  end
  
  # Sample invalid markdown (for error testing)
  def invalid_markdown
    "# Title\n\n[Broken link without URL\n\n**Unclosed bold"
  end
  
  # Expected ADF structure patterns
  def assert_valid_adf_structure(adf)
    assert_equal 'doc', adf[:type]
    assert_equal 1, adf[:version]
    assert adf[:content].is_a?(Array)
    assert adf[:content].length > 0
  end
  
  def assert_heading(content_item, level, text)
    assert_equal 'heading', content_item[:type]
    assert_equal level, content_item[:attrs][:level]
    assert_equal text, content_item[:content][0][:text]
  end
  
  def assert_paragraph(content_item)
    assert_equal 'paragraph', content_item[:type]
    assert content_item[:content].is_a?(Array)
  end
  
  def assert_bullet_list(content_item)
    assert_equal 'bulletList', content_item[:type]
    assert content_item[:content].is_a?(Array)
    content_item[:content].each do |item|
      assert_equal 'listItem', item[:type]
      assert item[:content].is_a?(Array)
    end
  end
end