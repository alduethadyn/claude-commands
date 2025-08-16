---
description: "Autonomously update a JIRA ticket with comprehensive changes based on provided context"
allowed-tools: ["Bash", "Read", "Edit", "Write", "TodoWrite"]
---

# Autonomous JIRA Ticket Update Workflow

You are updating a JIRA ticket with full autonomy. This command expects comprehensive update context upfront and executes all changes automatically.

## Arguments
- **Issue Number**: $ARGUMENTS (e.g., EM-9452)

## Required Context (Expected in initial prompt)
The user should provide comprehensive update details:
- What aspect needs updating (description, status, assignee, etc.)
- Specific changes or additions to make
- New status if applicable
- Assignee changes if applicable
- Additional content or requirements to add
- Priority or field changes if needed

## Autonomous Workflow Steps

1. **Fetch Current State**
   - Execute: `~/.claude/bin/fetch_jira_ticket $ARGUMENTS`
   - Parse current ticket details for context
   - Validate ticket exists and is accessible

2. **Parse Update Requirements**
   - Extract all update intentions from provided context
   - Categorize updates by type:
     - Status changes
     - Assignee modifications
     - Description/content updates
     - Field updates (priority, labels, sprint)
     - Comment additions

3. **Execute All Updates Automatically**
   - **Status Changes**: `~/.claude/bin/update_jira_ticket $ARGUMENTS --status "New Status"`
   - **Assignee Changes**: `~/.claude/bin/update_jira_ticket $ARGUMENTS --assignee user@example.com`
   - **Combined Updates**: Chain multiple flags together
   - **Description Updates**: Fetch, modify, and update via API
   - **Sprint Assignment**: `~/.claude/bin/update_jira_ticket $ARGUMENTS --sprint current`

4. **Verify and Report**
   - Confirm all updates completed successfully
   - Display updated ticket URL
   - Provide summary of all changes made
   - Suggest follow-up actions if applicable

## Update Patterns

### Common Autonomous Updates:
- **Ready for Review**: `--status "Ready for Review"`
- **Start Work**: `--assignee me --status "In Progress"`
- **Sprint Assignment**: `--status "To Do" --sprint current`
- **Complete Work**: `--status "Done"`

### Content Updates:
- Merge new requirements with existing description
- Add acceptance criteria or technical details
- Update references and links
- Append implementation notes

## Auto-Generated Content Style

- **Writing Style**: Clear, simple, direct language. Avoid flowery terms.
- **Content Merging**: Intelligently combine new content with existing
- **Formatting**: Maintain existing markdown structure and formatting
- **References**: Preserve and enhance existing links and code references

## Success Criteria

✅ Issue number validated and ticket retrieved
✅ Update requirements parsed from context
✅ All specified updates executed automatically
✅ Changes verified and confirmed
✅ Comprehensive update summary provided
✅ Ticket URL provided for verification

## Error Handling

- **Invalid issue number**: Clear format guidance
- **Ticket not found**: Verification steps
- **Permission denied**: Access troubleshooting
- **Update conflicts**: Automatic retry with different approach
- **API failures**: Fallback strategies and error reporting
- **Partial updates**: Complete what's possible, report what failed

## Advanced Features

### Smart Status Transitions:
- Auto-detect valid status transitions
- Suggest next logical status if requested status invalid
- Handle workflow-specific requirements

### Intelligent Content Merging:
- Preserve existing structure while adding new content
- Avoid duplication of similar information
- Maintain chronological order for updates

### Context-Aware Updates:
- Use ticket type and current status to inform update strategy
- Apply role-based defaults (assignee, priority, etc.)
- Suggest related updates based on context

---

**Usage**: `/jira_update_auto EM-9452 "Move to Ready for Review status, assign to me, add implementation notes about the new authentication flow and testing completed, update priority to High"`

Autonomously update JIRA ticket $ARGUMENTS with all changes specified in the comprehensive context provided.