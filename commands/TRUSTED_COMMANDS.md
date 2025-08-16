# Trusted Commands Configuration for Autonomous Workflows

To enable truly autonomous (zero-prompt) execution, the following bash commands need to be added to your trusted commands list:

## Core Git Operations
```
Bash(git status:*)
Bash(git stash:*)
Bash(git checkout:*)
Bash(git branch:*)
Bash(git commit:*)
Bash(git diff:*)
Bash(git log:*)
Bash(git rebase:*)
```

## GitHub CLI Operations
```
Bash(gh pr create:*)
Bash(gh pr view:*)
Bash(gh pr list:*)
```

## Testing and Quality
```
Bash(testrbl:*)
Bash(rake:*)
Bash(bundle exec:*)
Bash(rubocop:*)
```

## Ruby Environment Management
```
Bash(gem install:*)
Bash(rbenv install:*)
Bash(rbenv local:*)
```

## File System Operations
```
Bash(mkdir:*)
Bash(rm:*)
Bash(touch:*)
```

## Search Operations
```
Bash(grep:*)
Bash(find:*)
Bash(rg:*)
```

## Complete Trusted Commands List

Add these to your Claude Code trusted commands configuration:

```
Bash(~/.claude/fetch_jira_ticket:*),
Bash(~/.claude/create_jira_ticket:*),
Bash(~/.claude/bin/create_jira_ticket:*),
Bash(~/.claude/bin/update_jira_ticket:*),
Bash(~/.claude/bin/fetch_jira_ticket:*),
Bash(ruby:*),
Bash(bundle:*),
Bash(rbenv:*),
Bash(brew:*),
Bash(git:*),
Bash(gh:*),
Bash(testrbl:*),
Bash(rake:*),
Bash(gem:*),
Bash(mkdir:*),
Bash(rm:*),
Bash(touch:*),
Bash(grep:*),
Bash(find:*),
Bash(rg:*),
Bash(rubocop:*),
Bash(ffmpeg:*),
Bash(whisper:*),
Bash(ffprobe:*),
Bash(afplay:*),
Bash(expect:*),
Bash(cat:*)
```

## Configuration Location

The trusted commands are likely configured in one of these locations:
1. Your Claude Code settings/config file
2. Environment variables
3. A `.claude-config` or similar configuration file
4. Built into your Claude Code session/profile

## Alternative Approach: Working Directory Trust

You may also need to configure trusted working directories. For autonomous workflows, these directories should be trusted:

```
/Users/abeckwith/.claude
/Users/abeckwith/Code/zendesk/zendesk
/tmp
```

## Testing Trusted Commands

To test if commands are properly trusted:
1. Start a new Claude Code session
2. Try running one of the autonomous commands
3. Verify no bash command approval prompts appear
4. If prompts still appear, the trusted commands list needs updating

## Implementation Notes

- Using `git:*` instead of individual git commands provides broader coverage
- The `*` wildcard allows for command arguments and flags
- Paths with `~/.claude/` should match your actual script locations
- Consider security implications of broad wildcards like `Bash(*:*)`
