---
description: "Fetch JIRA ticket details and set up development workflow with branch creation"
allowed-tools: ["Bash", "Read", "Edit", "TodoWrite"]
---

# JIRA Implementation Workflow

You are helping implement a JIRA ticket. Follow this workflow:

## Arguments
- **Ticket ID**: $ARGUMENTS (e.g., TALK-123)

## Workflow Steps

1. **Fetch Ticket Details**
   - Use the `~/.claude/bin/fetch_jira_ticket $ARGUMENTS` command to get ticket information
   - Parse the ticket title, status, type, and description
   - Create a todo list to track the implementation steps

2. **Check Current Branch**
   - Get the current git branch name
   - Check if it contains the ticket ID (case-insensitive)
   - If the branch is already appropriate, continue on current branch

3. **Handle Local Changes** (if branch switch needed)
   - Check for uncommitted changes with `git status --porcelain`
   - If changes exist:
     - Ask user preference: stash, temporary commit, or abort
     - Stash: `git stash push -m "WIP: $ARGUMENTS - temporary stash"`
     - Temp commit: `git add . && git commit -m "WIP: $ARGUMENTS - temporary commit"`

4. **Create New Branch** (if needed)
   - Generate branch name: `{ticket-id-uppercase}/{short-summary}`
   - Example: `TALK-359/new_string_to_external_number_popup`
   - Create and switch: `git checkout -b {branch-name}`

5. **Set Up Implementation**
   - Create comprehensive todo list based on ticket requirements
   - Check status of local tooling stack:
     - Check that the current ruby version `rbenv local` matches the `.ruby-version`, if not run `brew upgrade ruby-build` and then `rbenv install [version from .ruby-version]`
     - Ensure the bundle is up-to-date by running `bundle` (if a new ruby was installed, run `gem install mysql2 -v '0.5.6' -- --with-mysql-config=$(brew --prefix mysql)/bin/mysql_config --with-ldflags="-L$(brew --prefix zstd)/lib -L$(brew --prefix openssl)/lib" --with-cppflags=-I$(brew --prefix openssl)/include` first)
     - If a new ruby was installed, run `gem install solargraph`
   - Identify relevant files and test files that need changes
   - Plan the implementation approach
   - Mark first task as in_progress

6. **Verify changes**
   - Ask user to start Docker for Mac if not running
   - Ensure `bundle install` has completed successfully before running tests
   - Run tests with `testrbl components/email/test/path/to/test_test.rb`

7. **Create Pull Request** (after implementation is complete)
   - Ensure all changes are committed and pushed to remote branch. The commit message should not mention Claude.
   - Use the PR template from `.github/PULL_REQUEST_TEMPLATE.md`
   - Fill in template with ticket information:
     - Set title as: `[TICKET-ID] Ticket Title`
     - Fill "What" section with ticket description/summary
     - Set appropriate risk level based on changes
     - Add ticket ID to References section
     - Include steps to reproduce/test the changes
   - Create PR using: `gh pr create --title "[TICKET-ID] Title" --body "$(cat template_content)"`

8. **Prompt for any additional changes from PR feedback**
   - Always rebase and squash commits into a single commit in the PR, updating the commit message if necessary
   - Update the PR description only if major implementation details changed

## Implementation Guidelines

- Follow the codebase conventions described in CLAUDE.md
- Use existing patterns and libraries found in the codebase
- Run appropriate test commands before committing
- Create meaningful commit messages referencing the ticket ID
- After implementation is complete, create a pull request using the GitHub PR template

## Success Criteria

✅ Ticket details fetched and understood
✅ Appropriate branch created or confirmed
✅ Local changes properly handled
✅ Todo list created with implementation plan
✅ Ready to begin implementation
✅ Pull request created using template (after implementation)

---

**Usage**: `/jira_implement TALK-123`

Start implementing JIRA ticket $ARGUMENTS following the workflow above.
