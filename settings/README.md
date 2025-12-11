# Agency Plugin Settings

Comprehensive configuration system for Agency plugin with cascading settings, smart defaults, and flexible validation.

## Overview

All settings are **optional** with sensible defaults. The plugin works perfectly out-of-box without any configuration.

## Settings Files

### Default Settings
- **Location**: `settings/defaults.yaml`
- **Purpose**: Built-in defaults for all settings
- **Editable**: No (part of plugin)

### User Settings
- **Location**: `~/.claude/agency.local.md` or `~/.claude/agency.local.yaml`
- **Purpose**: Personal preferences across all projects
- **Editable**: Yes
- **Scope**: All projects on this machine

### Project Settings
- **Location**: `.claude/agency.local.md` or `.claude/agency.local.yaml`
- **Purpose**: Project-specific overrides
- **Editable**: Yes
- **Scope**: Current project only
- **Git**: Should be git-ignored (`.claude/*.local.*` in `.gitignore`)

## Settings Cascade

Settings are loaded in priority order (later overrides earlier):

```
1. Plugin defaults (settings/defaults.yaml)
   ↓
2. User settings (~/.claude/agency.local.md)
   ↓
3. Project settings (.claude/agency.local.md)
   ↓
4. Command-line arguments (--model opus --no-tests)
```

**Example**:
```yaml
# defaults.yaml: enable_auto_format = true
# user settings: enable_auto_format = false
# project settings: enable_auto_format = true
# Result: true (project wins)
```

## Settings Categories

### 1. Models

Configure Claude models for different agent types:

```yaml
models:
  orchestrator: sonnet          # Coordination
  planning_agents: sonnet       # Strategic planning
  implementation_agents: haiku  # Fast execution
  review_agents: opus           # Thorough review
```

**Available models**: `haiku`, `sonnet`, `opus`

### 2. GitHub Integration

```yaml
github:
  default_branch: main
  branch_prefix: feature/
  auto_create_pr: true
  pr_template: .github/pull_request_template.md
  auto_assign_reviewers: false
```

### 3. Jira Integration

```yaml
jira:
  jira_url: "https://company.atlassian.net"
  default_project: "PROJ"
  transition_on_pr: true
  pr_transition_status: "In Review"
```

### 4. Workflow Preferences

```yaml
workflow:
  auto_approve_simple_plans: false  # Safety first
  parallel_execution: true          # Enable parallelism
  auto_run_tests: true              # Quality gate
  auto_commit: false                # Safety first
```

### 5. Quality Gates

```yaml
quality_gates:
  require_tests: true
  min_coverage: 80              # Percentage (0-100)
  require_build_pass: true
  require_lint_pass: false      # Warnings OK
  require_type_check: true
  block_on_security_issues: true
```

### 6. Testing Configuration

```yaml
testing:
  test_framework: auto-detect   # Or: jest, vitest, pytest, cargo-test
  test_command: npm test
  coverage_command: npm run test:coverage
  test_timeout: 300             # Seconds
  run_e2e_tests: false
```

### 7. Hook Settings

```yaml
hooks:
  enable_auto_format: true              # < 1s, enabled by default
  enable_pre_commit_validation: true    # 10-30s, enabled by default
  enable_auto_lint: false               # 2-5s, opt-in
  enable_build_verification: false      # 5-30s, opt-in
  enable_test_auto_run: false           # 30s+, opt-in
```

**Hook Performance**:
- **Auto-format**: Fast (< 1 second) - runs after every edit
- **Pre-commit validation**: Slow (10-30 seconds) - critical quality gate
- **Auto-lint**: Medium (2-5 seconds) - can be noisy
- **Build verification**: Slow (5-30 seconds) - too slow for every edit
- **Test auto-run**: Very slow (30+ seconds) - for TDD enthusiasts

### 8. Notifications

```yaml
notifications:
  desktop_notifications: false
  progress_updates: true        # For tasks > 2 minutes
  completion_summary: true
  error_notifications: true
```

### 9. Advanced Settings

```yaml
# Context management
context:
  max_orchestrator_context: 6000
  enable_context_cleanup: true

# Agent spawning
agents:
  max_parallel_agents: 4
  agent_timeout: 600            # Seconds

# Logging
logging:
  log_level: info               # debug, info, warn, error
  log_file: .agency/logs/agency.log

# Validation
validation:
  mode: lenient                 # strict, lenient, silent
```

## File Formats

### YAML Format (Recommended)

```yaml
# .claude/agency.local.yaml
hooks:
  enable_auto_format: true
  enable_auto_lint: true

quality_gates:
  min_coverage: 90
```

### Markdown Format

```markdown
# .claude/agency.local.md

## Hook Settings
- **Enable Auto-Format**: true
- **Enable Auto-Lint**: true

## Quality Gates
- **Min Coverage**: 90%
```

## Validation Modes

### Lenient (Default, Recommended)

```yaml
validation:
  mode: lenient
```

- Invalid settings use defaults with warnings
- Command continues
- Best for individual users

### Strict

```yaml
validation:
  mode: strict
```

- Any invalid setting fails the command
- User must fix before proceeding
- Best for production/team settings

### Silent

```yaml
validation:
  mode: silent
```

- Invalid settings use defaults silently
- No warnings shown
- Best for automation/CI

## Examples

### Minimal Configuration

```yaml
# Just override what you need
models:
  implementation_agents: sonnet  # Use sonnet for complex work

hooks:
  enable_auto_lint: true         # Opt into linting
```

### Maximum Quality

```yaml
models:
  orchestrator: opus
  review_agents: opus

quality_gates:
  require_tests: true
  min_coverage: 90
  require_build_pass: true
  require_lint_pass: true

hooks:
  enable_pre_commit_validation: true
  enable_build_verification: true
```

### Fast Prototyping

```yaml
models:
  orchestrator: haiku
  implementation_agents: haiku

workflow:
  auto_approve_simple_plans: true
  parallel_execution: true

quality_gates:
  require_tests: false
  require_build_pass: true

hooks:
  enable_auto_format: false
  enable_pre_commit_validation: false
```

## Enabling Opt-in Hooks

To enable opt-in hooks, add to your settings file:

```yaml
hooks:
  enable_auto_lint: true              # Enable linting
  enable_build_verification: true     # Enable build checks
  enable_test_auto_run: true          # Enable test auto-run
```

## Disabling Default Hooks

To disable default-enabled hooks:

```yaml
hooks:
  enable_auto_format: false           # Disable auto-format
  enable_pre_commit_validation: false # Disable pre-commit gates
```

## Troubleshooting

### Settings Not Being Applied

1. **Check file location**: Ensure `.claude/agency.local.md` or `~/.claude/agency.local.md` exists
2. **Check file format**: YAML must be valid (use a YAML validator)
3. **Check setting path**: Use correct nested structure (e.g., `hooks.enable_auto_format`)
4. **Check validation mode**: Set to `lenient` or `silent` to see warnings

### Hook Not Running

1. **Check if enabled**: Verify `hooks.enable_<hook_name>` is `true`
2. **Check hook script exists**: Ensure `hooks/<hook-name>.sh` exists
3. **Check hook is executable**: Run `chmod +x hooks/<hook-name>.sh`
4. **Check logs**: See `/tmp/agency-hooks-<hook-name>.log` for errors

### Quality Gate Blocking Commits

If pre-commit validation is blocking commits:

1. **Fix the issues**: Address build/lint/test failures
2. **Adjust thresholds**: Lower `min_coverage` or set `require_lint_pass: false`
3. **Disable temporarily**: Set `hooks.enable_pre_commit_validation: false`
4. **Override with git**: Use `git commit --no-verify` (not recommended)

## Related Documentation

- [Hook Configuration](../hooks/README.md) - Hook system details
- [Settings Template](../.claude/agency-settings-template.md) - Complete settings template
- [Settings Schema](settings.schema.json) - JSON schema for validation

## Notes

- All settings are optional
- Deep merge is used (partial overrides supported)
- Settings are cached for performance
- Changes take effect immediately (no restart required)
- Settings reader gracefully handles missing `yq` (uses defaults)
