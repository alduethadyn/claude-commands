#!/usr/bin/env ruby

require_relative 'test_helper'
require_relative '../lib/jira/markdown_formatter'

class TestMarkdownFormatter < Minitest::Test
  include TestHelper
  
  def setup
    @formatter = Jira::MarkdownFormatter
  end
  
  def test_converts_basic_markdown_to_adf
    markdown = "# Test Title\n\nThis is a paragraph."
    adf = @formatter.convert_markdown_to_adf(markdown)
    
    assert_valid_adf_structure(adf)
    assert_equal 2, adf[:content].length
    
    # Check heading
    assert_heading(adf[:content][0], 1, 'Test Title')
    
    # Check paragraph
    assert_paragraph(adf[:content][1])
    assert_equal 'This is a paragraph.', adf[:content][1][:content][0][:text]
  end
  
  def test_converts_multiple_heading_levels
    markdown = <<~MD
      # Level 1
      ## Level 2  
      ### Level 3
      #### Level 4
      ##### Level 5
      ###### Level 6
    MD
    
    adf = @formatter.convert_markdown_to_adf(markdown)
    
    assert_equal 6, adf[:content].length
    (1..6).each do |level|
      assert_heading(adf[:content][level-1], level, "Level #{level}")
    end
  end
  
  def test_converts_text_formatting
    markdown = "This has **bold text** and *italic text* and `inline code`."
    adf = @formatter.convert_markdown_to_adf(markdown)
    
    paragraph = adf[:content][0]
    content = paragraph[:content]
    
    # Should have multiple text nodes with different marks
    assert content.length > 1
    
    # Find bold text
    bold_node = content.find { |node| node[:marks]&.any? { |mark| mark[:type] == 'strong' } }
    assert bold_node
    assert_equal 'bold text', bold_node[:text]
    
    # Find italic text  
    italic_node = content.find { |node| node[:marks]&.any? { |mark| mark[:type] == 'em' } }
    assert italic_node
    assert_equal 'italic text', italic_node[:text]
    
    # Find code text
    code_node = content.find { |node| node[:marks]&.any? { |mark| mark[:type] == 'code' } }
    assert code_node
    assert_equal 'inline code', code_node[:text]
  end
  
  def test_converts_links
    markdown = "Check out [this link](https://example.com) for more info."
    adf = @formatter.convert_markdown_to_adf(markdown)
    
    paragraph = adf[:content][0]
    content = paragraph[:content]
    
    # Find link node
    link_node = content.find { |node| node[:marks]&.any? { |mark| mark[:type] == 'link' } }
    assert link_node
    assert_equal 'this link', link_node[:text]
    assert_equal 'https://example.com', link_node[:marks][0][:attrs][:href]
  end
  
  def test_converts_bullet_lists
    markdown = <<~MD
      * First item
      * Second item
      * Third item
    MD
    
    adf = @formatter.convert_markdown_to_adf(markdown)
    
    assert_equal 1, adf[:content].length
    assert_bullet_list(adf[:content][0])
    
    list = adf[:content][0]
    assert_equal 3, list[:content].length
    
    # Check list items
    assert_equal 'First item', list[:content][0][:content][0][:content][0][:text]
    assert_equal 'Second item', list[:content][1][:content][0][:content][0][:text]  
    assert_equal 'Third item', list[:content][2][:content][0][:content][0][:text]
  end
  
  def test_converts_nested_bullet_lists
    markdown = <<~MD
      * Top level item
        * Nested item 1
        * Nested item 2
      * Another top level
    MD
    
    adf = @formatter.convert_markdown_to_adf(markdown)
    
    assert_equal 1, adf[:content].length
    assert_bullet_list(adf[:content][0])
    
    list = adf[:content][0]
    assert_equal 2, list[:content].length
    
    # First item should have nested list
    first_item = list[:content][0]
    assert_equal 2, first_item[:content].length # paragraph + nested list
    
    nested_list = first_item[:content][1]
    assert_equal 'bulletList', nested_list[:type]
    assert_equal 2, nested_list[:content].length
  end
  
  def test_handles_empty_content
    adf = @formatter.convert_markdown_to_adf("")
    
    assert_equal 'doc', adf[:type]
    assert_equal 1, adf[:version]
    assert_equal 0, adf[:content].length
  end
  
  def test_handles_whitespace_only_content
    adf = @formatter.convert_markdown_to_adf("   \n\n   \n   ")
    
    assert_equal 0, adf[:content].length
  end
  
  def test_convert_with_fallback_method
    markdown = "# Test\n\nParagraph content."
    adf = @formatter.convert_with_fallback(markdown)
    
    assert_valid_adf_structure(adf)
    assert_equal 2, adf[:content].length
  end
  
  def test_test_connection_always_returns_true
    assert_equal true, @formatter.test_connection
  end
  
  def test_setup_instructions_contains_usage_info
    instructions = @formatter.setup_instructions
    
    assert instructions.include?('convert_markdown_to_adf')
    assert instructions.include?('Bold text')
    assert instructions.include?('Links')
    assert instructions.include?('Bullet lists')
  end
  
  def test_preserves_text_with_special_characters
    markdown = "Text with & ampersand < less than > greater than \"quotes\""
    adf = @formatter.convert_markdown_to_adf(markdown)
    
    paragraph = adf[:content][0]
    text = paragraph[:content][0][:text]
    
    assert_equal markdown, text
  end
  
  def test_complex_jira_template_conversion
    adf = @formatter.convert_markdown_to_adf(sample_markdown)
    
    assert_valid_adf_structure(adf)
    
    # Should have multiple sections
    assert adf[:content].length > 5
    
    # Should have headings of different levels
    headings = adf[:content].select { |item| item[:type] == 'heading' }
    assert headings.length >= 4
    
    # Should have bullet lists
    lists = adf[:content].select { |item| item[:type] == 'bulletList' }
    assert lists.length >= 2
  end
end