---
description: "Autonomously create a JIRA ticket with comprehensive context provided upfront"
allowed-tools: ["Bash", "Read", "Edit", "Write", "TodoWrite"]
---

# Autonomous JIRA Ticket Creation Workflow

You are helping create a new JIRA ticket with full autonomy. This command expects comprehensive context upfront and executes the entire workflow with minimal user interaction.

## Arguments
- **Issue Type**: $ARGUMENTS (either "story" or "task")

## Required Context (Expected in initial prompt)
The user should provide:
- Brief description of the desired outcome
- Problem or need being addressed
- Expected user or system behavior
- Technical requirements or constraints
- Priority level (High, Medium, Low) - defaults to Medium if not specified
- Any relevant components, labels, or assignee preferences

## Autonomous Workflow Steps

1. **Validate and Parse Input**
   - Ensure issue type is either "story" or "task"
   - Extract all provided context from user's comprehensive description
   - Set reasonable defaults for any missing information

2. **Generate Complete Ticket Content**
   - Create ticket title based on description
   - Fill Project Information section:
     - Project: "EM" (default)
     - Priority: From context or "Medium"
     - Labels: From context or defaults
     - Assignee: ENV['JIRA_EMAIL'] or from context
   - Generate Description section with full context
   - Create References and Notes with placeholders
   - Generate specific, testable Acceptance Criteria

3. **Create and Execute Immediately**
   - Generate filename: `autonomous_{type}_{timestamp}.md`
   - Write populated template to file
   - Automatically execute: `~/.claude/bin/create_jira_ticket $ARGUMENTS generated_file.md`
   - Display results and ticket URL

4. **Clean Up**
   - Remove temporary markdown file unless creation failed
   - Provide ticket URL and summary
   - Suggest next steps (implementation workflow)

## Content Generation Guidelines

- **Title Format**:
  - Story: "[Feature/Enhancement] description" or user story format
  - Task: "[Technical task] description"

- **Writing Style**: Clear, simple, direct. Avoid flowery language. Be terse and factual.

- **Auto-Generated Sections**:
  - Background: Why this work is needed
  - Proposed Solution: High-level approach
  - Acceptance Criteria: Clear, measurable conditions with feature flag considerations

## Success Criteria

✅ Issue type validated and context parsed
✅ Complete ticket content generated autonomously
✅ JIRA ticket created successfully
✅ Results provided with ticket URL
✅ Cleanup completed

## Error Handling

- Invalid issue type: Display usage and exit
- Insufficient context: Request specific missing information
- Creation script failure: Display error and retain markdown file for debugging
- Missing environment variables: Clear setup instructions

---

**Usage**: `/jira_create_auto story "Create user authentication system with OAuth2 support. Users need to log in with Google/GitHub. High priority. Affects login component and user management. Should include session management and security considerations."`

Create a JIRA ticket of type $ARGUMENTS autonomously using the comprehensive context provided in the initial prompt.