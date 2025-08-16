---
description: "Autonomously implement a JIRA ticket from fetch to PR creation with comprehensive planning"
allowed-tools: ["Bash", "Read", "Edit", "TodoWrite", "Grep", "Glob"]
---

# Autonomous JIRA Implementation Workflow

You are implementing a JIRA ticket with full autonomy. This command executes the complete workflow from ticket fetch to PR creation with minimal user interaction.

## Arguments
- **Ticket ID**: $ARGUMENTS (e.g., TALK-123)

## Expected Context (Optional in initial prompt)
If provided, use this context to enhance the implementation:
- Specific implementation approach preferences
- Areas of codebase to focus on or avoid
- Testing requirements beyond standard
- Any architectural constraints

## Autonomous Workflow Steps

### Phase 1: Setup and Planning
1. **Fetch and Analyze Ticket**
   - Execute: `~/.claude/bin/fetch_jira_ticket $ARGUMENTS`
   - Parse ticket title, status, type, and description
   - Create comprehensive todo list based on ticket requirements

2. **Prepare Development Environment**
   - Check current git branch and handle uncommitted changes automatically
   - Stash changes if needed: `git stash push -m "WIP: $ARGUMENTS - auto-stash"`
   - Verify Ruby version and update if needed
   - Run bundle install and handle any mysql2/dependency issues
   - Install Solargraph if new Ruby version installed

3. **Create Implementation Branch**
   - Generate branch name: `{ticket-id-uppercase}/{auto-generated-summary}`
   - Create and switch: `git checkout -b {branch-name}`

### Phase 2: Implementation Analysis
4. **Analyze Codebase Context**
   - Use Grep/Glob to find relevant files and patterns
   - Identify existing implementations and patterns to follow
   - Create detailed implementation strategy
   - Plan test file locations and requirements

5. **Execute Implementation**
   - Follow the todo list systematically
   - Make all necessary code changes
   - Update or create tests as needed
   - Ensure code follows existing patterns and conventions

### Phase 3: Validation and PR Creation
6. **Comprehensive Testing**
   - Run appropriate test suites automatically
   - Execute RuboCop and fix any style issues
   - Verify all functionality works as expected

7. **Create Pull Request Automatically**
   - Commit changes with proper message format
   - Push branch to remote
   - Generate PR using GitHub template
   - Fill template with ticket information
   - Create PR: `gh pr create --title "[TICKET-ID] Title" --body "$(cat template_content)"`

8. **Final Updates**
   - Update JIRA ticket status to "Ready for Review"
   - Provide comprehensive summary of changes made
   - List all files modified and tests updated

## Implementation Strategy

### Autonomous Decision Making:
- **Branch Naming**: Auto-generate based on ticket title
- **Code Patterns**: Follow existing codebase conventions automatically
- **Test Strategy**: Create/update tests following existing patterns
- **Commit Messages**: Format as "{TICKET-ID} {ticket title}"

### Error Recovery:
- **Test Failures**: Fix automatically where possible, flag complex issues
- **Dependency Issues**: Handle common Ruby/bundle problems automatically
- **Merge Conflicts**: Attempt auto-resolution, escalate if complex

## Success Criteria

✅ Ticket fetched and analyzed
✅ Development environment prepared
✅ Implementation branch created
✅ Code changes implemented following patterns
✅ Tests created/updated and passing
✅ Pull request created with proper template
✅ JIRA ticket updated to Ready for Review
✅ Comprehensive summary provided

## Escalation Points

The workflow will pause and request user input only for:
- Complex merge conflicts requiring manual resolution
- Test failures that can't be automatically fixed
- Architectural decisions that significantly impact the codebase
- Security-sensitive changes requiring explicit approval

## Error Handling

- **Invalid ticket ID**: Clear error message and format examples
- **Ticket fetch failure**: Network/permission troubleshooting
- **Environment setup failure**: Specific remediation steps
- **Implementation blockers**: Clear description of issue and suggested resolution
- **PR creation failure**: GitHub CLI troubleshooting

---

**Usage**: `/jira_implement_auto TALK-123`

Autonomously implement JIRA ticket $ARGUMENTS from start to PR creation with minimal user interaction required.