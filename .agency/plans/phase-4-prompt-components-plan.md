# Phase 4 Implementation Plan: Additional Prompt Components & Command Refactoring

**Created**: 2024-12-11
**Status**: Planning Complete, Ready for Implementation
**Agent ID for Continuation**: aeb93c0

---

## Executive Summary

Comprehensive plan to create 38+ reusable prompt components and refactor all 14 command files, achieving a **70% line reduction** (13,442 → 4,245 lines).

**Impact**:
- **38 new components** organized in 8 categories
- **Average 6.4 uses per component** (high reuse)
- **13,197 lines eliminated** through deduplication
- **Consistent behavior** across all commands
- **Single source of truth** for all workflows

---

## Current State Analysis

### Duplication Patterns Identified

| Pattern | Current Lines | After Components | Reduction | Commands Affected |
|---------|--------------|------------------|-----------|-------------------|
| Project Context Detection | 2,200 | 250 | 88% | 11 commands |
| Quality Gate Sequences | 1,400 | 180 | 87% | 7 commands |
| Git Operations | 1,100 | 150 | 86% | 9 commands |
| Error Handling | 1,800 | 200 | 89% | All 14 commands |
| Issue/PR Parsing | 800 | 120 | 85% | 6 commands |
| TodoWrite Tracking | 600 | 80 | 87% | 10 commands |
| Specialist Spawning | 1,200 | 180 | 85% | 12 commands |
| Reporting Templates | 1,400 | 180 | 87% | 11 commands |
| **TOTAL** | **10,500** | **1,340** | **87%** | - |

---

## Proposed Components (38 Total)

### Category 1: Project Context & Detection (6 components)

1. **`context/framework-detection.md`**
   - Detect framework (Next.js, Django, Laravel, FastAPI, etc.)
   - Used in: 11 commands
   - Saves: 2,000 lines

2. **`context/testing-framework-detection.md`**
   - Detect test framework (Jest, Vitest, pytest, Playwright)
   - Used in: 7 commands
   - Saves: 640 lines

3. **`context/database-detection.md`**
   - Detect database/ORM (Prisma, Drizzle, Supabase, SQLAlchemy)
   - Used in: 8 commands
   - Saves: 730 lines

4. **`context/build-tool-detection.md`**
   - Detect build tool (webpack, Vite, Rollup, Next.js)
   - Used in: 4 commands
   - Saves: 280 lines

5. **`context/documentation-system-detection.md`**
   - Detect docs system (MkDocs, Docusaurus, Storybook)
   - Used in: 2 commands
   - Saves: 135 lines

6. **`context/project-size-detection.md`**
   - Categorize project size (small/medium/large)
   - Used in: 4 commands
   - Saves: 175 lines

**Category Total**: 3,960 lines saved

---

### Category 2: Quality Gates & Verification (7 components)

7. **`quality-gates/build-verification.md`**
   - Run build and verify success
   - Used in: 7 commands
   - Saves: 480 lines

8. **`quality-gates/type-checking.md`**
   - TypeScript type checking
   - Used in: 6 commands
   - Saves: 250 lines

9. **`quality-gates/linting.md`**
   - Run linter and handle errors/warnings
   - Used in: 6 commands
   - Saves: 200 lines

10. **`quality-gates/test-execution.md`**
    - Run test suite
    - Used in: 7 commands
    - Saves: 540 lines

11. **`quality-gates/coverage-validation.md`**
    - Validate test coverage
    - Used in: 5 commands
    - Saves: 240 lines

12. **`quality-gates/security-scan-quick.md`**
    - Quick security scan (npm audit, secrets)
    - Used in: 4 commands
    - Saves: 260 lines

13. **`quality-gates/rollback-on-failure.md`**
    - Standardized rollback procedure
    - Used in: 6 commands
    - Saves: 300 lines

**Category Total**: 2,270 lines saved

---

### Category 3: Git Operations (5 components)

14. **`git/branch-creation.md`**
    - Create feature/bugfix/refactor branches
    - Used in: 5 commands
    - Saves: 200 lines

15. **`git/commit-formatting.md`**
    - Conventional commit format
    - Used in: 8 commands
    - Saves: 490 lines

16. **`git/pr-creation.md`**
    - Create PR with template
    - Used in: 5 commands
    - Saves: 400 lines

17. **`git/status-validation.md`**
    - Check uncommitted changes
    - Used in: 4 commands
    - Saves: 120 lines

18. **`git/tag-creation.md`**
    - Create deployment/release tags
    - Used in: 2 commands
    - Saves: 40 lines

**Category Total**: 1,250 lines saved

---

### Category 4: Issue & PR Management (4 components)

19. **`issue-management/github-issue-fetch.md`**
    - Fetch GitHub issue with gh CLI
    - Used in: 4 commands
    - Saves: 240 lines

20. **`issue-management/jira-issue-fetch.md`**
    - Fetch Jira issue with acli
    - Used in: 4 commands
    - Saves: 270 lines

21. **`issue-management/issue-metadata-extraction.md`**
    - Extract title, description, labels
    - Used in: 4 commands
    - Saves: 150 lines

22. **`issue-management/dependency-parsing.md`**
    - Parse "depends on #123" patterns
    - Used in: 3 commands
    - Saves: 80 lines

**Category Total**: 740 lines saved

---

### Category 5: Error Handling (6 components)

23. **`error-handling/scope-detection-failure.md`**
    - Handle ambiguous scope detection
    - Used in: All 14 commands
    - Saves: 520 lines

24. **`error-handling/tool-execution-failure.md`**
    - Handle CLI tool failures
    - Used in: All 14 commands
    - Saves: 650 lines

25. **`error-handling/user-cancellation.md`**
    - Clean up on user cancel
    - Used in: 12 commands
    - Saves: 330 lines

26. **`error-handling/timeout-handling.md`**
    - Handle long-running operations
    - Used in: 4 commands
    - Saves: 120 lines

27. **`error-handling/partial-failure-recovery.md`**
    - Handle partial successes
    - Used in: 4 commands
    - Saves: 150 lines

28. **`error-handling/ask-user-retry.md`**
    - Standardized retry/skip/abort
    - Used in: 10 commands
    - Saves: 360 lines

**Category Total**: 2,130 lines saved

---

### Category 6: Progress Tracking (3 components)

29. **`progress/todo-initialization.md`**
    - Create TodoWrite list
    - Used in: 10 commands
    - Saves: 360 lines

30. **`progress/phase-tracking.md`**
    - Update TodoWrite as phases complete
    - Used in: 8 commands
    - Saves: 210 lines

31. **`progress/completion-reporting.md`**
    - Final TodoWrite summary
    - Used in: 11 commands
    - Saves: 297 lines

**Category Total**: 867 lines saved

---

### Category 7: Specialist Selection (3 components)

32. **`specialist-selection/keyword-analysis.md`** (ENHANCE EXISTING)
    - Add keywords for security, docs, deployment
    - Already exists from Phase 3

33. **`specialist-selection/multi-specialist-routing.md`** (NEW)
    - Route to multiple specialists with handoff
    - Used in: 4 commands
    - Saves: 560 lines

34. **`specialist-selection/skill-activation.md`** (NEW)
    - Activate appropriate skills
    - Used in: 7 commands
    - Saves: 480 lines

**Category Total**: 1,040 lines saved

---

### Category 8: Reporting & Documentation (4 components)

35. **`reporting/summary-template.md`** (EXISTING - Phase 3)
    - Already completed

36. **`reporting/metrics-comparison.md`** (NEW)
    - Before/after metrics table
    - Used in: 4 commands
    - Saves: 280 lines

37. **`reporting/artifact-listing.md`** (NEW)
    - List generated files/reports
    - Used in: 10 commands
    - Saves: 360 lines

38. **`reporting/next-steps-template.md`** (NEW)
    - Standardized recommendations
    - Used in: 6 commands
    - Saves: 300 lines

**Category Total**: 940 lines saved

---

## Total Impact Summary

| Category | Components | Lines Saved | Avg Uses |
|----------|-----------|-------------|----------|
| Project Context | 6 | 3,960 | 6.3 |
| Quality Gates | 7 | 2,270 | 5.4 |
| Git Operations | 5 | 1,250 | 4.8 |
| Issue Management | 4 | 740 | 3.8 |
| Error Handling | 6 | 2,130 | 9.3 |
| Progress Tracking | 3 | 867 | 9.7 |
| Specialist Selection | 3 | 1,040 | 6.0 |
| Reporting | 4 | 940 | 6.0 |
| **TOTAL** | **38** | **13,197** | **6.4** |

---

## Critical Files for Implementation

1. **commands/work.md** - Central orchestrator, uses almost all components
2. **commands/refactor.md** - Largest unrefactored (1,617 lines)
3. **commands/sprint.md** - Most complex multi-issue workflow (1,722 lines)
4. **prompts/README.md** - Documentation hub for all components
5. **commands/optimize.md** - Third largest (1,253 lines)

---

## Implementation Priority

### Week 1: Foundation Components (Days 1-5)
- **Days 1-2**: Project Context components (6 components)
  - framework-detection, testing-framework-detection, database-detection
  - build-tool-detection, documentation-system-detection, project-size-detection

- **Days 3-4**: Error Handling components (6 components)
  - scope-detection-failure, tool-execution-failure, user-cancellation
  - timeout-handling, partial-failure-recovery, ask-user-retry

- **Day 5**: Progress Tracking components (3 components)
  - todo-initialization, phase-tracking, completion-reporting

**Week 1 Total**: 15 components created

---

### Week 2: Quality & Git Components (Days 6-10)
- **Days 6-7**: Quality Gates components (7 components)
  - build-verification, type-checking, linting
  - test-execution, coverage-validation, security-scan-quick, rollback-on-failure

- **Days 8-9**: Git Operations components (5 components)
  - branch-creation, commit-formatting, pr-creation
  - status-validation, tag-creation

- **Day 10**: Issue Management components (4 components)
  - github-issue-fetch, jira-issue-fetch
  - issue-metadata-extraction, dependency-parsing

**Week 2 Total**: 16 components created

---

### Week 3: Advanced & Reporting Components (Days 11-15)
- **Days 11-12**: Specialist Selection components (3 components)
  - Enhance keyword-analysis with security/docs/deployment keywords
  - multi-specialist-routing
  - skill-activation

- **Days 13-14**: Reporting components (4 components)
  - metrics-comparison, artifact-listing, next-steps-template
  - (summary-template already exists)

- **Day 15**: Update prompts/README.md with all 38 components

**Week 3 Total**: 7 new components + 1 enhancement + README update

---

### Week 4: High-Priority Command Refactoring (Days 16-20)
- **Day 16**: Refactor work.md (800+ lines → ~280 lines)
- **Day 17**: Refactor refactor.md (1,617 lines → ~520 lines)
- **Day 18**: Refactor sprint.md (1,722 lines → ~550 lines)
- **Day 19**: Refactor optimize.md (1,253 lines → ~400 lines)
- **Day 20**: Refactor test.md (~600 lines → ~200 lines)

**Week 4 Total**: 5 commands refactored

---

### Week 5: Medium-Priority Command Refactoring (Days 21-25)
- **Day 21**: Refactor plan.md (~500 lines → ~180 lines)
- **Day 22**: Refactor review.md (~700 lines → ~240 lines)
- **Day 23**: Refactor deploy.md (~800 lines → ~280 lines)
- **Day 24**: Refactor document.md (~600 lines → ~210 lines)
- **Day 25**: Refactor security.md (~550 lines → ~190 lines)

**Week 5 Total**: 5 commands refactored

---

### Week 6: Final Commands & Testing (Days 26-30)
- **Day 26**: Refactor adr.md (~450 lines → ~160 lines)
- **Day 27**: Refactor help.md (minimal changes, mostly links)
- **Days 28-29**: Comprehensive testing
  - Test each command with components
  - Verify backward compatibility
  - Test multi-specialist workflows
- **Day 30**: Final documentation and cleanup

**Week 6 Total**: 2 commands refactored + testing

---

## Success Metrics

**Quantitative**:
- ✅ 70% line reduction: 13,442 → 4,245 lines
- ✅ 38 components with 6.4 average uses per component
- ✅ All 14 commands refactored
- ✅ Zero breaking changes (backward compatible)

**Qualitative**:
- ✅ Single source of truth for all workflows
- ✅ Consistent behavior across commands
- ✅ Easier maintenance (update one component, all commands benefit)
- ✅ Faster command development (compose from components)

---

## Validation Strategy

### Per-Component Validation
- **Unit test each component** with sample inputs
- **Verify component used correctly** in at least 2 commands
- **Check documentation** is clear and complete
- **Ensure backward compatibility** with existing workflows

### Per-Command Validation
- **Before/after line count** matches target
- **All phases execute correctly** end-to-end
- **TodoWrite tracking** works as expected
- **Error handling** covers edge cases
- **User experience** unchanged or improved

### Integration Testing
- **Multi-specialist workflows** function correctly
- **Component composition** works smoothly
- **No circular dependencies** between components
- **Performance** not degraded

---

## Risk Mitigation

### Risk 1: Breaking Changes
**Mitigation**:
- Test each refactored command thoroughly
- Keep original commands as backups during transition
- Use feature flags if needed

### Risk 2: Component Over-Engineering
**Mitigation**:
- Only create components used by 2+ commands
- Keep components focused and single-purpose
- Avoid premature abstraction

### Risk 3: Implementation Timeline Slip
**Mitigation**:
- Prioritize high-impact components first
- Can ship incrementally (some commands refactored, some not)
- Buffer time built into week 6

---

## Next Steps

1. **Review this plan** with stakeholders
2. **Create component templates** for consistency
3. **Begin Week 1** implementation (foundation components)
4. **Track progress** with weekly milestones
5. **Adjust plan** based on learnings from early components

---

**Plan Status**: Ready for Implementation
**Estimated Completion**: 6 weeks
**Agent ID for Continuation**: aeb93c0 (resume the planning agent for Part 2 if needed)
