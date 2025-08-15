#!/usr/bin/env ruby
# frozen_string_literal: true

module Jira
  # Markdown formatter for JIRA ADF conversion
  # Uses local conversion only (JIRA doesn't provide markdown-to-ADF API)
  class MarkdownFormatter
    # Convert markdown text to ADF using local conversion
    # @param markdown_text [String] The markdown content to convert
    # @return [Hash] ADF document structure
    def self.convert_markdown_to_adf(markdown_text, **_options)
      return { type: 'doc', version: 1, content: [] } if markdown_text.strip.empty?

      # Preprocess markdown for better conversion
      processed_markdown = preprocess_markdown(markdown_text)
      lines = processed_markdown.split("\n")

      content = []
      current_paragraph_lines = []
      current_list_items = []
      in_list = false

      lines.each do |line|
        if line.strip.empty?
          # Empty line - finalize current paragraph, but preserve list context
          finalize_paragraph(content, current_paragraph_lines) unless current_paragraph_lines.empty?
          current_paragraph_lines = []
        elsif line.match(/^(\#{1,6})\s+(.+)$/)
          # Header - finalize any current content
          finalize_paragraph(content, current_paragraph_lines) unless current_paragraph_lines.empty?
          finalize_list(content, current_list_items) unless current_list_items.empty?
          current_paragraph_lines = []
          current_list_items = []
          in_list = false

          level = ::Regexp.last_match(1).length
          text = ::Regexp.last_match(2).strip
          content << create_heading(text, level)

        elsif line.match(/^(\s*)\*\s+(.+)$/)
          # List item - finalize paragraph, add to list
          finalize_paragraph(content, current_paragraph_lines) unless current_paragraph_lines.empty?
          current_paragraph_lines = []

          indent_spaces = ::Regexp.last_match(1).length
          indent_level = indent_spaces / 2
          list_text = ::Regexp.last_match(2).strip

          current_list_items << { text: list_text, indent: indent_level }
          in_list = true
        else
          # Regular text line
          if in_list && !current_list_items.empty?
            # Finalize list before starting paragraph
            finalize_list(content, current_list_items)
            current_list_items = []
            in_list = false
          end

          current_paragraph_lines << line.strip unless line.strip.empty?
        end
      end

      # Finalize any remaining content
      finalize_paragraph(content, current_paragraph_lines) unless current_paragraph_lines.empty?
      finalize_list(content, current_list_items) unless current_list_items.empty?

      {
        type: 'doc',
        version: 1,
        content: content.compact
      }
    end

    # Primary conversion method (same as convert_markdown_to_adf)
    # @param markdown_text [String] The markdown content to convert
    # @return [Hash] ADF document structure
    def self.convert_with_fallback(markdown_text, **_options)
      convert_markdown_to_adf(markdown_text)
    end

    # Test method for compatibility (always returns true for local conversion)
    def self.test_connection(**_options)
      true
    end

    # Setup instructions (simplified for local conversion)
    def self.setup_instructions
      <<-INSTRUCTIONS
        Jira::MarkdownFormatter uses local conversion to ADF format.

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

    # Preprocess markdown for optimal conversion
    def self.preprocess_markdown(markdown_text)
      processed = markdown_text.dup

      # Normalize headers - ensure space after #
      processed = processed.gsub(/^(\#{1,6})([^#\s])/, '\1 \2')

      # Ensure proper spacing around headers
      processed = processed.gsub(/([^\n])\n(\#{1,6}\s)/, "\\1\n\n\\2")
      processed = processed.gsub(/(\#{1,6}\s.+)\n([^\n#])/, "\\1\n\n\\2")

      # Normalize list formatting
      processed = processed.gsub(/^(\s*)\*([^\s])/, '\1* \2')

      # Clean up excessive line breaks
      processed = processed.gsub(/\n{3,}/, "\n\n")

      processed.strip
    end

    def self.finalize_paragraph(content, paragraph_lines)
      return if paragraph_lines.empty?

      paragraph_text = paragraph_lines.join(' ').strip
      return if paragraph_text.empty?

      content << create_paragraph(paragraph_text)
    end

    def self.finalize_list(content, list_items)
      return if list_items.empty?

      content << create_nested_bullet_list(list_items)
    end

    def self.create_heading(text, level)
      {
        type: 'heading',
        attrs: { level: [level, 6].min }, # Cap at level 6
        content: parse_inline_text(text)
      }
    end

    def self.create_paragraph(text)
      {
        type: 'paragraph',
        content: parse_inline_text(text)
      }
    end

    def self.create_nested_bullet_list(items)
      {
        type: 'bulletList',
        content: build_nested_list_structure(items)
      }
    end

    def self.build_nested_list_structure(items)
      result = []
      stack = []

      items.each do |item|
        text = item[:text]
        indent = item[:indent] || 0

        list_item = {
          type: 'listItem',
          content: [
            {
              type: 'paragraph',
              content: parse_inline_text(text)
            }
          ]
        }

        if indent.zero?
          # Top level
          result << list_item
          stack = [{ item: list_item, level: 0 }]
        else
          # Find appropriate parent
          stack.pop while stack.length.positive? && stack.last[:level] >= indent

          if stack.length.positive?
            parent = stack.last[:item]

            # Find or create nested list in parent
            nested_list = parent[:content].find { |c| c[:type] == 'bulletList' }

            unless nested_list
              nested_list = {
                type: 'bulletList',
                content: []
              }
              parent[:content] << nested_list
            end

            nested_list[:content] << list_item
            stack << { item: list_item, level: indent }
          else
            # Fallback to top level
            result << list_item
            stack = [{ item: list_item, level: indent }]
          end
        end
      end

      result
    end

    def self.parse_inline_text(text)
      content = []
      remaining = text.strip

      until remaining.empty?
        # Handle code spans first `code`
        if (match = remaining.match(/`([^`]+)`/))
          # Add preceding text
          content.concat(parse_text_formatting(remaining[0...match.begin(0)])) if match.begin(0).positive?

          # Add code span
          content << {
            type: 'text',
            text: match[1],
            marks: [{ type: 'code' }]
          }

          remaining = remaining[match.end(0)..]

        # Handle links [text](url)
        elsif (match = remaining.match(/\[([^\]]+)\]\(([^)]+)\)/))
          # Add preceding text
          content.concat(parse_text_formatting(remaining[0...match.begin(0)])) if match.begin(0).positive?

          # Add link
          link_text = match[1]
          link_url = match[2]

          content << {
            type: 'text',
            text: link_text,
            marks: [
              {
                type: 'link',
                attrs: { href: link_url }
              }
            ]
          }

          remaining = remaining[match.end(0)..]

        else
          # Handle remaining text with formatting
          content.concat(parse_text_formatting(remaining))
          break
        end
      end

      content.empty? ? [{ type: 'text', text: text }] : content
    end

    def self.parse_text_formatting(text)
      content = []
      remaining = text

      until remaining.empty?
        # Bold text **text**
        if (match = remaining.match(/\*\*([^*]+)\*\*/))
          # Add preceding text
          content << { type: 'text', text: remaining[0...match.begin(0)] } if match.begin(0).positive?

          # Add bold text
          content << {
            type: 'text',
            text: match[1],
            marks: [{ type: 'strong' }]
          }

          remaining = remaining[match.end(0)..]

        # Italic text *text* (not part of **)
        elsif (match = remaining.match(/(?<!\*)\*([^*]+)\*(?!\*)/))
          # Add preceding text
          content << { type: 'text', text: remaining[0...match.begin(0)] } if match.begin(0).positive?

          # Add italic text
          content << {
            type: 'text',
            text: match[1],
            marks: [{ type: 'em' }]
          }

          remaining = remaining[match.end(0)..]

        else
          # No more formatting, add remaining text
          content << { type: 'text', text: remaining } unless remaining.empty?
          break
        end
      end

      content
    end
  end
end
