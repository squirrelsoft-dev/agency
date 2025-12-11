# Question 11: Settings Override Levels

## Context
Settings can exist at multiple levels (user, project, command-line). Need to define precedence.

## Question
Should settings support multiple override levels, and what's the precedence?

## Proposed Override Hierarchy

### Level 1: Built-in Defaults (Lowest Priority)
**Location**: Plugin code
**Scope**: All users, all projects
**Purpose**: Sensible defaults that work everywhere

**Example**:
```typescript
const DEFAULT_CONFIG = {
  orchestrator: 'sonnet',
  defaultBranch: 'main',
  autoFormat: true,
  requireTests: true
}
```

### Level 2: User Defaults
**Location**: `~/.claude/agency.local.md`
**Scope**: One user, all projects
**Purpose**: Personal preferences across all work

**Example**:
```markdown
# ~/.claude/agency.local.md

## Default Models
- **Orchestrator**: opus (I want max intelligence)
- **Planning Agents**: sonnet

## Workflow Preferences
- **Auto-Approve Simple Plans**: true (I trust the system)
```

### Level 3: Project Settings
**Location**: `.claude/agency.local.md`
**Scope**: One project, all users
**Purpose**: Project-specific configuration

**Example**:
```markdown
# .claude/agency.local.md

## GitHub Configuration
- **Default Branch**: develop (we use gitflow)
- **Branch Prefix**: feat/

## Quality Gates
- **Min Coverage**: 90% (higher standards for this project)
```

### Level 4: Command Arguments (Highest Priority)
**Location**: Command line flags
**Scope**: Single command execution
**Purpose**: One-time overrides

**Example**:
```bash
/agency:work 123 --model opus --no-tests --auto-approve
```

## Precedence Rules

**Priority**: Command Args > Project Settings > User Settings > Built-in Defaults

**Example Resolution**:
```
Setting: orchestrator model

Built-in default: sonnet
User setting (~/.claude/): opus
Project setting (.claude/): haiku
Command arg: --model sonnet

Final value: sonnet (command arg wins)
```

**Example with Partial Overrides**:
```
Setting: Quality Gates

Built-in defaults:
  requireTests: true
  minCoverage: 80%
  requireBuild: true

User settings:
  minCoverage: 90%  (only override this)

Project settings:
  requireTests: false  (only override this)

Final merged config:
  requireTests: false  (from project)
  minCoverage: 90%    (from user)
  requireBuild: true  (from defaults)
```

## Configuration Merge Strategy

### Strategy A: Last-Win (Simple)
Later configs completely replace earlier ones

**Pros**: Simple, predictable
**Cons**: Can't partially override

### Strategy B: Deep Merge (Recommended)
Later configs merge with earlier ones, overriding only specified fields

**Pros**: Flexible, can partially override
**Cons**: More complex, need clear merge rules

## Decision Needed

1. **Confirm override hierarchy**: Command Args > Project > User > Defaults?

2. **Merge strategy**: Deep merge or last-win?

3. **Command argument syntax**: How should command args work?
   - Flags: `--model opus --no-tests`
   - Config file: `--config custom.md`
   - Inline JSON: `--config '{"model":"opus"}'`

4. **Validation**: What happens with invalid settings?
   - Fail command
   - Use defaults with warning
   - Ask user to fix

5. **Discovery**: How do users know what settings are available?
   - `/agency:config` command to show current config?
   - `/agency:config --help` to show all options?
   - Documentation only?

## Status
**Status**: Open
**Priority**: Medium
**Blocking**: Phase 5 (Component Implementation - Settings)
