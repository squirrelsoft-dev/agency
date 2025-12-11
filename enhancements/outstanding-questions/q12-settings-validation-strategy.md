# Question 12: Settings Validation Strategy

## Context
User settings may contain invalid values. Need to decide how to handle validation and errors.

## Question
Should invalid settings be rejected, use defaults with warnings, or prompt for fixes?

## Validation Scenarios

### Scenario 1: Invalid Model Name
**User Setting**:
```markdown
## Default Models
- **Orchestrator**: super-claude-9000
```

**Options**:
- ❌ **Reject**: Fail command with error "Invalid model: super-claude-9000"
- ⚠️ **Warn + Default**: Use 'sonnet' + warn "Invalid model, using default"
- ❓ **Prompt**: Ask user "Invalid model. Use sonnet, opus, or haiku?"

### Scenario 2: Invalid Coverage Percentage
**User Setting**:
```markdown
## Quality Gates
- **Min Coverage**: 150%
```

**Options**:
- ❌ **Reject**: Fail with "Coverage must be 0-100"
- ⚠️ **Warn + Default**: Use 80% + warn "Invalid coverage, using 80%"
- 🔧 **Auto-Fix**: Clamp to 100% + warn "Coverage clamped to 100%"

### Scenario 3: Missing Required Field
**User Setting**:
```markdown
## GitHub Configuration
# (branch prefix not specified)
```

**Options**:
- ✅ **Use Default**: Use 'feature/' silently (no required fields)
- ⚠️ **Warn**: Use default + warn "Branch prefix not set, using 'feature/'"
- ❌ **Reject**: Fail with "Missing required field: branch prefix"

### Scenario 4: Conflicting Settings
**User Setting**:
```markdown
## Workflow Preferences
- **Auto-Approve Simple Plans**: true
- **Require Tests**: true
- **Auto-Run Tests**: false
```

**Conflict**: Can't require tests if they don't auto-run and plan is auto-approved

**Options**:
- ❌ **Reject**: Fail with "Conflicting settings detected"
- ⚠️ **Warn**: Proceed + warn "May fail quality gates"
- 🔧 **Smart Fix**: Enable auto-run tests + warn "Auto-enabled test running"

## Recommended Validation Strategy

### Phase 1: Parse Settings
1. Read settings file (user or project)
2. Parse markdown/YAML
3. If parse fails: Log error, use all defaults

### Phase 2: Validate Each Setting
For each setting:
1. Check type (string, boolean, number, enum)
2. Check range (0-100 for percentage, valid model names, etc.)
3. If invalid:
   - Log warning with setting name and invalid value
   - Use default value for that setting
   - Continue (don't fail entire command)

### Phase 3: Validate Setting Combinations
1. Check for logical conflicts
2. If conflict found:
   - Log warning describing conflict
   - Apply smart defaults to resolve
   - Continue

### Phase 4: Report
- If any warnings: Show summary before command runs
- Give user option to proceed or abort
- Log all warnings for later review

## Example Validation Flow

```
User runs: /agency:work 123

1. Load settings:
   ✅ User settings loaded
   ✅ Project settings loaded
   ❌ Invalid model 'super-claude' in user settings
   ❌ Invalid coverage '150%' in project settings

2. Warnings:
   ⚠️ Invalid orchestrator model 'super-claude', using 'sonnet'
   ⚠️ Invalid coverage '150%', using '80%'

3. Final config:
   - Orchestrator: sonnet (default)
   - Min Coverage: 80% (default)
   - [other settings...]

Proceed? (y/n/fix)
```

## Strictness Modes

Could offer different validation modes:

### Strict Mode
- Any invalid setting fails the command
- User must fix before proceeding
- Best for production/team settings

### Lenient Mode (Default)
- Invalid settings use defaults with warnings
- Command continues
- Best for individual users

### Silent Mode
- Invalid settings use defaults silently
- No warnings shown
- Best for automation/CI

## Decision Needed

1. **Default mode**: Lenient (warnings + defaults)?

2. **User control**: Should users be able to set validation mode?
   ```markdown
   ## Plugin Settings
   - **Validation Mode**: lenient | strict | silent
   ```

3. **Warning format**: How to show warnings?
   - Inline before command runs
   - Summary at the end
   - Log file only
   - All of the above

4. **Fix workflow**: If settings invalid, how to help user fix?
   - Show correct format in warning
   - Offer `/agency:config --validate` command
   - Auto-generate template with `--init` flag

5. **Schema validation**: Should settings have a JSON schema?
   - Pros: Formal validation, IDE autocomplete
   - Cons: More complex, schema maintenance

## Status
**Status**: Open
**Priority**: Low
**Blocking**: Phase 5 (Component Implementation - Settings)
