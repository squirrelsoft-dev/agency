---
description: Get help for agency commands, agents, and skills
argument-hint: "[command|agent|skill]"
allowed-tools: [Read, Glob, Grep]
---

# Agency Help Command

Provide interactive help for agency commands, agents, and skills in a CLI-style format.

## Command Behavior

### No Arguments: `/agency:help`
Display overview help screen listing all available commands, agents, and skills organized by category.

### With Argument: `/agency:help <name>`
Display detailed help for the specified command, agent, or skill.

Examples:
- `/agency:help work` - Show help for the work command
- `/agency:help orchestrator` - Show help for the orchestrator agent
- `/agency:help github-integration` - Show help for the github-integration skill

## Implementation Instructions

### Phase 1: Determine Help Type

Check if an argument was provided:
- If NO argument: Show overview help (go to Phase 2)
- If argument provided: Show specific help (go to Phase 3)

### Phase 2: Overview Help (No Arguments)

Display a CLI-style help screen with the following structure:

```
AGENCY COMMANDS
Workflow automation commands for the complete development lifecycle

USAGE
  /agency:<command> [arguments] [options]
  /agency:help <command|agent|skill>

CORE COMMANDS
  work <issue>              Work on any issue (auto-detects GitHub/Jira)
  plan <issue|description>  Create implementation plan (no execution)
  implement <plan-file>     Implement from existing plan

WORKFLOW COMMANDS
  sprint [milestone]        Implement entire sprint
  triage [filter]          Triage issues
  parallel [scope]         Find parallelizable work
  worktree <issue>         Create git worktree for issue

QUALITY COMMANDS
  review [target]          Comprehensive code review
  test [target]            Generate comprehensive tests
  security [--full]        Security audit workflow

OPTIMIZATION COMMANDS
  optimize [--profile]     Performance optimization
  refactor <target>        Refactoring workflow

DOCUMENTATION COMMANDS
  document [target]        Generate documentation
  adr <decision>          Create Architecture Decision Record

GETTING HELP
  /agency:help              Show this help screen
  /agency:help <command>    Show detailed command help
  /agency:help <agent>      Show agent information
  /agency:help <skill>      Show skill information

EXAMPLES
  /agency:work 123          Work on issue #123
  /agency:plan next         Plan next available issue
  /agency:review PR-456     Review pull request
  /agency:help work         Get help for work command

For detailed information, use: /agency:help <command|agent|skill>
```

**Implementation Steps**:
1. Output the formatted help text above
2. List all available commands from `.claude/commands/agency-*.md` files
3. Optionally list available agents from `agents/` directories
4. Optionally list available skills from `skills/` directories

### Phase 3: Specific Help (With Argument)

When user provides an argument, determine what type of help to show:

**Step 1: Identify the target type**
1. Check if it's a command (exists in `.claude/commands/agency-{arg}.md`)
2. Check if it's an agent (exists in `agents/*/{arg}.md`)
3. Check if it's a skill (exists in `skills/{arg}/SKILL.md`)
4. If not found, show "not found" message with suggestions

**Step 2: Display Command Help**

If it's a command, read the command file and display:

```
COMMAND: /agency:<name>

DESCRIPTION
  <description from frontmatter>

USAGE
  /agency:<name> <argument-hint from frontmatter>

EXAMPLES
  <extract examples from command file>

WORKFLOW PHASES
  <extract phase information from command file>

AGENTS USED
  <extract agents mentioned in command file>

SKILLS USED
  <extract skills referenced in command file>

OPTIONS
  <extract any flags/options mentioned>

SEE ALSO
  <related commands>
```

**Step 3: Display Agent Help**

If it's an agent, read the agent file and display:

```
AGENT: <agent-name>

DESCRIPTION
  <description from frontmatter>

CATEGORY
  <category based on directory: engineering, testing, design, etc.>

TOOLS AVAILABLE
  <tools from frontmatter>

SKILLS REQUIRED
  <skills from frontmatter>

PRIMARY USE CASES
  <extract use cases from "Primary Use Cases" section>

WHEN TO SELECT
  <extract from "When to Select This Agent" section>

COMMANDS
  <extract from "Commands This Agent Responds To" section>

COLLABORATION
  <extract from "Cross-Agent Collaboration" section>

LOCATION
  <file path>

SEE ALSO
  <related agents from collaboration section>
```

**Step 4: Display Skill Help**

If it's a skill, read the skill file and display:

```
SKILL: <skill-name>

DESCRIPTION
  <description from frontmatter>

TRIGGERS
  <triggers from frontmatter>

WHEN TO USE
  <extract from "When to Use This Skill" section>

KEY TOPICS
  <extract section headings from content>

QUICK REFERENCE
  <extract from "Quick Reference" section if exists>

FILES
  Main: skills/<skill>/SKILL.md
  References: <list files in references/>
  Examples: <list files in examples/>

RELATED SKILLS
  <extract from "Related Skills" section>

USAGE
  Activate this skill by mentioning any of these phrases in your request:
  <list trigger phrases>
```

**Step 5: Not Found Message**

If the target is not found:

```
NOT FOUND: <name>

Could not find command, agent, or skill named "<name>"

Did you mean one of these?
  <list similar commands using fuzzy matching>
  <list similar agents>
  <list similar skills>

Available commands: /agency:help
Available agents:    /agency:help agents
Available skills:    /agency:help skills
```

### Phase 4: Special Listing Commands

Handle special cases:

**`/agency:help commands`**: List all commands with brief descriptions
**`/agency:help agents`**: List all agents by category
**`/agency:help skills`**: List all skills with descriptions

## Implementation Details

### Finding Commands
```typescript
// Use Glob to find all command files
const commandFiles = await glob('.claude/commands/agency-*.md');
// Extract command names: agency-work.md -> work
```

### Finding Agents
```typescript
// Use Glob to find all agent files
const agentFiles = await glob('agents/**/*.md');
// Organize by directory (category)
```

### Finding Skills
```typescript
// Use Glob to find all skill files
const skillFiles = await glob('skills/*/SKILL.md');
// Extract skill names from directory names
```

### Parsing Frontmatter
```typescript
// Read file content
// Extract YAML frontmatter between --- markers
// Parse description, triggers, tools, etc.
```

### Fuzzy Matching for Suggestions
```typescript
// When target not found, calculate string similarity
// Suggest commands/agents/skills with similar names
// Use Levenshtein distance or similar algorithm
```

## Output Format Guidelines

1. **Use clear section headers**: ALL CAPS for main sections
2. **Indentation**: 2 spaces for nested items
3. **Consistent spacing**: Blank line between sections
4. **Monospace formatting**: Use backticks for commands, file paths
5. **Bullet points**: Use `-` for lists
6. **Alignment**: Align command names and descriptions
7. **Color**: Not available, but use emphasis with **bold** or `code`

## Error Handling

1. **File not found**: Gracefully handle missing files, show helpful message
2. **Invalid frontmatter**: Parse what's available, note if incomplete
3. **Empty sections**: Skip sections with no content
4. **Ambiguous matches**: If multiple matches, ask user to be more specific

## Examples of Expected Output

### Example 1: `/agency:help`
Shows the main overview help screen with all commands listed.

### Example 2: `/agency:help work`
```
COMMAND: /agency:work

DESCRIPTION
  Work on any issue (auto-detects GitHub/Jira)

USAGE
  /agency:work <issue-id|url|'next'>

EXAMPLES
  /agency:work 123              Work on issue #123
  /agency:work next             Work on next available issue
  /agency:work https://...      Work on issue from URL

WORKFLOW PHASES
  1. Fetch - Retrieve issue details from GitHub/Jira
  2. Plan - Create implementation plan
  3. Review Plan - User reviews and approves plan
  4. Implement - Execute implementation
  5. Test - Run tests and verify
  6. Review - Code review
  7. PR - Create pull request

AGENTS USED
  - orchestrator - Coordinates the workflow
  - Plan agent - Creates implementation plan
  - Specialist agents - Execute implementation
  - Reality Checker - Reviews final output

SKILLS USED
  - github-integration or jira-integration
  - agency-workflow-patterns
  - testing-strategy

SEE ALSO
  /agency:plan      Create plan without executing
  /agency:implement Execute from existing plan
  /agency:help      Show all commands
```

### Example 3: `/agency:help frontend-developer`
```
AGENT: frontend-developer

DESCRIPTION
  Expert frontend developer specializing in modern web technologies

CATEGORY
  Engineering

TOOLS AVAILABLE
  Read, Write, Edit, Bash, Grep, Glob, Task, WebFetch

SKILLS REQUIRED
  Essential: nextjs-16-expert, typescript-5-expert, tailwindcss-4-expert
  Optional: testing-strategy, github-integration

PRIMARY USE CASES
  - Building React/Next.js user interfaces
  - Component architecture and design systems
  - Frontend performance optimization
  - UI/UX implementation

WHEN TO SELECT
  - Implementing user-facing features
  - Creating reusable UI components
  - Frontend bug fixes
  - Styling and responsive design

COMMANDS
  Primary: /agency:work, /agency:implement
  Secondary: /agency:optimize, /agency:refactor

COLLABORATION
  Receives work from: Backend Architect, UI Designer
  Provides work to: Reality Checker, Testing agents
  Works alongside: Senior Developer

LOCATION
  agents/engineering/frontend-developer.md

SEE ALSO
  backend-architect    - Backend implementation
  ui-designer         - UI design
  senior-developer    - Full-stack development
```

### Example 4: `/agency:help github-integration`
```
SKILL: github-integration

DESCRIPTION
  Master GitHub integration using gh CLI, GitHub API, issue/PR management

TRIGGERS
  - "github integration"
  - "gh cli"
  - "github api"
  - "github issue detection"
  - "github actions"

WHEN TO USE
  - Automating GitHub operations
  - Building GitHub-based workflows
  - Parsing GitHub URLs
  - Managing issues and pull requests
  - Creating GitHub Actions

KEY TOPICS
  - GitHub CLI (gh) Mastery
  - GitHub API Patterns
  - Issue and PR Detection
  - GitHub Actions Integration
  - Sprint Planning with GitHub Projects

QUICK REFERENCE
  Essential gh commands:
    gh issue list --label <label>
    gh pr create --fill
    gh pr merge --squash --auto

  Key API endpoints:
    GET /repos/{owner}/{repo}/issues
    POST /repos/{owner}/{repo}/issues

FILES
  Main: skills/github-integration/SKILL.md
  References:
    - gh-cli-reference.md (complete CLI reference)
    - github-api-patterns.md (API patterns)
    - github-actions-integration.md (workflow templates)
  Examples:
    - gh-cli-scripts.md (shell scripts)
    - api-usage-examples.md (TypeScript examples)
    - issue-detection-patterns.md (regex patterns)

RELATED SKILLS
  - github-workflow-best-practices
  - agency-workflow-patterns
  - jira-integration

USAGE
  Activate this skill by mentioning any trigger phrase:
  "Show me github integration patterns"
  "How do I use gh cli to create issues?"
  "Parse github issue URLs"
```

## Notes

- This command is read-only (uses Read, Glob, Grep only)
- Provides information without modifying any files
- Should be fast and responsive
- Output should be easy to scan and understand
- Use consistent formatting for professional CLI appearance
