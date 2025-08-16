---
description: "Autonomously remove Arturo feature flag with JIRA ticket creation and complete PR workflow"
allowed-tools: ["Bash", "Read", "Edit", "Write", "TodoWrite", "Grep", "Glob"]
---

# Autonomous Arturo Feature Flag Removal Workflow

You are removing an Arturo feature flag with full autonomy. This command expects the flag rollout status and executes the complete workflow from JIRA creation to PR merge-ready state.

## Arguments
- **Feature Flag Name**: $ARGUMENTS (the Arturo feature flag to remove)

## Required Context (Expected in initial prompt)
The user should provide:
- **Rollout Status**: "fully rolled out" (100%) or "fully disabled" (0%)
- **Affected Areas**: Components or systems this flag impacts (if known)
- **Special Considerations**: Any unique aspects of this flag removal

## Autonomous Workflow Steps

### Phase 1: Validation and Analysis
1. **Comprehensive Flag Analysis**
   - Search entire codebase for all flag references
   - Categorize references by type (checks, tests, config, docs)
   - Validate flag exists and determine removal complexity
   - Create detailed scope assessment

2. **Auto-Generate JIRA Ticket**
   - Create ticket title: "Remove fully rolled out Arturo feature flag: {flag_name}"
   - Use comprehensive template with all discovered flag usage
   - Set appropriate priority and assignee automatically
   - Execute: `~/.claude/bin/create_jira_ticket task auto_generated_file.md`
   - Immediately move to Sprint: `~/.claude/bin/update_jira_ticket {TICKET-ID} --status "To Do" --sprint current`

### Phase 2: Environment Setup
3. **Prepare Development Environment**
   - Check Ruby version and update if needed
   - Run bundle install with dependency handling
   - Handle mysql2 installation if new Ruby version
   - Install Solargraph if needed
   - Create branch: `{TICKET-ID}/remove-{flag_name}-flag`
   - Update ticket: `~/.claude/bin/update_jira_ticket {TICKET-ID} --status "In Progress"`

### Phase 3: Implementation
4. **Execute Flag Removal Automatically**
   - **For Fully Rolled Out Flags (100%)**:
     - Remove flag checks, keep enabled code path
     - Simplify conditional logic
     - Preserve functionality while removing flag references
   
   - **For Fully Disabled Flags (0%)**:
     - Remove flag checks and entire conditional blocks
     - Clean up unused code paths
     - Remove related helper methods if unused

5. **Update Tests Comprehensively**
   - Remove flag-specific test cases
   - Update factories and fixtures
   - Ensure remaining tests pass with simplified code
   - Add any missing test coverage for preserved functionality

### Phase 4: Validation and PR Creation
6. **Comprehensive Validation**
   - Run full test suite automatically
   - Execute RuboCop and fix style issues
   - Verify no flag references remain in codebase
   - Test key application flows affected by changes

7. **Create PR Automatically**
   - Commit with message: `{TICKET-ID} Remove fully rolled out Arturo feature flag: {flag_name}`
   - Push branch to remote
   - Generate PR using project template
   - Fill template with comprehensive details:
     - Flag removal rationale
     - Areas affected
     - Testing performed
     - Verification steps
   - Create PR: `gh pr create --title "[{TICKET-ID}] Remove fully rolled out Arturo feature flag: {flag_name}" --body "$(cat pr_template)"`

8. **Final Status Updates**
   - Update JIRA: `~/.claude/bin/update_jira_ticket {TICKET-ID} --status "Ready for Review"`
   - Provide comprehensive summary:
     - JIRA ticket created and ready for review
     - Complete list of files modified
     - PR created and ready for review
     - Testing results and verification performed

## Implementation Logic

### Fully Rolled Out Flag Removal:
```ruby
# Before
if account.arturo_feature_enabled?(:new_feature)
  new_implementation()
else
  old_implementation()
end

# After (Automatic)
new_implementation()
```

### Fully Disabled Flag Removal:
```ruby
# Before
if account.arturo_feature_enabled?(:experimental_feature)
  experimental_code()
end

# After (Automatic)
# Entire block removed automatically
```

### Smart Test Updates:
- Remove flag-toggling test cases
- Preserve functionality tests
- Update factory states
- Ensure coverage maintained

## Autonomous Decision Points

- **Code Path Selection**: Automatically choose correct path based on rollout status
- **Test Strategy**: Intelligently update tests while preserving coverage
- **Cleanup Scope**: Determine which helper methods to remove based on usage
- **Commit Granularity**: Single commit with all changes for clean history

## Success Criteria

✅ Feature flag validated and fully analyzed
✅ JIRA ticket created with comprehensive scope
✅ Development environment prepared
✅ Flag removal implemented correctly based on rollout status
✅ All tests updated and passing
✅ Code quality checks passed
✅ Pull request created with detailed documentation
✅ JIRA ticket marked ready for review
✅ Complete summary provided

## Escalation Points

Workflow pauses for user input only for:
- **Ambiguous rollout status**: Cannot determine if rolled out or disabled
- **Complex flag logic**: Nested or interdependent flag checks requiring decision
- **Test failures**: Unexpected test breakage that can't be auto-resolved
- **Security implications**: Flag removal affects security-sensitive code

## Error Recovery

- **Flag not found**: Clear error with search results
- **Rollout status unclear**: Request explicit confirmation
- **Complex dependencies**: Break into subtasks with user guidance
- **Test suite failures**: Detailed failure analysis and suggested fixes
- **PR creation issues**: GitHub CLI troubleshooting steps

---

**Usage**: `/zendesk_remove_arturo_auto flag_name "This flag is fully rolled out at 100% and affects the email processing pipeline and user notification system. No special considerations."`

Autonomously remove Arturo feature flag $ARGUMENTS with JIRA ticket creation and complete PR workflow based on the comprehensive context provided.