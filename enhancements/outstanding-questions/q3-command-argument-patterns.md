# Question 3: Command Argument Patterns

## Context
Commands need to accept various input formats for flexibility and ease of use.

## Question
Should commands accept multiple argument formats, and if so, which ones?

## Proposed Argument Patterns

### Issue Number
```bash
/agency:work 123
```
- Simple and common
- Assumes context (current repo)

### Full URL
```bash
/agency:work https://github.com/owner/repo/issues/123
```
- Explicit and unambiguous
- Works across repos
- More typing required

### Auto-detect Next
```bash
/agency:work next
```
- Convenient for sequential workflow
- Requires smart detection logic
- May pick wrong issue

### Multiple Issues
```bash
/agency:work 123 124 125
```
- Batch operations
- Parallel execution potential
- More complex orchestration

### Filter/Query
```bash
/agency:gh-sprint label:priority-high
/agency:gh-triage assignee:me state:open
```
- Flexible issue selection
- GitHub/Jira query syntax
- Most powerful but complex

## Recommendations

### Minimum Viable
All commands should support:
1. Issue number: `/agency:work 123`
2. Full URL: `/agency:work https://...`

### Nice to Have
- `next` keyword for auto-detection
- Multiple issues for batch operations

### Advanced
- Filter/query syntax for power users

## Implementation Considerations

- How to detect which format is being used?
- How to validate inputs?
- Error messages for invalid formats?
- Should there be command-specific argument patterns?

## Decision Needed
- Which argument patterns to support in Phase 1?
- Which to defer to Phase 2?
- Standardize across all commands or allow variation?

## Status
**Status**: Open
**Priority**: Medium
**Blocking**: Phase 5 (Component Implementation)
