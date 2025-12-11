# Question 2: Interactive vs Automated Commands

## Context
Commands can either ask user questions (interactive) or run fully automated. Need to decide which pattern for each command.

## Question
Which commands should ask user questions vs. fully automated?

## Trade-offs

### Interactive Commands
**Pros**:
- User control and validation
- Clarify ambiguous requirements
- Safer for destructive operations

**Cons**:
- Slower workflow
- More user intervention required
- Interrupts flow

### Automated Commands
**Pros**:
- Fast execution
- Consistent behavior
- Can run in background

**Cons**:
- Less user control
- May make wrong assumptions
- Harder to abort mid-flow

## Examples

### Likely Interactive
- `/agency:work` - Should confirm plan before implementation?
- `/agency:gh-sprint` - Should ask which issues to include?
- `/agency:refactor` - Should confirm scope?

### Likely Automated
- `/agency:test` - Just generate tests based on code
- `/agency:document` - Just generate docs
- `/agency:gh-parallel` - Just find and report parallelizable issues

### Configurable?
- Could support `--auto` flag for automated mode
- Could support `--interactive` flag for step-by-step
- Could have user preference in settings

## Decision Needed
For each command, decide:
- Default behavior (interactive or automated)
- Whether to support override flags
- What questions to ask (if interactive)

## Status
**Status**: Open
**Priority**: High
**Blocking**: Phase 5 (Component Implementation)
