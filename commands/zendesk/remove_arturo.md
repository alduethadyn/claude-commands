---
description: "Create a JIRA ticket for removing a fully rolled out/disabled Arturo feature flag and open a PR"
allowed-tools: ["Bash", "Read", "Edit", "Write", "TodoWrite", "Grep", "Glob"]
---

# Remove Arturo Feature Flag Workflow

You are helping remove a fully rolled out or disabled Arturo feature flag. This workflow combines JIRA ticket creation with implementation.

## Arguments
- **Feature Flag Name**: $ARGUMENTS (the name of the Arturo feature flag to remove)

## Workflow Steps

### Phase 1: Validation and Setup

1. **Validate Feature Flag**
   - Search the codebase for references to the feature flag: `$ARGUMENTS`
   - Verify the flag exists in the system
   - Check current rollout status if possible
   - If no references found, inform user and exit

2. **Gather Context**
   - Ask user to confirm:
     - Is this flag fully rolled out (100%) or fully disabled (0%)?
     - Any specific areas or components this affects?
     - Any special considerations for removal?
   - Search codebase for all occurrences to understand scope

### Phase 2: JIRA Ticket Creation

3. **Generate Ticket Content**
   - Create ticket title: "Remove fully rolled out Arturo feature flag: {flag_name}"
   - Use "task" type for the ticket
   - Follow jira_template_v2.md format with proper nested bullets:
     - **Background**: Explain that the feature flag has been fully rolled out/disabled and can be safely removed
     - **Proposed Solution**: Remove flag references and cleanup related code
     - **References and Notes** section with proper nested bullets:
       - *Code Context:* List file locations where flag is referenced
       - *Related Tickets/Docs:* Any related documentation
       - *Testing Considerations:* Note test updates needed
       - *Rollout/Deployment:* Explain this removes the Arturo flag
     - **Acceptance Criteria** with proper nested bullets:
       - All references to `{flag_name}` are removed from the codebase
       - Default behavior is maintained (for rolled out flags) or removed (for disabled flags)
       - Related test updates are made
       - Arturo feature flag is removed from admin interface
       - Code cleanup of any flag-related conditional logic

4. **Create JIRA Ticket**
   - Write populated template to temporary file (the assignee should default to me unless otherwise specified)
   - Execute `~/.claude/create_jira_ticket task temp_file.md`
   - Capture ticket ID for implementation phase
   - Mark ticket as To Do and move into current sprint: `~/.claude/update_jira_ticket {TICKET-ID} --status "To Do" --sprint current`

### Phase 3: Implementation Setup

5. **Set Up Development Environment**
   - Check current git branch and handle uncommitted changes
   - Ensure the main or master branch up-to-date
   - Check status of local tooling stack:
     - Check that the current ruby version `rbenv local` matches the `.ruby-version`, if not run `brew upgrade ruby-build` and then `rbenv install [version from .ruby-version]`
     - Ensure the bundle is up-to-date by running `bundle` (if a new ruby was installed, run `gem install mysql2 -v '0.5.6' -- --with-mysql-config=$(brew --prefix mysql)/bin/mysql_config --with-ldflags="-L$(brew --prefix zstd)/lib -L$(brew --prefix openssl)/lib" --with-cppflags=-I$(brew --prefix openssl)/include` first)
     - If a new ruby was installed, run `gem install solargraph`
   - Create new branch: `{TICKET-ID}/remove-{flag_name}-flag`
   - Set up todo list for implementation tasks:
     - Analyze all flag references found in codebase
     - Remove flag checks and simplify conditional logic
     - Update related tests
     - Cleanup any flag-related helper methods
     - Run test suites to ensure no regressions
     - Create pull request

6. **Code Analysis and Planning**
   - Use Grep/Glob to find all references to the flag
   - Categorize references:
     - Feature flag checks (`account.arturo_feature_enabled?(:flag_name)`)
     - Test fixtures and factory references
     - Configuration or migration files
     - Documentation references
   - Create detailed implementation plan based on findings
   - Mark ticket In Progress: `~/.claude/update_jira_ticket {TICKET-ID} --status "In Progress"`

### Phase 4: Implementation

7. **Execute Removal**
   - Start with first todo item
   - For each flag reference:
     - **Fully Rolled Out Flags**: Remove flag check and keep the "enabled" code path
     - **Fully Disabled Flags**: Remove flag check and the entire conditional block
   - Update tests to remove flag-related test cases
   - Clean up any helper methods that are no longer needed
   - Ensure all changes maintain expected behavior

8. **Validation**
   - Run relevant test suites using commands from CLAUDE.md
   - Run RuboCop: `rake rubocop:changed`
   - Verify no flag references remain: search for flag name again
   - Test application behavior in key areas

### Phase 5: Pull Request Creation

9. **Create Pull Request**
   - Commit all changes with message: `{TICKET-ID} Remove fully rolled out Arturo feature flag: {flag_name}`
   - Push branch to remote
   - Use GitHub PR template (using the project's .github/PULL_REQUEST_TEMPLATE.md if present) with:
     - Title: `[{TICKET-ID}] Remove fully rolled out Arturo feature flag: {flag_name}`
     - Description explaining the removal and verification steps
     - Reference to JIRA ticket
     - List of areas affected and testing performed
   - Create PR: `gh pr create --title "[TICKET-ID] Remove fully rolled out Arturo feature flag: {flag_name}" --body "$(cat pr_template)"`
   - Mark ticket ready for review: `~/.claude/update_jira_ticket {TICKET-ID} --status Review`

10. **Post-Creation Tasks**
    - Update todo list to mark items complete
    - Provide summary of:
      - JIRA ticket created and marked ready for review
      - Files modified
      - PR created and ready for review
      - Next steps (code review, testing, deployment)

## Implementation Guidelines

### For Fully Rolled Out Flags (100%):
```ruby
# Before
if account.arturo_feature_enabled?(:new_feature)
  new_implementation()
else
  old_implementation()
end

# After
new_implementation()
```

### For Fully Disabled Flags (0%):
```ruby
# Before  
if account.arturo_feature_enabled?(:experimental_feature)
  experimental_code()
end

# After
# Remove entire block
```

### Test Updates:
- Remove test cases that specifically test flag behavior
- Update factories/fixtures that set flag state
- Ensure remaining tests still pass with simplified code

## Error Handling

- **Flag not found**: Search didn't return results - confirm flag name with user
- **Unclear rollout status**: Ask user to verify flag status in admin interface
- **Complex removal**: If flag removal involves significant code changes, break into multiple todos
- **Test failures**: Address failing tests before proceeding with PR creation
- **Git conflicts**: Handle merge conflicts if branch is behind main

## Success Criteria

✅ Feature flag validated and found in codebase
✅ User confirmed rollout status and removal plan  
✅ JIRA ticket created with comprehensive details
✅ Development branch created and ready
✅ All flag references identified and categorized
✅ Flag removal implemented correctly based on rollout status
✅ Tests updated and passing
✅ Code quality checks passed
✅ Pull request created with proper documentation
✅ Ready for code review and deployment

---

**Usage**: `/zendesk_remove_arturo flag_name`

Remove the fully rolled out or disabled Arturo feature flag `$ARGUMENTS` by creating a JIRA ticket and opening a pull request with the removal implementation.