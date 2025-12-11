# Question 6: Skill Examples Approach

## Context
Skills can include various types of examples to illustrate concepts and provide reusable code.

## Question
Should skills include working code examples or just patterns/checklists?

## Options

### Option A: Patterns & Checklists Only
**Example Content**:
- Conceptual workflow diagrams
- Step-by-step checklists
- Decision trees
- Best practice lists

**Pros**:
- Language/framework agnostic
- Easier to maintain
- Focus on concepts not implementation

**Cons**:
- Less concrete
- Users must translate to code
- Less immediately useful

### Option B: Working Code Examples
**Example Content**:
- Complete working scripts
- Code snippets
- Configuration files
- Real implementation examples

**Pros**:
- Immediately useful
- Copy-paste ready
- Clear and concrete
- Shows actual implementation

**Cons**:
- May become outdated
- Framework/language specific
- More maintenance required

### Option C: Hybrid (Recommended)
**Structure**:
- SKILL.md: Patterns and checklists (conceptual)
- examples/: Working code examples (concrete)
- references/: Deep dives on specific topics

**Example for GitHub Workflow Best Practices**:
- SKILL.md: Branching strategy checklist, PR review criteria
- examples/commit-message-good-examples.md: Real commit messages
- examples/pr-description-template.md: PR template
- references/git-worktree-guide.md: Detailed worktree usage

**Pros**:
- Best of both worlds
- Conceptual guidance + practical examples
- Organized by use case
- Easy to find what you need

**Cons**:
- More files to create
- Requires organization

## Recommendation
**Use Option C: Hybrid Approach**

For each skill:
1. **SKILL.md**: Conceptual patterns, checklists, decision frameworks
2. **examples/**: 3-5 working examples of common scenarios
3. **references/**: Deep dives for complex topics

## Decision Needed
- Confirm hybrid approach
- How many examples per skill? (suggest 3-5)
- What format for examples? (markdown with code blocks or actual executable files?)
- Language/framework for code examples? (TypeScript/JavaScript since most commands use GitHub/Node.js?)

## Status
**Status**: Open
**Priority**: Low
**Blocking**: Phase 5 (Component Implementation)
