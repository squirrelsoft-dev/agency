# Question 10: Settings - Required vs Optional

## Context
Plugin settings can have required fields (must configure) vs optional (use defaults).

## Question
Which settings are required vs optional with defaults?

## Proposed Settings Structure

### Settings Category 1: Default Models
```markdown
## Default Models
- **Orchestrator**: sonnet (balance of speed and intelligence)
- **Planning Agents**: sonnet (strategic thinking)
- **Implementation Agents**: haiku (fast execution) / sonnet (complex work)
- **Review Agents**: opus (thoroughness) / sonnet (balance)
```

**Required or Optional?**
**Recommendation**: OPTIONAL with smart defaults
- Most users will be fine with defaults
- Power users can customize
- Can be overridden per command

### Settings Category 2: GitHub Configuration
```markdown
## GitHub Configuration
- **Default Branch**: main
- **Branch Prefix**: feature/
- **Auto-Create PR**: true
- **PR Template**: .github/pull_request_template.md
```

**Required or Optional?**
**Recommendation**: OPTIONAL with smart defaults
- Can auto-detect default branch from repo
- Branch prefix defaults to `feature/`
- Auto-create PR defaults to `true`
- PR template auto-detected if exists

### Settings Category 3: Workflow Preferences
```markdown
## Workflow Preferences
- **Auto-Approve Simple Plans**: false
- **Parallel Execution**: true (when possible)
- **Auto-Run Tests**: true
- **Auto-Format**: true
- **Auto-Lint**: false (opt-in)
```

**Required or Optional?**
**Recommendation**: OPTIONAL with safe defaults
- All default to safe/conservative settings
- Users can enable aggressive automation if desired

### Settings Category 4: Quality Gates
```markdown
## Quality Gates
- **Require Tests**: true
- **Min Coverage**: 80%
- **Require Build Pass**: true
- **Require Lint Pass**: false
```

**Required or Optional?**
**Recommendation**: OPTIONAL with quality-focused defaults
- Enforce quality by default
- Users can relax if needed
- Can override per command

### Settings Category 5: Notification Preferences
```markdown
## Notification Preferences
- **Desktop Notifications**: false
- **Progress Updates**: true (for long-running tasks)
```

**Required or Optional?**
**Recommendation**: OPTIONAL with non-intrusive defaults
- Desktop notifications off by default
- Progress updates helpful for long tasks

## Summary

**All settings should be OPTIONAL with smart defaults**

**Rationale**:
1. Plugin works out of the box
2. No configuration barrier to entry
3. Sensible defaults for most users
4. Power users can customize everything

## Default Values Priority

If a setting is not configured:

1. **Check project settings** (`.claude/agency.local.md`)
2. **Check user settings** (`~/.claude/agency.local.md`)
3. **Use built-in defaults**

## Example Default Cascade

User runs `/agency:work 123` with no configuration:

```
1. Check .claude/agency.local.md → Not found
2. Check ~/.claude/agency.local.md → Not found
3. Use defaults:
   - Orchestrator: sonnet
   - Default branch: main (detected from git)
   - Auto-approve: false
   - Auto-format: true
   - Require tests: true
```

## Decision Needed
- Confirm all settings are optional
- Review default values for each setting
- Should there be a "strict mode" with more quality gates?
- Should there be a "fast mode" with fewer checks?

## Status
**Status**: Open
**Priority**: Low
**Blocking**: Phase 5 (Component Implementation - Settings)
