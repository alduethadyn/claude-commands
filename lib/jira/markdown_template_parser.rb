#!/usr/bin/env ruby

module Jira
  # Common module for parsing JIRA ticket markdown templates
  # Used by both TicketCreator and TicketUpdater for consistent parsing
  module MarkdownTemplateParser

    # Parse a markdown template and extract all ticket information
    # Returns a hash with metadata and structured content
    def self.parse_template(content, issue_type = nil)
      lines = content.split("\n")

      # Metadata fields
      title = ""
      project_key = "EM" # Default project, can be overridden in template
      priority = "Medium"
      labels = []
      components = []
      assignee = nil
      parent_issue = nil

      # Sections for structured content
      description_section = []
      references_section = []
      acceptance_criteria_section = []

      current_section = nil
      in_metadata = true

      lines.each do |line|
        original_line = line
        line = line.strip

        # Extract title from first # or ## header
        if (line.start_with?('# ') || line.start_with?('## ')) && title.empty?
          title = line.gsub(/^(\#{1,2})\s*/, '').strip
          next
        end

        # Handle metadata fields (before first ## section or in ### Project Information)
        if in_metadata || current_section == 'project information'
          if line.start_with?('**Project:**')
            value = extract_metadata_value(line)
            project_key = value unless value.nil? || value.include?('PROJECT_KEY')
          elsif line.start_with?('**Priority:**')
            value = extract_metadata_value(line)
            priority = value unless value.nil? || value.include?('|')
          elsif line.start_with?('**Labels:**')
            value = extract_metadata_value(line)
            if value && !value.include?('label1')
              labels = value.split(',').map(&:strip)
            end
          elsif line.start_with?('**Components:**')
            value = extract_metadata_value(line)
            if value && !value.include?('component1')
              components = value.split(',').map(&:strip)
            end
          elsif line.start_with?('**Assignee:**')
            value = extract_metadata_value(line)
            if value && !value.include?('user@example.com') && !value.include?('ENV[') && !value.include?('Unassigned')
              assignee = value
            else
              assignee = nil # Default to Unassigned
            end
          elsif line.start_with?('**Parent:**')
            value = extract_metadata_value(line)
            if value && !value.empty? && !value.include?('PARENT-KEY')
              parent_issue = value
            end
          elsif line.start_with?('## ')
            in_metadata = false
            current_section = line[3..-1].strip.downcase
          elsif line.start_with?('### ')
            current_section = line[4..-1].strip.downcase
          end
        else
          # Handle content sections
          if line.start_with?('## ')
            current_section = line[3..-1].strip.downcase
          elsif line.start_with?('### ')
            # Keep subsection headers in the content
            case current_section
            when 'description'
              description_section << original_line
            when 'references and notes'
              references_section << original_line
            when 'acceptance criteria'
              acceptance_criteria_section << original_line
            end
          else
            # Add content to appropriate section
            case current_section
            when 'description'
              description_section << original_line
            when 'references and notes'
              references_section << original_line
            when 'acceptance criteria'
              acceptance_criteria_section << original_line
            end
          end
        end
      end

      {
        # Metadata
        title: title,
        project_key: project_key,
        priority: priority,
        labels: labels,
        components: components,
        assignee: assignee,
        parent_issue: parent_issue,

        # Content sections
        description_section: description_section,
        references_section: references_section,
        acceptance_criteria_section: acceptance_criteria_section
      }
    end

    # Build a full description from parsed sections
    # This is used for the JIRA description field
    def self.build_full_description(description_section, references_section, acceptance_criteria_section)
      sections = []

      unless description_section.empty?
        sections << description_section.join("\n")
      end

      unless references_section.empty?
        sections << "## References and Notes\n\n" + references_section.join("\n")
      end

      unless acceptance_criteria_section.empty?
        sections << "## Acceptance Criteria\n\n" + acceptance_criteria_section.join("\n")
      end

      sections.join("\n\n")
    end

    # Parse template and return just the description content (convenience method)
    def self.parse_for_description(content)
      parsed = parse_template(content)
      build_full_description(
        parsed[:description_section],
        parsed[:references_section], 
        parsed[:acceptance_criteria_section]
      )
    end

    private

    # Extract value from metadata line like "**Field:** value"
    def self.extract_metadata_value(line)
      return nil unless line.include?(':')

      value = line.split(':', 2)[1].strip
      return nil if value.empty?

      # Remove markdown formatting
      value = value.gsub(/^\*\*\s*/, '').gsub(/\s*\*\*$/, '')

      value
    end
  end
end