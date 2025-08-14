#!/usr/bin/env ruby

require_relative 'markdown_formatter_enhanced'

module Jira
  # Main Markdown formatter optimized for JIRA ADF conversion
  # Uses enhanced local conversion (JIRA doesn't provide markdown-to-ADF API)
  class MarkdownFormatter
    # Convert markdown text to ADF using enhanced local conversion
    # @param markdown_text [String] The markdown content to convert
    # @return [Hash] ADF document structure
    def self.convert_markdown_to_adf(markdown_text, **options)
      MarkdownFormatterEnhanced.convert_markdown_to_adf(markdown_text)
    end

    # Primary conversion method with enhanced local processing
    # @param markdown_text [String] The markdown content to convert
    # @return [Hash] ADF document structure
    def self.convert_with_fallback(markdown_text, **options)
      # No fallback needed - enhanced local conversion is the primary method
      convert_markdown_to_adf(markdown_text)
    end

    # Test method for compatibility (always returns true for local conversion)
    def self.test_connection(**options)
      true
    end

    # Setup instructions (simplified for local conversion)
    def self.setup_instructions
      <<~INSTRUCTIONS
        Jira::MarkdownFormatter uses enhanced local conversion to ADF format.
        
        No API credentials required - conversion is handled locally with 
        high-quality markdown parsing optimized for JIRA's ADF structure.
        
        Supported markdown features:
        - Headers (# ## ### #### ##### ######)
        - Bold text (**bold**)
        - Italic text (*italic*)
        - Inline code (`code`)
        - Links ([text](url))
        - Bullet lists with nesting (*, indented with 2 spaces per level)
        
        Usage:
        Jira::MarkdownFormatter.convert_markdown_to_adf(markdown_text)
      INSTRUCTIONS
    end
  end
end