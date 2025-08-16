# Claude Code Commands

This directory contains structured workflows for common development tasks, organized into two complementary approaches:

## Directory Structure

```
~/.claude/commands/
├── jira/
│   ├── create.md                    # /jira:create
│   ├── implement.md                 # /jira:implement
│   ├── update.md                    # /jira:update
│   └── autonomous/
│       ├── create.md                # /jira:autonomous:create
│       ├── implement.md             # /jira:autonomous:implement
│       └── update.md                # /jira:autonomous:update
├── zendesk/
│   ├── remove_arturo.md             # /zendesk:remove_arturo
│   └── autonomous/
│       └── remove_arturo.md         # /zendesk:autonomous:remove_arturo
└── README.md                        # This file
```

## Command Types

### Interactive Commands (Base Commands)
- **Purpose**: Guided, educational workflows with step-by-step prompts
- **Best For**: Learning, exploration, complex scenarios, first-time usage
- **Approach**: Progressive information gathering with decision points
- **Speed**: Slower but thorough with full explanations
- **Examples**: `/jira:create`, `/jira:implement`, `/zendesk:remove_arturo`

### Autonomous Commands (`:autonomous` Subcommands)
- **Purpose**: Zero-prompt execution with comprehensive upfront context
- **Best For**: Routine tasks, speed, well-understood workflows
- **Approach**: Front-loaded context with minimal interaction
- **Speed**: Fast execution with single approval gates
- **Examples**: `/jira:autonomous:create`, `/jira:autonomous:implement`, `/zendesk:autonomous:remove_arturo`

## Available Workflows

| Workflow | Interactive | Autonomous | Purpose |
|----------|-------------|------------|---------|
| **JIRA Create** | `/jira:create` | `/jira:autonomous:create` | Create JIRA tickets |
| **JIRA Implement** | `/jira:implement` | `/jira:autonomous:implement` | Implement tickets end-to-end |
| **JIRA Update** | `/jira:update` | `/jira:autonomous:update` | Update existing tickets |
| **Remove Arturo Flag** | `/zendesk:remove_arturo` | `/zendesk:autonomous:remove_arturo` | Remove feature flags |

## Choosing the Right Approach

### Start with Interactive When:
- 🎓 **Learning**: First time using a workflow
- 🤔 **Uncertain**: Requirements or approach unclear
- 🔍 **Exploring**: Need to understand codebase context
- ⚠️ **Complex**: Non-standard or unusual scenarios
- 🎯 **Precise**: Want control over each step

### Graduate to Autonomous When:
- ⚡ **Speed**: Need fast execution of routine tasks
- 📋 **Clear**: Have comprehensive context upfront
- 🔄 **Routine**: Familiar with the workflow and patterns
- 🤖 **Trust**: Comfortable with automated decision-making
- 📦 **Batch**: Processing multiple similar tasks

## Configuration Requirements

### Interactive Commands
- Standard Claude Code permissions
- No special trusted command configuration needed

### Autonomous Commands
- Requires trusted bash commands for zero-prompt execution
- See `TRUSTED_COMMANDS.md` for configuration details
- Must configure: `Bash(git:*)`, `Bash(gh:*)`, `Bash(testrbl:*)`, etc.

## Usage Examples

### Interactive Approach
```bash
# Guided ticket creation with prompts
/jira:create story
# → Prompts for description, priority, components, etc.
# → Explains each section and asks for confirmation
# → Walks through ticket creation step by step
```

### Autonomous Approach  
```bash
# Complete ticket creation with upfront context
/jira:autonomous:create story "Create user authentication with OAuth2. High priority. Affects login component. Include session management and security."
# → Creates ticket immediately with provided context
# → No prompts, executes full workflow autonomously
```

## Migration Path

1. **Learn** → Use interactive commands to understand workflows
2. **Practice** → Get comfortable with patterns and conventions  
3. **Graduate** → Switch to autonomous for routine execution
4. **Optimize** → Use interactive for exploration, autonomous for speed

## Integration with CLAUDE.md

These commands integrate with your global CLAUDE.md instructions:

- **Environment Setup**: Ruby version management, bundle install, dependencies
- **Git Workflow**: Branch naming, commit messages, PR templates
- **JIRA Integration**: ADF conversion, ticket templates, status management
- **Testing**: Test execution, RuboCop, validation workflows
- **Code Patterns**: Following existing conventions and patterns

## Getting Started

1. **Review** the README files in each subdirectory
2. **Start** with interactive commands to learn the workflows
3. **Configure** trusted commands for autonomous execution (see `TRUSTED_COMMANDS.md`)
4. **Practice** with both approaches to find your preferred workflow
5. **Customize** as needed for your specific development patterns

Each command is self-documented with usage examples, expected inputs, and success criteria.