# Question 7: Hook Default Enablement

## Context
Hooks provide automated quality checks but can slow down workflows. Need to decide which are on by default.

## Question
Which hooks should be **enabled by default** vs **opt-in**?

## Proposed Hooks

### Hook 1: Auto-Format on Edit
**Impact**: Runs prettier/eslint on every edit
**Performance**: Fast (< 1 second for most files)
**Value**: High (ensures consistent formatting)

**Recommendation**: **Enabled by default**
- Fast enough not to be annoying
- High value for code quality
- Users can disable if preferred

### Hook 2: Auto-Lint Verification
**Impact**: Runs linter and reports issues on every edit
**Performance**: Fast to Medium (depends on file size)
**Value**: Medium (helpful but may be noisy)

**Recommendation**: **Opt-in**
- Can be noisy with many warnings
- May interrupt flow
- Better as user choice

### Hook 3: Pre-Commit Validation
**Impact**: Runs tests and linting before commits
**Performance**: Slow (can be 10+ seconds)
**Value**: Very High (prevents broken commits)

**Recommendation**: **Enabled by default**
- Critical quality gate
- Runs rarely (only on commit)
- Worth the wait time
- Users can override with --no-verify if needed

### Hook 4: Build Verification
**Impact**: Runs type check on every edit
**Performance**: Slow (5-30 seconds for large projects)
**Value**: High (catches type errors early)

**Recommendation**: **Opt-in**
- Too slow for every edit
- Better to run manually or in CI
- Could offer "on-demand" mode

### Hook 5: Test Auto-Run
**Impact**: Runs tests on every edit
**Performance**: Very Slow (depends on test suite)
**Value**: High (catches bugs early)

**Recommendation**: **Opt-in**
- Way too slow for every edit
- Better for TDD enthusiasts
- Could offer "watch mode" alternative

## Summary Recommendations

**Enabled by Default**:
- ✅ Auto-Format on Edit (fast + high value)
- ✅ Pre-Commit Validation (critical gate)

**Opt-In** (disabled by default):
- ⬜ Auto-Lint Verification (noisy)
- ⬜ Build Verification (slow)
- ⬜ Test Auto-Run (very slow)

## Alternative: Smart Defaults
Could detect project type and enable appropriate hooks:
- Small projects: Enable more hooks
- Large projects: Enable fewer hooks
- User can override in settings

## Decision Needed
- Confirm enabled-by-default hooks
- Should there be smart defaults based on project size?
- How to make opt-in hooks easy to discover and enable?

## Status
**Status**: Open
**Priority**: Medium
**Blocking**: Phase 5 (Component Implementation)
