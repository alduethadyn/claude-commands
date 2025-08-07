---
description: "Create a JIRA ticket (story or task) using guided prompts and template generation"
allowed-tools: ["Bash", "Read", "Edit", "Write"]
---

# JIRA Ticket Creation Workflow

You are helping create a new JIRA ticket. Follow this workflow:

## Arguments
- **Issue Type**: $ARGUMENTS (either "story" or "task")

## Workflow Steps

1. **Validate Issue Type**
   - Ensure the argument is either "story" or "task"
   - If invalid, display usage information and exit

2. **Gather User Requirements**
   - Prompt the user for a brief description of the desired outcome
   - Ask clarifying questions to understand:
     - The problem or need being addressed
     - The expected user or system behavior
     - Any specific technical requirements or constraints
     - Priority level (High, Medium, Low)
     - Any relevant components or labels

3. **Analyze Template Structure**
   - Read the JIRA template from `~/.claude/jira_template.md`
   - Understand the required sections and metadata fields

4. **Generate Ticket Content**
   - Create a meaningful ticket title based on the user's description
   - Fill in the metadata fields:
     - Project: Use "EM" as default (can be adjusted)
     - Priority: Based on user input or default to "Medium"
     - Labels: Generate relevant labels based on description
     - Components: Suggest components if applicable
     - Assignee: Use ENV['JIRA_EMAIL'] default
   - Generate Description section:
     - Background: Explain the context and problem
     - Proposed Solution: High-level technical approach
   - Create References and Notes section with placeholders for:
     - Code Context (to be filled during implementation)
     - Related Tickets/Docs
     - Testing Considerations
     - Rollout/Deployment notes
   - Generate Acceptance Criteria:
     - Create specific, testable conditions
     - Include feature flag considerations
     - Add test coverage expectations

5. **Create Ticket File**
   - Generate a filename based on ticket type and summary
   - Example: `story_user_authentication.md` or `task_refactor_email_parser.md`
   - Write the populated template to the file
   - Display the file location to the user

6. **Execute Ticket Creation**
   - Prompt user to review the generated content
   - Ask for confirmation to create the JIRA ticket
   - If confirmed, execute the create_jira_ticket script:
     - `~/.claude/create_jira_ticket $ARGUMENTS generated_file.md`
   - Display the results and ticket URL

7. **Cleanup and Next Steps**
   - Ask if the user wants to keep the generated markdown file
   - Suggest next steps (like starting implementation workflow)

## Content Generation Guidelines

- **Title**: Should be concise but descriptive, following the pattern:
  - Story: "As a [user type], I want [functionality] so that [benefit]" or simplified "[Feature/Enhancement] description"
  - Task: "[Technical task] description" focusing on the technical work

- **Background**: Explain why this work is needed, what problem it solves, or what improvement it provides

- **Proposed Solution**: High-level approach without deep implementation details

- **Acceptance Criteria**:
  - Use clear, measurable conditions
  - Include feature flag considerations (assume Arturo feature flags)
  - Focus on observable outcomes and behaviors
  - Include test coverage as a standard expectation

## Prompt Templates

### Initial Description Prompt
"Please provide a brief description of what you want this {story/task} to accomplish. Include:
- What problem are you trying to solve or what feature do you want to add?
- Who is the intended user or what system will benefit?
- Any specific requirements or constraints I should know about?"

### Clarification Prompts
- "What priority should this be? (High/Medium/Low)"
- "Are there specific components or areas of the codebase this relates to?"
- "Are there any related tickets or documentation I should reference?"
- "What would successful completion look like from a user perspective?"

## Success Criteria

✅ Issue type validated (story or task)
✅ User requirements gathered through guided prompts
✅ Template analyzed and understood
✅ Meaningful ticket content generated
✅ Markdown file created with populated template
✅ JIRA ticket created successfully (if user confirms)
✅ Next steps provided to user

## Error Handling

- Invalid issue type: Display usage and exit
- Missing environment variables: Inform user of JIRA setup requirements
- Template file not found: Error with path to expected template location
- Creation script failure: Display error details and suggest troubleshooting

---

**Usage**: `/jira_create story` or `/jira_create task`

Create a new JIRA ticket of type $ARGUMENTS using guided prompts and template generation.
