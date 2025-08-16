# Claude Zendesk Workflow Toolkit

A comprehensive Ruby toolkit for Zendesk development workflows, including JIRA integration, feature flag management, and automated development processes.

## Structure

### Core Components

#### JIRA Integration Scripts
- `create_jira_ticket` - Ruby script to create JIRA tickets from markdown templates
- `fetch_jira_ticket` - Script to fetch JIRA ticket details  
- `update_jira_ticket` - Ruby script to update JIRA ticket status, assignee, and sprint assignment
- `jira_template.md` - Template for creating JIRA tickets

#### Zendesk Workflow Automation
- Feature flag removal system with codebase analysis
- Automated pull request creation and testing
- Branch management and git workflow integration

### Claude Commands

#### JIRA Commands (`commands/jira/`)
- `create.md` - Create JIRA tickets (story or task) using guided prompts
- `implement.md` - **Read existing JIRA tickets and implement them** - fetches ticket details, creates branches, and sets up complete development workflow through pull request creation

#### Zendesk Commands (`commands/zendesk/`)  
- `remove_arturo.md` - Remove fully rolled out Arturo feature flags with automated JIRA ticket creation and code cleanup
- `autonomous/remove_arturo.md` - Autonomous feature flag removal with full workflow automation
- *More Zendesk-specific workflows coming soon*

## Quick Start

```bash
# Install dependencies
bundle install

# Run tests
~/.claude/bin/test

# Validate ADF documents
~/.claude/bin/validate_adf description.md
```

## Setup

### Prerequisites
- Ruby 3.4.5 (managed via rbenv)
- Bundler for dependency management
- JIRA API access configured
- GitHub CLI (`gh`) installed for PR creation

#### Voice Mode Additional Requirements
- `expect` - Script runner for interactive sessions
- `ffmpeg` - Audio recording and processing
- `whisper` - OpenAI speech recognition model
- `iTerm` - Terminal application (for focus management)

### Environment Variables
Set these environment variables for JIRA integration:
```bash
export JIRA_ACCESS_TOKEN="your_jira_api_token"
export JIRA_EMAIL="your_email@zendesk.com"
```

### Development Setup
```bash
# Install dependencies
bundle install

# Run test suite (no API calls)
bundle exec ruby test/run_tests.rb
```

#### Voice Mode Setup
```bash
# Install voice mode dependencies
brew install expect ffmpeg openai-whisper

# Alternative: Install Whisper via pip if not using homebrew-supplied python
pip install openai-whisper

# Launch voice-enabled Claude Code
~/.claude/bin/claude-code-voice
```

## Usage

### Magic Words for Instant Agent Execution

Claude Code supports "magic words" that trigger instant agent-based execution for maximum efficiency:

#### Primary Triggers
- **"Build me..."** - Instant agent for feature development
- **"Fix the..."** - Instant agent for problem resolution  
- **"Deliver..."** - Instant agent for end-to-end outcomes
- **"Complete..."** - Instant agent for finishing workflows
- **"Optimize..."** - Instant agent for improvements
- **"Remove rolled out arturo feature..."** - Instant agent for feature flag removal
- **"Remove the disabled arturo feature..."** - Instant agent for feature flag cleanup

#### Context Indicators (Trigger Agent Mode)
When your request includes these patterns, Claude will automatically use agent mode:
- Multiple requirements mentioned (priority, components, technical details)
- End-to-end outcomes described ("from X to Y", "ready for review/deployment")
- Business objectives stated ("increase performance", "user experience")
- Timeline implications ("urgent", "high priority", "for next release")

### Autonomous vs Interactive Commands

#### Autonomous Commands (Full Automation)
- `/jira:autonomous:create` - Create tickets with full context provided
- `/jira:autonomous:implement` - Implement tickets with clear scope
- `/jira:autonomous:update` - Update tickets with all requirements specified
- `/zendesk:autonomous:remove_arturo` - Remove feature flags with status provided

#### Interactive Commands (Guided Workflow)
- `/jira:create` - Create tickets with guided prompts
- `/jira:implement` - Implement with exploration of requirements
- `/jira:update` - Update with guided steps
- `/zendesk:remove_arturo` - Remove flags with status confirmation

### Creating JIRA Tickets
```bash
# Create a story or task interactively
/jira:create story
/jira:create task

# Create ticket from template file directly
./create_jira_ticket story my_ticket.md
./create_jira_ticket task my_ticket.md
```

### Implementing Existing JIRA Tickets
```bash
# Read existing JIRA ticket and set up complete development workflow
# (fetches ticket details, creates branch, guides implementation to PR)
/jira_implement TALK-123
```

### Updating JIRA Tickets
```bash
# Mark ticket ready for review
./update_jira_ticket EM-1234 --ready-for-review

# Assign to yourself and move to In Progress
./update_jira_ticket EM-1234 --assignee me --status "In Progress"

# Add to current sprint
./update_jira_ticket EM-1234 --assignee me --status "In Progress" --sprint current
```

### Removing Arturo Feature Flags
```bash
# Interactive feature flag removal (guided workflow)
/zendesk:remove_arturo flag_name

# Autonomous feature flag removal (full automation)
/zendesk:autonomous:remove_arturo flag_name
```

### Voice Mode Usage
```bash
# Launch voice-enabled Claude Code
~/.claude/bin/claude-code-voice

# Or use the recommended alias (add to ~/.zshrc):
alias ccode="~/.claude/bin/claude-code-voice"
ccode

# In the session:
# - Use Ctrl+V to trigger voice recording
# - Speak your command or question  
# - Text is automatically transcribed and sent to Claude
# - Configure recording duration and model in the script
```

## Templates

The `jira_template.md` provides a standardized format for JIRA tickets including:
- Metadata (project, priority, labels, components, assignee)
- Description with background and proposed solution
- References and notes section
- Acceptance criteria

## Features

### Agent-First Automation
- **Magic Words**: Instant agent execution with trigger words like "Build me...", "Fix the...", "Remove the disabled arturo feature..."
- **Context-Aware**: Automatically detects comprehensive context and switches to agent mode for maximum efficiency
- **Autonomous Commands**: Full automation with `/autonomous:` prefix for experienced users
- **Interactive Fallback**: Guided workflows when exploration is needed

### JIRA Integration
- **Ticket Creation**: Create well-formatted JIRA tickets from markdown templates
- **Implementation Workflow**: Read existing tickets and guide full development process
- **Smart Updates**: Update ticket status, assignee, and sprint assignment
- **Template-based**: Consistent ticket formatting using markdown templates
- **Dual Modes**: Both autonomous (full automation) and interactive (guided) workflows

### Zendesk Development Workflows
- **Feature Flag Cleanup**: Automated removal of rolled-out Arturo feature flags with codebase analysis
- **Branch Management**: Automatic branch creation and git workflow handling  
- **PR Integration**: Automatic pull request creation with proper templates
- **Test Integration**: Automated test running and validation
- **Context Intelligence**: Automatically determines rollout status and implementation strategy

### Growing Ecosystem
This toolkit is designed to expand with more Zendesk-specific development workflows, providing a comprehensive automation suite optimized for both agent-driven efficiency and interactive guidance.

## Contributing

When adding new commands:
1. Follow the existing command structure with YAML frontmatter
2. Include comprehensive workflow steps
3. Add error handling and success criteria
4. Update this README with usage examples
