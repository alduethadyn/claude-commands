#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/jira/adf_validator'

class TestADFValidator < Minitest::Test
  include TestHelper

  def setup
    @validator = Jira::ADFValidator

    # Ensure schema is available for testing
    return if File.exist?(Jira::ADFValidator::SCHEMA_CACHE_PATH)

    @validator.send(:download_schema)
  end

  def test_validates_simple_valid_adf
    valid_adf = {
      'type' => 'doc',
      'version' => 1,
      'content' => [
        {
          'type' => 'paragraph',
          'content' => [
            {
              'type' => 'text',
              'text' => 'Hello world'
            }
          ]
        }
      ]
    }

    assert @validator.validate(valid_adf)
  end

  def test_validates_heading_adf
    heading_adf = {
      'type' => 'doc',
      'version' => 1,
      'content' => [
        {
          'type' => 'heading',
          'attrs' => { 'level' => 1 },
          'content' => [
            {
              'type' => 'text',
              'text' => 'Test Heading'
            }
          ]
        }
      ]
    }

    assert @validator.validate(heading_adf)
  end

  def test_validates_bullet_list_adf
    list_adf = {
      'type' => 'doc',
      'version' => 1,
      'content' => [
        {
          'type' => 'bulletList',
          'content' => [
            {
              'type' => 'listItem',
              'content' => [
                {
                  'type' => 'paragraph',
                  'content' => [
                    {
                      'type' => 'text',
                      'text' => 'List item'
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }

    assert @validator.validate(list_adf)
  end

  def test_validates_text_with_marks
    marked_text_adf = {
      'type' => 'doc',
      'version' => 1,
      'content' => [
        {
          'type' => 'paragraph',
          'content' => [
            {
              'type' => 'text',
              'text' => 'Bold text',
              'marks' => [
                { 'type' => 'strong' }
              ]
            }
          ]
        }
      ]
    }

    assert @validator.validate(marked_text_adf)
  end

  def test_validates_link_adf
    link_adf = {
      'type' => 'doc',
      'version' => 1,
      'content' => [
        {
          'type' => 'paragraph',
          'content' => [
            {
              'type' => 'text',
              'text' => 'Link text',
              'marks' => [
                {
                  'type' => 'link',
                  'attrs' => { 'href' => 'https://example.com' }
                }
              ]
            }
          ]
        }
      ]
    }

    assert @validator.validate(link_adf)
  end

  def test_rejects_invalid_document_type
    invalid_adf = {
      'type' => 'invalid_type',
      'version' => 1,
      'content' => []
    }

    refute @validator.validate(invalid_adf)
  end

  def test_rejects_missing_required_fields
    invalid_adf = {
      'type' => 'doc'
      # Missing version and content
    }

    refute @validator.validate(invalid_adf)
  end

  def test_rejects_invalid_heading_level
    invalid_heading = {
      'type' => 'doc',
      'version' => 1,
      'content' => [
        {
          'type' => 'heading',
          'attrs' => { 'level' => 99 }, # Invalid level
          'content' => [
            { 'type' => 'text', 'text' => 'Invalid heading' }
          ]
        }
      ]
    }

    refute @validator.validate(invalid_heading)
  end

  def test_validate_with_details_returns_hash
    valid_adf = {
      'type' => 'doc',
      'version' => 1,
      'content' => [
        {
          'type' => 'paragraph',
          'content' => [{ 'type' => 'text', 'text' => 'Test' }]
        }
      ]
    }

    result = @validator.validate_with_details(valid_adf)

    assert result.is_a?(Hash)
    assert result.key?(:valid)
    assert result.key?(:errors)
    assert_equal true, result[:valid]
    assert_equal [], result[:errors]
  end

  def test_validate_with_details_returns_errors
    invalid_adf = { 'type' => 'invalid' }

    result = @validator.validate_with_details(invalid_adf)

    assert_equal false, result[:valid]
    assert result[:errors].is_a?(Array)
    assert result[:errors].length.positive?
  end

  def test_validate_markdown_file_with_valid_content
    temp_file = create_temp_markdown(sample_markdown, 'valid_test.md')

    begin
      result = @validator.validate_markdown_file(temp_file, verbose: false)
      assert result
    ensure
      cleanup_temp_files(temp_file)
    end
  end

  def test_validate_markdown_file_with_empty_content
    temp_file = create_temp_markdown('', 'empty_test.md')

    begin
      result = @validator.validate_markdown_file(temp_file, verbose: false)
      assert result # Empty content should still be valid ADF
    ensure
      cleanup_temp_files(temp_file)
    end
  end

  def test_schema_caching_mechanism
    # Test that schema gets cached (only test if cache doesn't exist)
    cache_path = @validator::SCHEMA_CACHE_PATH

    # Only test download if cache doesn't exist
    unless File.exist?(cache_path)
      # First validation should download schema
      valid_adf = {
        'type' => 'doc',
        'version' => 1,
        'content' => []
      }

      @validator.validate(valid_adf)
      assert File.exist?(cache_path)
    end

    # Schema should be valid JSON (whether downloaded or cached)
    assert File.exist?(cache_path), 'Schema cache should exist'
    schema_content = File.read(cache_path)
    parsed_schema = JSON.parse(schema_content)
    assert parsed_schema.is_a?(Hash)
    assert parsed_schema.key?('$schema')
  end

  def test_handles_network_failure_gracefully
    # This test would be more complex to implement properly
    # as it requires mocking network calls
    # For now, just ensure the validator doesn't crash with existing cache

    cache_path = @validator::SCHEMA_CACHE_PATH
    assert File.exist?(cache_path), 'Schema cache should exist for this test'

    valid_adf = {
      'type' => 'doc',
      'version' => 1,
      'content' => []
    }

    # Should work even if network is down (using cached schema)
    assert @validator.validate(valid_adf)
  end
end
