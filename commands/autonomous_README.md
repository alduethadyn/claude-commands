# Autonomous Commands

This directory contains autonomous versions of the standard commands designed to work with minimal user interaction. These commands expect comprehensive context upfront and execute complete workflows with only approval gates for final submissions.

## Key Differences from Standard Commands

### Standard Commands
- Interactive prompts throughout workflow
- Step-by-step user guidance
- Multiple decision points requiring user input
- Gradual information gathering

### Autonomous Commands
- Comprehensive context expected upfront
- Minimal user interaction during execution
- Automatic decision making based on established patterns
- Single approval point at end (PR/ticket creation)

## Available Autonomous Commands

### JIRA Commands

#### `/jira:autonomous:create {story|task}`
**Usage**: `/jira:autonomous:create story "Create user authentication system with OAuth2 support. Users need to log in with Google/GitHub. High priority. Affects login component and user management. Should include session management and security considerations."`

**Expected Context**:
- Complete problem description
- Technical requirements
- Priority level
- Affected components
- Special considerations

**Autonomous Actions**:
- Generates complete JIRA ticket content
- Creates ticket immediately
- Provides ticket URL and next steps

#### `/jira:autonomous:implement {TICKET-ID}`
**Usage**: `/jira:autonomous:implement TALK-123`

**Optional Context**:
- Implementation approach preferences
- Areas to focus on/avoid
- Testing requirements
- Architectural constraints

**Autonomous Actions**:
- Fetches ticket and creates implementation plan
- Sets up development environment
- Creates branch and implements changes
- Runs tests and creates PR
- Updates JIRA to Ready for Review

#### `/jira:autonomous:update {TICKET-ID}`
**Usage**: `/jira:autonomous:update EM-9452 "Move to Ready for Review status, assign to me, add implementation notes about the new authentication flow and testing completed, update priority to High"`

**Expected Context**:
- All desired changes in single description
- Status changes
- Assignee updates  
- Content additions
- Field modifications

**Autonomous Actions**:
- Parses all update requirements
- Executes all changes simultaneously
- Provides comprehensive update summary

### Zendesk Commands

#### `/zendesk:autonomous:remove_arturo {flag_name}`
**Usage**: `/zendesk:autonomous:remove_arturo flag_name "This flag is fully rolled out at 100% and affects the email processing pipeline and user notification system. No special considerations."`

**Expected Context**:
- Rollout status (fully rolled out/disabled)
- Affected systems/components
- Special considerations

**Autonomous Actions**:
- Creates JIRA ticket for flag removal
- Sets up development environment
- Implements flag removal based on rollout status
- Updates all tests
- Creates PR ready for review
- Updates JIRA ticket status

## Design Principles

### 1. Zero-Prompt Execution
Commands execute bash/git/CLI operations without requiring user approval for each command. All necessary commands should be pre-trusted.

### 2. Front-loaded Context
All autonomous commands expect comprehensive information in the initial prompt rather than gathering it through interactive sessions.

### 3. Intelligent Defaults
Commands make reasonable assumptions and use established patterns when specific information isn't provided.

### 4. Error Recovery
Commands handle common errors automatically and only escalate complex issues that require human decision-making.

### 5. Complete Workflows
Each command executes an entire workflow from start to finish, ending at a natural approval gate (PR creation, ticket ready for review).

### 6. Comprehensive Reporting
Commands provide detailed summaries of all actions taken, changes made, and next steps.

## When to Use Autonomous Commands

### Use Autonomous Commands When:
- You have complete context about the requirements
- You want minimal interaction during execution
- You trust the established patterns and conventions
- You want to approve the final result rather than guide the process

### Use Standard Commands When:
- You need to explore and understand the requirements
- You want to guide the process step by step
- You're working on something experimental or unusual
- You want to learn about the codebase during the process

## Command Mapping

| Standard Command | Autonomous Equivalent | Key Difference |
|------------------|----------------------|----------------|
| `/jira:create` | `/jira:autonomous:create` | All context provided upfront, immediate execution |
| `/jira:implement` | `/jira:autonomous:implement` | Complete implementation workflow with minimal interaction |
| `/jira:update` | `/jira:autonomous:update` | All updates specified in single comprehensive prompt |
| `/zendesk:remove_arturo` | `/zendesk:autonomous:remove_arturo` | Full workflow from JIRA creation to PR ready for review |

## Error Handling Strategy

Autonomous commands are designed to handle errors gracefully:

1. **Auto-Recovery**: Common issues (dependency problems, style fixes) handled automatically
2. **Smart Defaults**: Missing information filled with reasonable defaults
3. **Escalation Points**: Only complex decisions or failures requiring human input pause execution
4. **Comprehensive Logging**: All actions and decisions are documented for transparency

## Configuration Requirements

For true zero-prompt execution, ensure these bash commands are trusted in your Claude Code configuration:

```
Bash(git:*), Bash(gh:*), Bash(testrbl:*), Bash(rake:*), Bash(gem:*), 
Bash(mkdir:*), Bash(rm:*), Bash(rubocop:*), Bash(bundle exec:*)
```

See `TRUSTED_COMMANDS.md` for the complete list and configuration details.

## Best Practices

1. **Provide Comprehensive Context**: Include all relevant information in your initial prompt
2. **Be Specific**: The more detail you provide, the better the autonomous execution
3. **Review Results**: Always verify the final output meets your expectations
4. **Use for Routine Tasks**: Best suited for well-understood, pattern-based work
5. **Fall Back When Needed**: Use standard commands for complex or exploratory work
6. **Trust Configuration**: Ensure all necessary bash commands are pre-trusted for zero-prompt operation