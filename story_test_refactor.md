## Test Refactor - Common Parser Functionality

### Project Information
**Project:** EM  
**Priority:** Low  
**Labels:** testing, refactor  
**Parent:**   
**Assignee:** 

## Description

This is a test story to verify that the refactored common parser works correctly for both create and update operations. The refactoring extracted duplicate parsing logic into a shared `MarkdownTemplateParser` module.

## References and Notes

### Code Context
* [lib/jira/markdown_template_parser.rb#L1-L50](https://github.com/zendesk/support/blob/main/lib/jira/markdown_template_parser.rb#L1-L50) - New common parser module
* [lib/jira/ticket_creator.rb#L90-L110](https://github.com/zendesk/support/blob/main/lib/jira/ticket_creator.rb#L90-L110) - Refactored create logic

### Testing Considerations
* Verify create functionality with common parser
* Verify update functionality with common parser
* Ensure consistent parsing behavior between create and update

## Acceptance Criteria

* Create operation parses markdown template correctly using common parser
* Update operation parses markdown template correctly using common parser
* Both operations produce identical description formatting
* No regression in existing functionality