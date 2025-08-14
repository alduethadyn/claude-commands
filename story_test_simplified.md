## Test Simplified Markdown Formatter

### Project Information
**Project:** EM  
**Priority:** Low  
**Labels:**   
**Parent:**   
**Assignee:** 

## Description

This ticket tests the simplified markdown formatter that consolidates all local ADF conversion into a single file. The API-based conversion and legacy fallback have been removed.

**Update Test**: This line was added to test the update functionality with the simplified formatter.

Key changes in the refactor:
- Consolidated `markdown_formatter_enhanced.rb` into main `markdown_formatter.rb`
- Removed API-based conversion from `markdown_formatter_old.rb`
- Removed legacy `v1.rb` fallback formatter
- Simplified to local-only conversion with no external dependencies

## References and Notes

### Code Context
* [lib/jira/markdown_formatter.rb#L1-L50](https://github.com/zendesk/support/blob/main/lib/jira/markdown_formatter.rb#L1-L50) - Simplified single-file formatter

### Testing Considerations
* Verify **bold** and *italic* text formatting works
* Test `inline code` formatting
* Check nested bullet lists:
  * Top level item
    * Nested item
    * Another nested item
* Verify [link formatting](https://example.com) works

## Acceptance Criteria

* Markdown formatter converts text to proper ADF format
* All inline formatting (bold, italic, code, links) works correctly
* Nested bullet lists render properly in JIRA
* Headers display with correct hierarchy
* No external API dependencies required