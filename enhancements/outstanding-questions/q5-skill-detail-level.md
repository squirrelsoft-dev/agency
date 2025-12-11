# Question 5: Skill Detail Level

## Context
Skills can be structured with different levels of detail and progressive disclosure.

## Question
What detail level should skills follow?

## Options

### Option A: Lean Core (1,500-2,000 words)
**Structure**:
- SKILL.md: 1,500-2,000 word core
- Link to external docs for details

**Pros**:
- Fast to load and read
- Keeps context lean
- Easy to maintain

**Cons**:
- May miss important details
- Requires external doc maintenance
- Less self-contained

### Option B: Comprehensive (3,000-5,000 words)
**Structure**:
- SKILL.md: 3,000-5,000 words with everything inline

**Pros**:
- All information in one place
- Self-contained
- No external dependencies

**Cons**:
- Larger context usage
- Harder to skim
- May overwhelm with detail

### Option C: Progressive Disclosure (Recommended)
**Structure**:
- SKILL.md: 1,500-2,000 word core (lean, imperative form)
- references/: Detailed documentation
- examples/: Working code examples
- scripts/: Utility scripts (if needed)

**Pros**:
- Best of both worlds
- Claude can reference details as needed
- Organized and maintainable
- Follows plugin-dev best practices

**Cons**:
- More files to manage
- Requires thoughtful organization

## Recommendation
**Use Option C: Progressive Disclosure**

This matches the plugin-dev pattern and provides:
- Quick overview in main skill
- Deep details in references/
- Practical examples in examples/
- Reusable utilities in scripts/ (if needed)

## Decision Needed
- Confirm Option C progressive disclosure approach
- Define what goes in core vs references vs examples
- Set word count targets for each section

## Status
**Status**: Open
**Priority**: Medium
**Blocking**: Phase 5 (Component Implementation)
