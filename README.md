# Claude JIRA Integration Tools

A comprehensive Ruby toolkit for JIRA workflow automation, ticket management, and Atlassian Document Format (ADF) processing.

## Structure

### JIRA Integration Scripts
- `create_jira_ticket` - Ruby script to create JIRA tickets from markdown templates
- `fetch_jira_ticket` - Script to fetch JIRA ticket details  
- `update_jira_ticket` - Ruby script to update JIRA ticket status, assignee, and sprint assignment
- `jira_template.md` - Template for creating JIRA tickets

### Claude Commands

#### JIRA Commands (`commands/jira/`)
- `create.md` - Create JIRA tickets (story or task) using guided prompts
- `implement.md` - Fetch JIRA ticket details and set up development workflow

#### Zendesk Commands (`commands/zendesk/`)  
- `remove_arturo.md` - Remove fully rolled out Arturo feature flags with JIRA ticket creation

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

## Usage

### Creating JIRA Tickets
```bash
# Create a story or task interactively
/jira_create story
/jira_create task

# Create ticket from template file directly
./create_jira_ticket story my_ticket.md
./create_jira_ticket task my_ticket.md
```

### Implementing JIRA Tickets
```bash
# Set up development workflow for a ticket
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
# Remove a fully rolled out feature flag
/zendesk_remove_arturo flag_name
```

## Templates

The `jira_template.md` provides a standardized format for JIRA tickets including:
- Metadata (project, priority, labels, components, assignee)
- Description with background and proposed solution
- References and notes section
- Acceptance criteria

## Features

- **Automated Workflow**: Seamless integration between JIRA ticket creation and development setup
- **Branch Management**: Automatic branch creation and git workflow handling
- **Template-based**: Consistent ticket formatting using markdown templates
- **Smart Updates**: Update ticket status, assignee, and sprint assignment
- **Feature Flag Cleanup**: Automated removal of rolled-out Arturo feature flags
- **PR Integration**: Automatic pull request creation with proper templates

## Contributing

When adding new commands:
1. Follow the existing command structure with YAML frontmatter
2. Include comprehensive workflow steps
3. Add error handling and success criteria
4. Update this README with usage examples
