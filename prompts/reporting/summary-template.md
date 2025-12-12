# Reporting: Implementation Summary Template

Standardized format for implementation summary reports.

## When to Use

**After implementation completes**:
- In `implement.md` Phase 6
- In `work.md` final step
- In `sprint.md` after each issue

**Purpose**: Consistent reporting format for all implementations.

---

## File Location

```bash
# Generate filename
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FEATURE_NAME=[extracted from plan filename or issue ID]
SUMMARY_FILE=".agency/implementations/impl-${FEATURE_NAME}-${TIMESTAMP}.md"
```

**Directory**: `.agency/implementations/`
**Filename Pattern**: `impl-[feature-name]-[timestamp].md`

**Examples**:
- `.agency/implementations/impl-user-authentication-20241211-143022.md`
- `.agency/implementations/impl-issue-123-20241211-150000.md`

---

## Template Structure

```markdown
# Implementation Summary: [Feature Name]

**Date**: [YYYY-MM-DD HH:MM:SS]
**Plan**: [Plan file path or issue reference]
**Specialist**: [Selected specialist(s)]
**Duration**: [Approximate time taken]
**Status**: ✅ SUCCESS / ⚠️ PARTIAL / ❌ FAILED

---

## Objective

[Brief description of what was built - 1-3 sentences]

---

## Requirements Implemented

- [x] Requirement 1 - [Brief description]
- [x] Requirement 2 - [Brief description]
- [x] Requirement 3 - [Brief description]
- [ ] Requirement 4 - [If not completed, explain why]

**Completion**: [X/Y] requirements ([Z]%)

---

## Files Changed

### Created ([X] files)

- `path/to/file1.ts` - [Brief description of what this file does]
- `path/to/file2.tsx` - [Brief description]

### Modified ([Y] files)

- `path/to/file3.ts` - [What changed and why]
- `path/to/file4.tsx` - [What changed and why]

### Deleted ([Z] files)

- `path/to/file5.ts` - [Why deleted]

**Total Changes**: +[X] lines, -[Y] lines across [Z] files

---

## Verification Results

### Build: ✅ PASS / ❌ FAIL

[If FAIL: Build output summary, error count, top errors]

### Type Check: ✅ PASS / ❌ FAIL

[If FAIL: Type error count, critical type errors]

### Linter: ✅ PASS / ⚠️ WARNINGS / ❌ FAIL

- Errors: [X]
- Warnings: [Y]

[If errors/warnings: Summary of main issues]

### Tests: ✅ PASS / ❌ FAIL

- Total: [X] tests
- Passed: [Y] tests
- Failed: [Z] tests
- Skipped: [W] tests

[If FAIL: List failed tests and reasons]

### Coverage: [X]%

- Target: 80%
- Actual: [X]%
- Line Coverage: [X]%
- Branch Coverage: [Y]%
- Function Coverage: [Z]%

[If below target: Coverage gaps by file/area]

---

## Code Review Findings

### Critical Issues: [X]

[If any, list each with:
- File and line number
- Issue description
- Fix applied or reason not fixed]

OR "None"

### High Priority Issues: [X]

[If any, list each with same format]

OR "None"

### Medium/Low Issues: [X]

[Brief summary, not full list]

OR "None"

**Review Status**: ✅ APPROVED / ⚠️ APPROVED WITH NOTES / ❌ CHANGES REQUIRED

---

## Success Criteria Status

[For each criterion from the plan:]

- [x] **Criterion 1**: [Description] - ✅ Met
- [x] **Criterion 2**: [Description] - ✅ Met
- [ ] **Criterion 3**: [Description] - ⚠️ Partially met - [Explanation]
- [ ] **Criterion 4**: [Description] - ❌ Not met - [Reason]

**Overall**: [X/Y] criteria met ([Z]%)

---

## Technical Decisions

[Document any significant technical decisions made during implementation:]

- **Decision 1**: [What was decided and why]
- **Decision 2**: [What was decided and why]

[If ADRs created, link to them]

---

## Known Issues / Limitations

[Document any known issues, limitations, or technical debt:]

- **Issue 1**: [Description, impact, recommendation]
- **Issue 2**: [Description, impact, recommendation]

OR "None identified"

---

## Next Steps

[If all criteria met]:
- ✅ Ready for commit and PR creation
- Consider running `/agency:review` for additional review
- Consider running `/agency:test` if test coverage below 80%
- Deploy to [environment] for testing

[If issues remain]:
- ❌ Address [X] critical issues before proceeding
- Re-run verification after fixes
- Consider additional testing for [area]
- Escalate [issue] to team

---

## Performance Notes

[If performance was measured:]

- Benchmark 1: [Metric] - [Result]
- Benchmark 2: [Metric] - [Result]

OR "No performance testing conducted"

---

## Security Notes

[If security was considered:]

- Security measure 1: [Implemented/Verified]
- Security measure 2: [Implemented/Verified]
- Security review: [PASSED/CONCERNS]

OR "Standard security practices applied"

---

## Dependencies Added/Updated

[If dependencies changed:]

### Added
- `package@version` - [Why added]

### Updated
- `package@old-version` → `new-version` - [Why updated]

### Removed
- `package@version` - [Why removed]

OR "No dependency changes"

---

## Notes

[Any important notes, gotchas, or context for future maintainers:]

- Note 1
- Note 2
- Note 3

---

## Related Resources

- **Plan**: [Link to plan file]
- **Issue**: [Link to GitHub/Jira issue if applicable]
- **PR**: [Link to PR if created]
- **ADRs**: [Links to related ADRs]
- **Documentation**: [Links to updated docs]
```

---

## Multi-Specialist Summary Extension

**For multi-specialist workflows**, add this section after "Specialist":

```markdown
## Specialists Involved

### Backend Architect

**Responsibilities**:
- API endpoints
- Database schema
- Authentication

**Files Changed**: [X] created, [Y] modified
**Status**: ✅ Verified
**Summary**: [Link to .agency/handoff/{feature}/backend-architect/summary.md]

### Frontend Developer

**Responsibilities**:
- Login/register forms
- Protected routes
- User profile UI

**Files Changed**: [X] created, [Y] modified
**Status**: ✅ Verified
**Summary**: [Link to .agency/handoff/{feature}/frontend-developer/summary.md]

### Integration Review

**Status**: ✅ PASS / ⚠️ ISSUES FOUND / ❌ FAIL
**Findings**: [Cross-specialist integration issues if any]
```

---

## Summary Quality Checklist

Before finalizing summary, verify:

- [ ] All sections filled out (no [TBD] or blank sections)
- [ ] Accurate file change counts
- [ ] All verification results documented
- [ ] Code review findings captured
- [ ] Success criteria status complete
- [ ] Next steps are actionable
- [ ] Timestamp and metadata correct

---

## Report to User (Concise Version)

After saving full summary, show user a concise version:

```markdown
## Implementation Complete: [Feature Name]

**Status**: ✅ SUCCESS / ⚠️ PARTIAL / ❌ FAILED

**Specialist**: [Selected specialist(s)]

**Verification**:
- Build: [✅/❌]
- Type Check: [✅/❌]
- Linter: [✅/⚠️/❌]
- Tests: [X/Y passed] ([Z]%)
- Coverage: [X]%

**Code Review**:
- Critical: [X]
- High: [X]
- Medium/Low: [X]

**Files Changed**: [X] created, [Y] modified, [Z] deleted

**Summary Report**: [PATH_TO_SUMMARY_FILE]

**Next Steps**:
[Recommended actions based on results]
```
