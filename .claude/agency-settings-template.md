# Agency Plugin Configuration Template

Copy this file to `.claude/agency.local.md` (project-level) or `~/.claude/agency.local.md` (user-level) to configure Agency plugin settings.

**Note**: This file should be git-ignored (`.claude/*.local.md` is in `.gitignore`)

---

## Default Models

Configure which Claude models to use for different agent types:

- **Orchestrator**: sonnet
  - _Balance of speed and strategic intelligence for coordination_
- **Planning Agents**: sonnet
  - _Strategic thinking and architecture planning_
- **Implementation Agents**: haiku
  - _Fast execution for straightforward coding tasks_
  - _Use sonnet for complex implementation work_
- **Review Agents**: opus
  - _Maximum thoroughness for quality review_
  - _Use sonnet for balance of speed and quality_

**Available Models**: haiku, sonnet, opus

---

## GitHub Configuration

Settings for GitHub workflow automation:

- **Default Branch**: main
  - _Primary branch to pull from and create PRs against_
- **Branch Prefix**: feature/
  - _Prefix for feature branches (feature/, bugfix/, hotfix/)_
- **Auto-Create PR**: true
  - _Automatically create PRs after implementing issues_
- **PR Template**: .github/pull_request_template.md
  - _Path to PR template (if exists)_
- **Auto-Assign Reviewers**: false
  - _Automatically assign reviewers based on CODEOWNERS_

---

## Jira Configuration

Settings for Jira workflow automation:

- **Jira URL**: https://your-company.atlassian.net
  - _Your Jira instance URL_
- **Default Project**: PROJ
  - _Default Jira project key_
- **Transition on PR**: true
  - _Automatically transition Jira issues when PR is created_
- **PR Transition Status**: In Review
  - _Jira status to transition to when PR is created_

---

## Workflow Preferences

Control automation behavior:

- **Auto-Approve Simple Plans**: false
  - _Skip user approval for simple plans (< 20 LOC changes)_
  - _Recommended: false for safety_
- **Parallel Execution**: true
  - _Enable parallel agent execution when possible_
- **Auto-Run Tests**: true
  - _Automatically run tests after implementation_
- **Auto-Format**: true
  - _Automatically format code after edits (via hooks)_
- **Auto-Lint**: false
  - _Automatically lint code after edits (can be noisy)_
- **Auto-Commit**: false
  - _Automatically commit after successful verification_
  - _Recommended: false for safety_

---

## Quality Gates

Requirements before allowing PR creation:

- **Require Tests**: true
  - _Fail if tests don't pass_
- **Min Coverage**: 80%
  - _Minimum test coverage percentage_
- **Require Build Pass**: true
  - _Fail if build doesn't complete successfully_
- **Require Lint Pass**: false
  - _Fail if linting has errors (warnings OK)_
- **Require Type Check**: true
  - _Fail if TypeScript type checking has errors_
- **Block on Security Issues**: true
  - _Fail if security vulnerabilities detected_

---

## Testing Configuration

Test framework and execution settings:

- **Test Framework**: auto-detect
  - _Options: auto-detect, jest, vitest, pytest, cargo-test_
- **Test Command**: npm test
  - _Command to run tests_
- **Coverage Command**: npm run test:coverage
  - _Command to generate coverage report_
- **Test Timeout**: 300
  - _Test execution timeout in seconds_
- **Run E2E Tests**: false
  - _Include E2E tests in verification (can be slow)_

---

## Notification Preferences

How to notify about workflow progress:

- **Desktop Notifications**: false
  - _Show desktop notifications for completed workflows_
- **Progress Updates**: true
  - _Show progress updates for long-running tasks (> 2 minutes)_
- **Completion Summary**: true
  - _Show detailed summary when workflow completes_
- **Error Notifications**: true
  - _Show notifications when errors occur_

---

## Hook Settings

Configure automated hooks:

- **Enable Auto-Format**: true
  - _Run formatter after edits_
- **Enable Pre-Commit Validation**: true
  - _Validate before commits_
- **Enable Auto-Lint**: false
  - _Run linter after edits (can be noisy)_
- **Enable Build Verification**: false
  - _Run build after edits (can be slow)_
- **Enable Test Auto-Run**: false
  - _Run tests after relevant changes (very slow)_

---

## Advanced Settings

Advanced configuration options:

### Context Management

- **Max Orchestrator Context**: 6000
  - _Maximum tokens in orchestrator context_
- **Enable Context Cleanup**: true
  - _Automatically clean up old context_

### Agent Spawning

- **Max Parallel Agents**: 4
  - _Maximum agents to run simultaneously_
- **Agent Timeout**: 600
  - _Agent execution timeout in seconds_

### Logging

- **Log Level**: info
  - _Options: debug, info, warn, error_
- **Log File**: .agency/logs/agency.log
  - _Path to log file_

---

## Validation Mode

How to handle invalid settings:

- **Validation Mode**: lenient
  - _Options: strict, lenient, silent_
  - _strict: Fail on invalid settings_
  - _lenient: Use defaults with warnings (recommended)_
  - _silent: Use defaults without warnings_

---

## Example Configurations

### Minimal Configuration (Recommended)
```markdown
## Default Models
- **Orchestrator**: sonnet
- **Implementation Agents**: haiku

## Workflow Preferences
- **Auto-Format**: true
- **Auto-Run Tests**: true
```

### Maximum Quality Configuration
```markdown
## Default Models
- **Orchestrator**: opus
- **Review Agents**: opus

## Quality Gates
- **Require Tests**: true
- **Min Coverage**: 90%
- **Require Build Pass**: true
- **Require Lint Pass**: true
- **Block on Security Issues**: true

## Hook Settings
- **Enable Pre-Commit Validation**: true
- **Enable Build Verification**: true
```

### Fast Prototyping Configuration
```markdown
## Default Models
- **Orchestrator**: haiku
- **Implementation Agents**: haiku

## Workflow Preferences
- **Auto-Approve Simple Plans**: true
- **Parallel Execution**: true

## Quality Gates
- **Require Tests**: false
- **Require Build Pass**: true
```

---

## Override Priority

Settings are loaded in this order (later overrides earlier):
1. Built-in defaults (in plugin code)
2. User settings (`~/.claude/agency.local.md`)
3. Project settings (`.claude/agency.local.md`)
4. Command-line flags (`--model opus --no-tests`)

---

## Related Documentation

- `enhancements/outstanding-questions/q10-settings-required-vs-optional.md` - Required vs optional settings
- `enhancements/outstanding-questions/q11-settings-override-levels.md` - Override hierarchy
- `enhancements/outstanding-questions/q12-settings-validation-strategy.md` - Validation approach

---

**Note**: All settings are optional with sensible defaults. The plugin works out of the box without configuration.
