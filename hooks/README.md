# Agency Hooks

Automated quality checks and workflow automation using Claude Code hooks.

## Overview

Hooks provide deterministic automation that runs at specific lifecycle events:
- `PreToolUse`: Before a tool is used
- `PostToolUse`: After a tool is used
- `UserPromptSubmit`: When user submits a prompt

## Available Hooks

### Auto-Format on Edit (Default: Enabled)
Automatically formats files after editing using project-specific formatter.

**Event**: PostToolUse on Edit tool
**Command**: Auto-detected (prettier, black, rustfmt, etc.)
**Performance**: Fast (< 1 second)

### Pre-Commit Validation (Default: Enabled)
Runs tests and linting before allowing commits.

**Event**: PreToolUse on Bash tool (git commit commands)
**Checks**: Build, lint, tests
**Performance**: Slow (10-30 seconds), but critical quality gate

### Auto-Lint (Default: Disabled - Opt-in)
Runs linter after edits and reports issues.

**Event**: PostToolUse on Edit tool
**Command**: Auto-detected (eslint, pylint, clippy, etc.)
**Performance**: Fast to Medium

### Build Verification (Default: Disabled - Opt-in)
Runs type checking after TypeScript/JavaScript edits.

**Event**: PostToolUse on Edit tool
**Command**: `tsc --noEmit` or equivalent
**Performance**: Slow (5-30 seconds)

## Hook Configuration

Hooks are configured in `hooks/hooks.json` (not yet implemented).

## Implementation Status

### Phase 1 (Planned)
- [ ] Auto-format on edit (prettier/black/rustfmt)
- [ ] Pre-commit validation

### Phase 2 (Planned)
- [ ] Auto-lint (opt-in)
- [ ] Build verification (opt-in)

### Phase 3 (Future)
- [ ] Test auto-run (opt-in)
- [ ] Desktop notifications
- [ ] Progress tracking for long operations

## Design Questions

See `enhancements/outstanding-questions/` for hook design decisions:
- `q7-hook-default-enablement.md` - Which hooks enabled by default
- `q8-hook-performance-strategy.md` - Sync vs async execution
- `q9-hook-project-detection.md` - How to detect project type

## Creating Hooks

To create a new hook:

1. Create `hooks/hooks.json` with configuration
2. Use prompt-based hooks for complex logic
3. Use command-based hooks for simple operations
4. Test with validate-hook-schema.sh and test-hook.sh utilities

Example hook configuration:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{
        "type": "command",
        "command": "prettier --write \"{{file_path}}\""
      }]
    }]
  }
}
```

## Related Documentation

- Claude Code Hooks Documentation
- `skills/agency-workflow-patterns/` - Workflow patterns
- `/claude-builder:new-hook` - Hook generator command

## Notes

- Hooks run deterministically (always execute)
- Use hooks for automation, not AI decisions
- Keep hooks fast to avoid disrupting workflow
- Provide clear error messages when hooks fail
- Allow users to disable hooks if needed

