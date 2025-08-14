---
description: "Update a JIRA ticket with a brief description using guided prompts"
allowed-tools: ["Bash", "Read", "Edit", "Write"]
---

# JIRA Ticket Update Workflow

You are helping update an existing JIRA ticket. Follow this workflow:

## Arguments
- **Issue Number**: $ARGUMENTS (e.g., EM-9452)

## Workflow Steps

1. **Validate Issue Number**
   - Ensure the argument follows the correct format (PROJECT-NUMBER)
   - If invalid, display usage information and exit

2. **Fetch Current Ticket Information**
   - Use the fetch_jira_ticket script to get current ticket details:
     - `~/.claude/fetch_jira_ticket $ARGUMENTS`
   - Display the current ticket summary and description for context

3. **Gather Update Requirements**
   - Prompt the user for a brief description of what they want to update
   - Ask clarifying questions to understand:
     - What specific aspect needs updating (summary, description, status, assignee, etc.)
     - The nature of the change or addition
     - Any new requirements or information to add
     - Whether this is a status change, content update, or field modification

4. **Determine Update Type**
   Based on user input, identify what needs to be updated:
   - **Description/Content Update**: Update the ticket description with new information
   - **Status Change**: Transition the ticket to a new status
   - **Assignee Change**: Reassign the ticket to someone else
   - **Field Updates**: Update priority, labels, sprint assignment, etc.
   - **Comment Addition**: Add a new comment with updates

5. **Execute Update**
   - For status/assignee/field changes, use the update_jira_ticket script:
     - `~/.claude/update_jira_ticket $ARGUMENTS --status "New Status"`
     - `~/.claude/update_jira_ticket $ARGUMENTS --assignee user@example.com`
     - `~/.claude/update_jira_ticket $ARGUMENTS --ready-for-review`
   - For description updates, fetch current content, modify it, and update via API
   - For comment additions, add a comment with the update information

6. **Confirm Changes**
   - Display what was updated
   - Show the ticket URL for verification
   - Suggest next steps if applicable

## Prompt Templates

### Initial Update Prompt
"Please provide a brief description of what you want to update on ticket $ARGUMENTS:
- What aspect of the ticket needs to be changed?
- Are you updating the description, changing status, reassigning, or adding information?
- What specific changes do you want to make?"

### Clarification Prompts
- "Do you want to change the ticket status? If so, to what status?"
- "Should this ticket be reassigned to someone else?"
- "Are you adding new information to the description or completely replacing it?"
- "Do you want to add a comment to document this update?"

## Common Update Scenarios

### Status Updates
- Move to "In Progress" when starting work
- Move to "Ready for Review" when work is complete
- Move to "Done" when review is approved

### Content Updates
- Add new requirements or acceptance criteria
- Update technical approach or implementation details
- Add references to related work or documentation

### Assignment Updates
- Assign to yourself: `--assignee me`
- Assign to specific person: `--assignee user@example.com`
- Combined with status: `--assignee me --status "In Progress"`

## Success Criteria

✅ Issue number validated and ticket exists
✅ Current ticket information retrieved and displayed
✅ User requirements gathered through guided prompts
✅ Appropriate update method determined
✅ Update executed successfully
✅ Confirmation provided with ticket URL

## Error Handling

- Invalid issue number format: Display usage and exit
- Ticket not found: Inform user and suggest checking the ticket number
- Permission denied: Inform user they may not have edit access
- Update script failure: Display error details and suggest troubleshooting
- Network/API errors: Provide clear error messages and suggest retry

---

**Usage**: `/jira_update EM-9452`

Update an existing JIRA ticket $ARGUMENTS using guided prompts to determine what changes to make.