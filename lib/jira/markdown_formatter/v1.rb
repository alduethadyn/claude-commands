#!/usr/bin/env ruby

module Jira
  class MarkdownFormatter
    # V1 Markdown formatter - local conversion without API
    # This is the original implementation used as fallback
    module V1
      def self.convert_markdown_to_adf(markdown_text)
        return { type: "doc", version: 1, content: [] } if markdown_text.strip.empty?

        lines = markdown_text.split("\n")
        content = []
        current_paragraph = []
        current_list = []
        in_list = false

        lines.each do |line|
          if line.strip.empty?
            # Empty line - end current paragraph if it exists, but continue list
            if !current_paragraph.empty?
              content << create_paragraph(current_paragraph.join(" "))
              current_paragraph = []
            end
          elsif line.start_with?('## ')
            # Heading level 2 - end any current content
            content << create_paragraph(current_paragraph.join(" ")) unless current_paragraph.empty?
            content << create_bullet_list(current_list) unless current_list.empty?
            current_paragraph = []
            current_list = []
            in_list = false
            content << create_heading(line[3..-1].strip, 2)
          elsif line.start_with?('### ')
            # Heading level 3 - end any current content
            content << create_paragraph(current_paragraph.join(" ")) unless current_paragraph.empty?
            content << create_bullet_list(current_list) unless current_list.empty?
            current_paragraph = []
            current_list = []
            in_list = false
            content << create_heading(line[4..-1].strip, 3)
          elsif line.match(/^\s*\*\s+/)
            # List item (any level)
            content << create_paragraph(current_paragraph.join(" ")) unless current_paragraph.empty?
            current_paragraph = []

            # Calculate indent level based on leading spaces before *
            leading_spaces = line.match(/^(\s*)/)[1].length
            indent_level = leading_spaces / 2 # 2 spaces per indent level
            
            # Extract list text after * and any whitespace
            list_text = line.sub(/^\s*\*\s*/, '').strip

            if !in_list
              in_list = true
            end
            current_list << { text: list_text, indent: indent_level }
          else
            # Regular text - end list if we were in one, add to current paragraph
            if in_list && !current_list.empty?
              content << create_bullet_list(current_list)
              current_list = []
              in_list = false
            end
            current_paragraph << line.strip
          end
        end

        # Don't forget the last content
        content << create_paragraph(current_paragraph.join(" ")) unless current_paragraph.empty?
        content << create_bullet_list(current_list) unless current_list.empty?

        {
          type: "doc",
          version: 1,
          content: content.reject { |item| item.nil? }
        }
      end

      def self.create_heading(text, level)
        {
          type: "heading",
          attrs: { level: level },
          content: [
            {
              type: "text",
              text: text
            }
          ]
        }
      end

      def self.create_paragraph(text)
        return nil if text.strip.empty?

        {
          type: "paragraph",
          content: parse_inline_formatting(text)
        }
      end

      def self.create_bullet_list(items)
        return nil if items.empty?

        # If items is an array of hashes with text and indent, handle nested structure
        if items.first.is_a?(Hash) && items.first.key?(:text)
          {
            type: "bulletList",
            content: build_nested_list_items(items)
          }
        else
          # Fallback for simple items (array of formatted text content)
          {
            type: "bulletList",
            content: items.map do |item|
              {
                type: "listItem",
                content: [
                  {
                    type: "paragraph",
                    content: item
                  }
                ]
              }
            end
          }
        end
      end

      def self.build_nested_list_items(items)
        result = []
        stack = []

        items.each do |item|
          text = item[:text]
          indent = item[:indent] || 0

          # Create the list item with proper inline formatting
          list_item = {
            type: "listItem",
            content: [
              {
                type: "paragraph",
                content: parse_inline_formatting(text)
              }
            ]
          }

          if indent == 0
            # Top level item
            result << list_item
            stack = [{ item: list_item, level: 0 }]
          else
            # Find the appropriate parent for this indent level
            while stack.length > 0 && stack.last[:level] >= indent
              stack.pop
            end

            if stack.length > 0
              parent = stack.last[:item]
              
              # Check if parent already has a nested bulletList
              nested_list = parent[:content].find { |content| content[:type] == "bulletList" }
              
              if nested_list.nil?
                # Create new nested bulletList
                nested_list = {
                  type: "bulletList",
                  content: []
                }
                parent[:content] << nested_list
              end
              
              # Add item to nested list
              nested_list[:content] << list_item
              stack << { item: list_item, level: indent }
            else
              # Fallback: add to top level if no parent found
              result << list_item
              stack = [{ item: list_item, level: indent }]
            end
          end
        end

        result
      end

      def self.parse_inline_formatting(text)
        # Enhanced parsing for bold, italic, code, and links
        content = []
        remaining_text = text.strip

        while !remaining_text.empty?
          # Check for code blocks `code`
          if match = remaining_text.match(/`([^`]+)`/)
            # Add text before the code
            if match.begin(0) > 0
              content.concat(parse_basic_formatting(remaining_text[0...match.begin(0)]))
            end

            # Add the code text
            content << {
              type: "text",
              text: match[1],
              marks: [{ type: "code" }]
            }

            remaining_text = remaining_text[match.end(0)..-1]
          # Check for markdown links [text](url)
          elsif match = remaining_text.match(/\[([^\]]+)\]\(([^)]+)\)/)
            # Add text before the link
            if match.begin(0) > 0
              content.concat(parse_basic_formatting(remaining_text[0...match.begin(0)]))
            end

            # Add the link
            content << {
              type: "text",
              text: match[1],
              marks: [
                {
                  type: "link",
                  attrs: { href: match[2] }
                }
              ]
            }

            remaining_text = remaining_text[match.end(0)..-1]
          else
            # Parse remaining text for bold/italic
            content.concat(parse_basic_formatting(remaining_text))
            break
          end
        end

        content
      end

      def self.parse_basic_formatting(text)
        # Parse bold and italic formatting
        content = []
        remaining_text = text

        while !remaining_text.empty?
          # Check for bold text **text**
          if match = remaining_text.match(/\*\*([^*]+)\*\*/)
            # Add text before the bold
            if match.begin(0) > 0
              content << { type: "text", text: remaining_text[0...match.begin(0)] }
            end

            # Add the bold text
            content << {
              type: "text",
              text: match[1],
              marks: [{ type: "strong" }]
            }

            remaining_text = remaining_text[match.end(0)..-1]
          # Check for italic text *text* (but not **)
          elsif match = remaining_text.match(/(?<!\*)\*([^*]+)\*(?!\*)/)
            # Add text before the italic
            if match.begin(0) > 0
              content << { type: "text", text: remaining_text[0...match.begin(0)] }
            end

            # Add the italic text
            content << {
              type: "text",
              text: match[1],
              marks: [{ type: "em" }]
            }

            remaining_text = remaining_text[match.end(0)..-1]
          else
            # No special formatting found, add the rest as plain text
            content << { type: "text", text: remaining_text }
            break
          end
        end

        content
      end
    end
  end
end