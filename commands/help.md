---
description: Get help for agency commands, agents, and skills
argument-hint: "[command|agent|skill]"
allowed-tools: Read, Glob, Grep
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

<!-- Component: File discovery uses standard Glob patterns -->

### Finding Commands

```bash
# Use Glob to find all command files
Glob: pattern=".claude/commands/agency-*.md"

# Extract command names from filenames
# Example: agency-work.md -> work
# Example: agency-plan.md -> plan
```

**Pattern**: All agency commands follow `.claude/commands/agency-{name}.md` naming convention

### Finding Agents

```bash
# Use Glob to find all agent files
Glob: pattern="agents/**/*.md"

# Organize by directory (category):
# - agents/engineering/* -> Engineering category
# - agents/testing/* -> Testing category
# - agents/design/* -> Design category
```

**Pattern**: Agents are organized by role category in subdirectories

### Finding Skills

```bash
# Use Glob to find all skill files
Glob: pattern="skills/*/SKILL.md"

# Extract skill names from directory names:
# - skills/github-integration/SKILL.md -> github-integration
# - skills/testing-strategy/SKILL.md -> testing-strategy
```

**Pattern**: Each skill has its own directory with SKILL.md as the main file

### Parsing Frontmatter

```bash
# Read file content using Read tool
Read: file_path="[discovered-file-path]"

# Extract YAML frontmatter:
# 1. Find content between first two --- markers
# 2. Parse YAML to extract:
#    - description
#    - triggers (for skills)
#    - allowed-tools (for commands)
#    - argument-hint (for commands)
# 3. Handle missing or malformed frontmatter gracefully
```

**Fallback**: If frontmatter parsing fails, extract description from first paragraph

### Fuzzy Matching for Suggestions

**Algorithm for "NOT FOUND" suggestions**:

1. **Calculate similarity score** for user input vs. all available names
   - Use simple character matching or Levenshtein distance
   - Ignore case differences
   - Consider partial matches (substring matching)

2. **Rank suggestions** by similarity score
   - Exact substring match: highest priority
   - Starts with input: high priority
   - Contains input: medium priority
   - Similar characters: low priority

3. **Show top 5 suggestions** across all categories
   - Include category (command/agent/skill)
   - Show full name and brief description
   - Provide exact usage syntax

**Example**:
```
User input: "workk" (typo)
Top suggestions:
  - work (command) - Work on any issue
  - worktree (command) - Create git worktree for issue
  - workflow-agent (agent) - Manages workflow orchestration
```

## Output Format Guidelines

<!-- Component: Based on prompts/reporting/ standards -->

1. **Use clear section headers**: ALL CAPS for main sections
2. **Indentation**: 2 spaces for nested items
3. **Consistent spacing**: Blank line between sections
4. **Monospace formatting**: Use backticks for commands, file paths
5. **Bullet points**: Use `-` for lists
6. **Alignment**: Align command names and descriptions
7. **Color**: Not available, but use emphasis with **bold** or `code`
8. **Status indicators**: Use ✅, ⚠️, ❌ for visual clarity when showing status
9. **File paths**: Always use absolute paths, never relative paths
10. **Code blocks**: Use fenced code blocks with language hints for syntax highlighting

## Error Handling

<!-- Component: prompts/error-handling/ -->

### File Not Found Errors

**When command/agent/skill file doesn't exist**:
- Check for typos in the search name
- Use fuzzy matching to suggest similar names
- Provide clear message about what was searched
- Offer to list all available options

**Recovery**: Show "NOT FOUND" message (see Phase 3, Step 5) with suggestions

### Invalid or Missing Frontmatter

**When frontmatter is malformed or missing**:
- Attempt to parse what's available
- Show warning about incomplete metadata
- Continue displaying what information exists
- Note which fields are missing

**Recovery**: Display partial information, note limitations

### Empty Sections

**When content sections are missing**:
- Skip empty sections entirely
- Don't show "None" or "Empty" placeholders
- Maintain clean output format
- Only display sections with actual content

### Ambiguous Matches

**When multiple items match search term**:
- List all matching items
- Show category/location for each match
- Ask user to be more specific
- Provide exact paths for disambiguation

**Example**: If searching "test" matches both "test-agent" and "testing-strategy" skill, list both with full context

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

---

## Component References

This command leverages reusable prompt components for consistency across the agency plugin:

### Error Handling Components

Referenced in **Error Handling** section:

- **`prompts/error-handling/scope-detection-failure.md`** - Patterns for handling missing or ambiguous targets
- **`prompts/error-handling/tool-execution-failure.md`** - File not found and tool errors (Read, Glob failures)
- **`prompts/error-handling/ask-user-retry.md`** - User decision patterns for ambiguous matches

**Usage**: Error handling patterns ensure consistent user experience when help targets aren't found

### Reporting Components

Referenced in **Output Format Guidelines** section:

- **`prompts/reporting/summary-template.md`** - Standard formatting conventions
  - Section headers (ALL CAPS)
  - Status indicators (✅, ⚠️, ❌)
  - Code block formatting
  - File path conventions (absolute paths)

**Usage**: Output follows agency-wide formatting standards for professional CLI appearance

### File Discovery Patterns

Referenced in **Implementation Details** section:

- **Standard Glob patterns** - Consistent file discovery across all commands
  - Commands: `.claude/commands/agency-*.md`
  - Agents: `agents/**/*.md`
  - Skills: `skills/*/SKILL.md`

**Usage**: Same discovery patterns used by other commands for reliability

### Related Components (Not Directly Used)

These components are NOT used by the help command but may be referenced in help output when describing other commands:

- **`prompts/issue-management/`** - Used by work/plan/sprint commands
- **`prompts/git/`** - Used by commands that create PRs/commits
- **`prompts/quality-gates/`** - Used by implement/work commands
- **`prompts/specialist-selection/`** - Used by orchestrator workflows
- **`prompts/planning/`** - Used by plan/implement commands
- **`prompts/progress/`** - Used by multi-phase commands

**Note**: When showing help for these commands, you may reference these components in the output to explain their workflow
