# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Command Execution Workflow

**CRITICAL**: When asked to run a command or perform a task, ALWAYS follow this sequence:

1. **First**: Search for and read relevant command documentation in `~/.claude/commands/`
2. **Then**: Follow the documented workflow, steps, and guidelines from the command files
3. **Finally**: Execute scripts or tools with proper context and user input

Never run scripts blindly without first understanding the intended workflow from the command documentation.

## Workflow Execution Priority

**AGENT FIRST**: When the user provides comprehensive context or uses trigger words, ALWAYS prioritize agent-based workflows for maximum efficiency:

### 🚀 **Agent-First Triggers (Use Task Tool)**
When user input contains these patterns, immediately use the Task tool with general-purpose agent:

**Primary Triggers**:
- **"build"** / **"create"** / **"implement"** + comprehensive context
- **"deliver"** / **"complete"** / **"finish"** + outcome description
- **"fix"** / **"resolve"** / **"solve"** + problem description
- **"improve"** / **"optimize"** / **"enhance"** + target area
- **"remove the [fully rolled out|disabled] arturo feature"** + feature name

**Context Indicators (Use Agent When Present)**:
- Multiple requirements mentioned (priority, components, technical details)
- End-to-end outcomes described ("from X to Y", "ready for review/deployment")
- Business objectives stated ("increase performance", "user experience")
- Timeline implications ("urgent", "high priority", "for next release")

**Agent Workflow Examples**:
```bash
# User: "Build user authentication with OAuth2, high priority, affects login component"
→ Task: general-purpose agent "Build user authentication with OAuth2: create JIRA story, implement OAuth2 integration with Google/GitHub, add session management, comprehensive testing, deliver PR ready for review. High priority affecting login component."

# User: "Fix the email parsing bug in attachments"
→ Task: general-purpose agent "Fix email parsing bug in attachments: investigate issue, create JIRA ticket, implement fix, add test coverage, create PR ready for review."

# User: "Remove the fully rolled out arturo feature new_email_parser"
→ Task: general-purpose agent "Remove fully rolled out Arturo feature flag 'new_email_parser': analyze codebase usage, create JIRA ticket, implement removal, update tests, create PR ready for review."

# User: "Remove the disabled arturo feature experimental_attachment_preview"
→ Task: general-purpose agent "Remove disabled Arturo feature flag 'experimental_attachment_preview': analyze codebase usage, create JIRA ticket, implement removal, clean up unused code, update tests, create PR ready for review."
```

### ⚡ **Autonomous Command Fallback**
Use autonomous commands when agent approach isn't suitable but good context exists:
- `/jira:autonomous:create` - When full ticket context provided but simple creation needed
- `/jira:autonomous:implement` - When ticket ID given with clear scope
- `/jira:autonomous:update` - When all update requirements specified
- `/zendesk:autonomous:remove_arturo` - When flag status and context provided

### 📋 **Interactive Command Fallback**
Use interactive commands when minimal context or exploration needed:
- `/jira:create` - When user says "create a ticket" without details
- `/jira:implement` - When exploration of ticket requirements needed
- `/jira:update` - When user asks "update this ticket" without specifics
- `/zendesk:remove_arturo` - When flag status or impact unclear

### 🎯 **Decision Matrix**:
| User Input | Approach | Rationale |
|------------|----------|-----------|
| "Build user auth with OAuth2, high priority, affects login" | **Agent** | Trigger word "build" + comprehensive context |
| "Fix email parsing bug in attachments" | **Agent** | Trigger word "fix" + clear problem |
| "Create a story for user auth with OAuth2, high priority" | **Agent** | Multiple requirements + end-to-end outcome |
| "Implement TALK-123" | **Autonomous** | Clear ticket ID, routine workflow |
| "Create a ticket" | **Interactive** | Minimal context, needs exploration |
| "Help me work on this ticket" | **Interactive** | Vague request, needs guidance |

### 🔑 **Magic Trigger Words for Instant Agent Execution**:
- **"Build me..."** - Instant agent for feature development
- **"Fix the..."** - Instant agent for problem resolution
- **"Deliver..."** - Instant agent for end-to-end outcomes
- **"Complete..."** - Instant agent for finishing workflows
- **"Optimize..."** - Instant agent for improvements
- **"Remove rolled out arturo feature..."** - Instant agent for feature flag removal
- **"Remove the disabled arturo feature..."** - Instant agent for feature flag cleanup

**EFFICIENCY PRINCIPLE**: Agent-first maximizes throughput and minimizes interaction. Always choose the highest level of automation the context supports.

## Development Environment Setup

### Ruby Environment
- Check Ruby version matches `.ruby-version` with `rbenv local`
- If version mismatch: `brew upgrade ruby-build && rbenv install [version]`
- After new Ruby install (in `~/Code/zendesk/zendesk/` project only): `gem install mysql2 -v '0.5.6' -- --with-mysql-config=$(brew --prefix mysql)/bin/mysql_config --with-ldflags="-L$(brew --prefix zstd)/lib -L$(brew --prefix openssl)/lib" --with-cppflags=-I$(brew --prefix openssl)/include`
- Install Solargraph: `gem install solargraph`
- Update dependencies: `bundle install`

### Testing
- Run Ruby test files directly: `ruby script_name.rb`
- Run specific tests: `testrbl components/email/test/path/to/test_test.rb`
- Always run `bundle install` successfully before running tests (unless this was performed in a previous step)

## Git Workflow Best Practices

### Squashing Commits
When you need to squash a new commit into an existing commit on a branch:

**Option 1: Fixup commit (preferred for single additional commit)**
```bash
# Make your changes and commit with --fixup
git add .
git commit --fixup <original-commit-hash>
git rebase -i --autosquash <base-branch>
```

**Option 2: Interactive rebase**
```bash
# Make your changes and commit normally
git add .
git commit -m "Additional changes"
git rebase -i HEAD~2  # or however many commits to squash
# In the editor, change 'pick' to 'squash' for commits to merge
```

**IMPORTANT**: Never use `git commit --amend --reset-author` when squashing into someone else's commit - this changes the original author. Only use `--reset-author` when you are the original author and want to update the timestamp.

## Architecture Overview

### JIRA Integration System
This repository implements a comprehensive JIRA workflow automation system with three core components:

#### 1. Ticket Creation Pipeline
- **Entry Point**: `/jira_create story|task` command
- **Template System**: Uses `templates/jira_ticket_v3.md` as base template
- **Script**: `~/.claude/bin/create_jira_ticket` (Ruby)
- **Core Logic**: `lib/jira/ticket_creator.rb`
- **Markdown Processing**: `lib/jira/markdown_formatter.rb` converts markdown to Atlassian Document Format (ADF)

#### 2. Implementation Workflow
- **Entry Point**: `/jira_implement TICKET-ID` command
- **Script**: `~/.claude/bin/fetch_jira_ticket` (Ruby)
- **Core Logic**: `lib/jira/ticket_fetcher.rb`
- **Workflow**: Fetches ticket details, creates branches, sets up development environment

#### 4. Ticket Management
- **Script**: `~/.claude/bin/update_jira_ticket` (Ruby)
- **Core Logic**: `lib/jira/ticket_updater.rb`
- **Capabilities**: Status transitions, assignee changes, sprint assignment, description updates

### Markdown to ADF Conversion
- **Primary System**: Enhanced local conversion (no external API dependencies)  
- **Fallback Architecture**: Handles API failures gracefully
- **Supported Features**: Headers, bold/italic text, inline code, links, nested bullet lists
- **Template Structure**: Metadata extraction, section parsing, structured content building
- **ADF Validation**: Built-in validation using official Atlassian JSON schema
  - Automatic validation in ticket creation and updates
  - Standalone validation tool: `~/.claude/bin/validate_adf`
  - Schema cached locally with automatic updates

### Arturo Feature Flag Removal
- **Entry Point**: `/zendesk_remove_arturo flag_name` command
- **Workflow**: Creates JIRA ticket, analyzes codebase, removes flag references, creates PR
- **Flag Types**: Handles fully rolled out (100%) and fully disabled (0%) flags
- **Implementation**:
  - Rolled out flags: Remove check, keep enabled code path
  - Disabled flags: Remove entire conditional block
- **Validation**: Test suite execution, RuboCop checks, reference verification

### Command Architecture
- **Command Definition**: YAML frontmatter with allowed tools and workflow steps
- **Guided Workflows**: Step-by-step processes with validation and error handling
- **Template Generation**: Dynamic content creation based on user input

## Environment Variables
```bash
export JIRA_ACCESS_TOKEN="your_jira_api_token"
export JIRA_EMAIL="your_email@zendesk.com"
```

## Key Patterns and Conventions

### Branch Naming
Format: `{TICKET-ID-UPPERCASE}/{short-summary}`
Example: `TALK-359/new_string_to_external_number_popup`

### JIRA Ticket Structure
- **Projects**: Default to "EM" (Email Processing)
- **GitHub Links**: Always use permalinks with base URL `https://github.com/zendesk/`
- **Line References**: Format as `filename.rb#L123-L145`
- **Template Sections**: Project Information, Description, References and Notes, Acceptance Criteria

### Git Workflow Integration
- Automatic stash/commit handling for uncommitted changes
- Branch creation and switching
- Pull request creation using GitHub CLI with template population

### Error Handling Strategy
- Graceful API fallbacks (markdown conversion, component permissions)
- Comprehensive error messages with troubleshooting guidance
- Validation at multiple pipeline stages

## Development Commands

### JIRA Operations
```bash
# Create tickets
/jira_create story story_attributes.md
/jira_create task task_attributes.md

# Implement tickets
/jira_implement TICKET-123

# Remove Arturo feature flags
/zendesk_remove_arturo flag_name

# Update tickets
~/.claude/bin/update_jira_ticket EM-1234 --ready-for-review
~/.claude/bin/update_jira_ticket EM-1234 --assignee me --status "In Progress" --sprint current
~/.claude/bin/update_jira_ticket EM-1234 --status "To Do" --sprint current
~/.claude/bin/update_jira_ticket EM-1234 --description /path/to/description.md
```

**JIRA Description Format**: Always use `~/.claude/templates/jira_ticket_v3.md` template format for JIRA description markdown files.

### Testing and Development
```bash
# Install dependencies
bundle install

# Run test suite
~/.claude/bin/test
bundle exec ruby test/run_tests.rb

# Validate ADF format
~/.claude/bin/validate_adf description.md
~/.claude/bin/validate_adf description.md --quiet

# Ruby/bundle management
bundle install
bundle update

# Code style
bundle exec rubocop
```

### Voice Mode Setup
Voice-enabled Claude Code allows speech-to-text interaction using Ctrl+V.

**Requirements:**
```bash
# Install required tools
brew install expect ffmpeg openai-whisper

# Alternative: Install Whisper via pip if not using homebrew-supplied python
pip install openai-whisper
```

**Usage:**
```bash
# Launch voice-enabled Claude Code
~/.claude/bin/claude-code-voice

# In the session:
# - Use Ctrl+V to trigger voice recording
# - Speak your command/question
# - Text is automatically transcribed and sent to Claude
```

**Shell Alias Setup:** Add to your `~/.zshrc` or shell config:
```bash
# Voice-enabled Claude Code alias
alias ccode="~/.claude/bin/claude-code-voice"

# Then use:
ccode
```

**Configuration:** Edit voice settings in `~/.claude/bin/claude-code-voice`:
- `mic`: Audio input device (default ":1")
- `model`: Whisper model size ("tiny", "small", "medium", "large")
- `voice_secs`: Recording duration (4 seconds, or 0 for manual stop with 'q')

## Critical Implementation Notes

### Before Code Changes
1. Ensure Docker for Mac is running if needed
2. Verify `bundle install` completion
3. Check Ruby version compatibility
4. Run relevant test suites

### Pull Request Workflow
1. Use template from `.github/PULL_REQUEST_TEMPLATE.md`
2. Title format: `[TICKET-ID] Ticket Title`
3. Include risk assessment and testing steps
4. Reference ticket ID in description
5. Squash commits before merge

### JIRA-Specific Considerations
- ADF conversion is local-only (no external API dependencies)
- Component permissions may be restricted (automatic retry without components)
- Sprint assignment only works with Scrum boards (Kanban detection included)
- Account ID resolution uses hardcoded mappings for performance
- Favor brief/terse writing style when describing the problem and proposed solution.
- Always reference code/class/module/file names in `code` styling, unless it is a URL/permalink

### Arturo Feature Flag Management
- Feature flags should only be removed when fully rolled out (100%) or fully disabled (0%)
- **Rolled Out Flags**: Remove flag check, preserve enabled behavior
- **Disabled Flags**: Remove entire conditional block and related code
- Always verify flag status before removal
- Update tests to remove flag-specific test cases
- Use codebase search to ensure complete removal of all references