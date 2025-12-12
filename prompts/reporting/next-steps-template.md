# Reporting: Next Steps Template

Standardized format for generating contextual "what to do next" recommendations based on implementation results.

## When to Use

**Include next steps in**:
- Implementation summaries
- Code review reports
- Verification results
- Multi-specialist handoffs
- Sprint completions

**Purpose**: Provide clear, actionable guidance on what to do after current work completes.

---

## Decision Tree for Next Steps

### Based on Implementation Status

```
IF status = SUCCESS AND all_verification_passed:
  → Ready for Deployment Path

ELSE IF status = SUCCESS AND some_issues_remain:
  → Conditional Deployment Path

ELSE IF status = PARTIAL:
  → Additional Work Required Path

ELSE IF status = FAILED:
  → Remediation Required Path
```

---

## Next Steps Templates

### 1. Ready for Deployment (Full Success)

**When**:
- ✅ All requirements implemented
- ✅ Build passes
- ✅ Type check passes
- ✅ All tests pass
- ✅ Coverage ≥ 80%
- ✅ No critical or high code review issues
- ✅ All success criteria met

**Template**:
```markdown
## Next Steps

### ✅ Ready for Deployment

This implementation is complete and ready to proceed.

**Recommended Actions**:

1. **Create Git Commit**
   ```bash
   git add .
   git commit -m "feat: [feature description]"
   ```
   - Review changed files before committing
   - Use conventional commit format

2. **Create Pull Request**
   ```bash
   gh pr create --title "[PR Title]" --body "..."
   ```
   - Link to original issue/plan
   - Include implementation summary
   - Add reviewers

3. **Optional: Additional Review**
   - Run `/agency:review [pr-url]` for deeper code review
   - Consider peer review for critical features
   - Security review for authentication/authorization changes

4. **Optional: Additional Testing**
   - Run `/agency:test [component]` to add more tests if coverage < 90%
   - Consider E2E tests for critical user flows
   - Load testing for performance-critical features

5. **Deployment**
   - Merge PR after approval
   - Deploy to staging environment
   - Verify functionality in staging
   - Deploy to production

**Documentation**:
- Implementation summary: [path]
- Code review report: [path]

**No Blockers**: All quality gates passed. Safe to proceed.
```

---

### 2. Conditional Deployment (Minor Issues)

**When**:
- ✅ All requirements implemented
- ✅ Build passes
- ✅ Tests pass
- ⚠️ Coverage 70-79% (below target but acceptable)
- ⚠️ Some medium/low code review issues
- ⚠️ Some non-critical success criteria partially met

**Template**:
```markdown
## Next Steps

### ⚠️ Ready with Recommendations

Implementation is functional but has minor issues to address.

**Required Actions**:

1. **Address Medium Priority Issues** (if time permits)
   - [Issue 1 from code review]
   - [Issue 2 from code review]
   - [Issue 3 from code review]

2. **Improve Test Coverage** (optional)
   - Current: [X]%
   - Target: 80%
   - Gap: [files/modules with low coverage]
   - Run `/agency:test [component]` to add tests

**Proceed Actions**:

3. **Create Git Commit**
   ```bash
   git add .
   git commit -m "feat: [feature description]"
   ```

4. **Create Pull Request**
   ```bash
   gh pr create --title "[PR Title]" --body "..."
   ```
   - Note known issues in PR description
   - Request review feedback on medium issues
   - Add "Technical Debt" label if applicable

5. **Document Known Issues**
   - Add TODO comments for medium issues
   - Create follow-up issues for improvements
   - Update documentation with limitations

**Recommendations**:
- Consider addressing medium issues before deployment
- Plan follow-up iteration for coverage improvement
- Monitor for issues in staging deployment

**Minor Blockers**: [X] medium issues, [Y]% coverage gap
**Risk Level**: Low - safe to deploy with noted limitations
```

---

### 3. Additional Work Required (Partial Success)

**When**:
- ⚠️ Most requirements implemented
- ⚠️ Build passes with warnings
- ⚠️ Some tests fail (non-critical)
- ❌ Coverage < 70%
- ⚠️ High priority code review issues found
- ⚠️ Some critical success criteria not met

**Template**:
```markdown
## Next Steps

### 🔧 Additional Work Required

Implementation is partially complete. Address issues before deployment.

**Critical Actions Required**:

1. **Fix High Priority Issues**
   - [ ] [High issue 1 from code review]
   - [ ] [High issue 2 from code review]
   - [ ] [High issue 3 from code review]

2. **Complete Missing Requirements**
   - [ ] [Requirement 1 not fully implemented]
   - [ ] [Requirement 2 needs completion]

3. **Improve Test Coverage**
   - Current: [X]%
   - Required: 80%
   - Focus areas:
     - [Module 1 with low coverage]
     - [Module 2 with low coverage]
   - Action: Run `/agency:test [component]`

4. **Fix Failing Tests**
   - [Test 1 failing]
   - [Test 2 failing]
   - Root cause analysis needed

**After Fixes Complete**:

5. **Re-run Verification**
   ```bash
   npm run build
   npm test
   npm run lint
   ```

6. **Re-run Code Review**
   - Spawn reality-checker again
   - Verify all high priority issues resolved

7. **Update Implementation Summary**
   - Document fixes applied
   - Update verification results

**Then Proceed**:
- Create git commit
- Create pull request
- Deploy

**Blockers**: [X] high priority issues, [Y] incomplete requirements, [Z]% coverage gap
**Risk Level**: Medium - requires fixes before deployment
**Estimated Effort**: [X] hours to address issues
```

---

### 4. Remediation Required (Failure)

**When**:
- ❌ Build fails
- ❌ Type check fails
- ❌ Critical tests fail
- ❌ Critical code review issues
- ❌ Core requirements not implemented
- ❌ Critical success criteria not met

**Template**:
```markdown
## Next Steps

### ❌ Remediation Required

Implementation has critical issues. Do NOT deploy.

**Critical Blockers**:

1. **Build Failures**
   - Error count: [X]
   - Top errors:
     - [Error 1]
     - [Error 2]
     - [Error 3]
   - Action: Fix build errors immediately

2. **Critical Code Issues**
   - [Critical issue 1 - security vulnerability]
   - [Critical issue 2 - data loss risk]
   - [Critical issue 3 - breaking change]
   - Action: Address all critical issues before proceeding

3. **Failed Tests**
   - [X] tests failing
   - Critical failures:
     - [Test 1 - affects core functionality]
     - [Test 2 - data integrity]
   - Action: Fix failing tests

4. **Missing Core Requirements**
   - [ ] [Core requirement 1 not implemented]
   - [ ] [Core requirement 2 incomplete]
   - Action: Complete core functionality

**Remediation Steps**:

1. **Analyze Root Causes**
   - Review error logs
   - Identify systemic issues
   - Determine if approach needs revision

2. **Create Fix Plan**
   - Prioritize critical issues
   - Estimate fix effort
   - Identify blockers

3. **Execute Fixes**
   - Fix build errors first
   - Address critical security/data issues
   - Fix core functionality gaps
   - Fix failing tests

4. **Re-verify Completely**
   - Re-run all verification steps
   - Re-run code review
   - Ensure all critical issues resolved

5. **Consider Alternative Approaches**
   - If fixes are extensive, consider:
     - Revising implementation plan
     - Breaking into smaller iterations
     - Seeking expert consultation

**Do NOT Proceed Until**:
- ✅ Build passes
- ✅ Type check passes
- ✅ All critical tests pass
- ✅ All critical code issues resolved
- ✅ Core requirements implemented

**Risk Level**: High - not deployable in current state
**Estimated Effort**: [X] hours/days for remediation
**Escalation**: Consider escalating to senior developer if issues persist
```

---

## Multi-Specialist Next Steps

### After Each Specialist Completes

```markdown
## Next Steps: [Specialist] Complete

### Current Status

**Completed**: [SPECIALIST] work
**Verification**: ✅ PASSED / ❌ FAILED
**Next Specialist**: [NEXT_SPECIALIST]

**Actions**:

1. **[IF verification PASSED]**
   - ✅ Handoff artifacts ready
   - Mark specialist complete in execution-state.json
   - Unblock next specialist: [NEXT_SPECIALIST]
   - Next specialist can begin work

2. **[IF verification FAILED]**
   - ❌ Critical issues found: [X]
   - Fix iteration [X/3] in progress
   - [NEXT_SPECIALIST] remains blocked
   - Wait for fixes and re-verification

**Handoff Review**:
- Review `[SPECIALIST]/summary.md` for key details
- Check `integration/` for shared contracts
- Verify files-changed.json accuracy

**Integration Points for [NEXT_SPECIALIST]**:
- [Integration point 1]
- [Integration point 2]
- [Integration point 3]
```

### After All Specialists Complete

```markdown
## Next Steps: Multi-Specialist Integration

### All Specialists Complete

**Completed**:
- ✅ Backend Architect - [X] files
- ✅ Frontend Developer - [Y] files
- ✅ [Other specialists...]

**Status**: All individual work verified

**Actions**:

1. **Run Integration Review**
   - Spawn code-reviewer for cross-specialist integration
   - Focus: API contracts, type consistency, architecture
   - Check: Security across boundaries, error handling alignment

2. **[IF integration review PASSES]**
   - Proceed to final verification
   - Run full build and test suite
   - Create aggregated implementation summary
   - Ready for deployment path

3. **[IF integration issues found]**
   - Identify affected specialists
   - Create fix tasks per specialist
   - Re-spawn affected specialists for integration fixes
   - Re-verify integration (max 2 iterations)

4. **Create Aggregated Summary**
   - Combine all specialist summaries
   - Document integration review results
   - List all files changed across specialists
   - Provide unified next steps

5. **Archive Handoff Artifacts**
   ```bash
   tar -czf .agency/handoff/[feature]/archive/handoff-$(date +%Y%m%d-%H%M%S).tar.gz \
     .agency/handoff/[feature]/**/*.md
   ```

**Integration Quality Gates**:
- ✅ API contracts match
- ✅ Type definitions consistent
- ✅ Error handling aligned
- ✅ Security complete end-to-end
- ✅ No integration gaps

**Proceed When**: All integration quality gates passed
```

---

## Contextual Recommendations

### Based on Feature Type

#### Authentication/Security Features

```markdown
**Additional Security Steps**:

1. **Security Review**
   - Review authentication flow end-to-end
   - Verify password hashing (bcrypt, Argon2)
   - Check JWT token security
   - Validate input sanitization
   - Test session management

2. **Penetration Testing** (if critical)
   - Test SQL injection vulnerabilities
   - Test XSS vulnerabilities
   - Test CSRF protection
   - Test authentication bypass attempts

3. **Security Documentation**
   - Document authentication flow
   - Document authorization rules
   - Document security assumptions
   - Add security testing guide

**Deploy to Staging First**: Critical security features require staging validation
```

#### Performance-Critical Features

```markdown
**Additional Performance Steps**:

1. **Performance Testing**
   - Run load tests
   - Measure Core Web Vitals
   - Test under expected traffic
   - Identify bottlenecks

2. **Optimization Review**
   - Review database query efficiency
   - Check N+1 query patterns
   - Verify caching implementation
   - Analyze bundle size

3. **Monitoring Setup**
   - Add performance monitoring
   - Set up alerts for regressions
   - Track key metrics in production
   - Create performance dashboard

**Gradual Rollout**: Consider feature flags for performance-critical changes
```

#### Database Schema Changes

```markdown
**Additional Database Steps**:

1. **Migration Verification**
   - Test migration on staging database
   - Verify rollback procedure works
   - Check migration performance
   - Validate data integrity

2. **Backup Strategy**
   - Backup production database before migration
   - Document rollback steps
   - Test restore procedure
   - Plan maintenance window

3. **Data Migration**
   - If data migration needed, test thoroughly
   - Verify data transformation logic
   - Check for data loss
   - Validate constraints

**Staged Deployment**: Run migration on staging → production with backups
```

#### Breaking API Changes

```markdown
**Additional API Steps**:

1. **API Versioning**
   - Implement API versioning (v1, v2)
   - Maintain backward compatibility
   - Document breaking changes
   - Communicate with API consumers

2. **Client Updates**
   - Update all API clients (web, mobile, etc.)
   - Test integration with new API
   - Plan deprecation timeline
   - Support old version temporarily

3. **Documentation Updates**
   - Update API documentation
   - Add migration guide
   - Document deprecation schedule
   - Notify stakeholders

**Coordinated Deployment**: Ensure clients updated before deprecating old API
```

---

## Quality-Based Recommendations

### Based on Test Coverage

```markdown
**Coverage: [X]%**

[IF coverage < 70%]:
**⚠️ Low Coverage - Testing Required**
- Current coverage is below acceptable threshold
- Recommend running `/agency:test [component]` to add tests
- Focus on:
  - Core business logic
  - Edge cases
  - Error handling paths
- Do not deploy without improving coverage

[IF coverage 70-79%]:
**⚠️ Below Target - Consider Improvements**
- Coverage is acceptable but below 80% target
- Consider adding tests for:
  - [Modules with <70% coverage]
- Can deploy but plan follow-up for coverage improvement

[IF coverage 80-89%]:
**✅ Good Coverage - Optional Improvements**
- Coverage meets target
- Optional: Achieve >90% for critical modules
- Focus on complex logic and edge cases

[IF coverage ≥ 90%]:
**✅ Excellent Coverage**
- Coverage exceeds expectations
- Maintain this level for future changes
```

### Based on Code Review Findings

```markdown
**Code Review: [X] critical, [Y] high, [Z] medium/low**

[IF critical > 0]:
**❌ Critical Issues - Must Fix**
- Do NOT deploy with critical issues
- Address all critical issues immediately
- Re-run verification after fixes
- Critical issues are deployment blockers

[IF high > 0 AND critical = 0]:
**⚠️ High Priority Issues - Should Fix**
- High priority issues should be addressed before deployment
- Issues are not blockers but create technical debt
- Consider fixing before PR or create follow-up issues
- Document if deploying with high issues

[IF only medium/low]:
**✅ Minor Issues Only**
- No critical or high priority issues
- Medium/low issues can be addressed later
- Create issues for tracking
- Safe to deploy
```

### Based on Verification Results

```markdown
**Verification Status**:
- Build: [✅/❌]
- Type Check: [✅/❌]
- Linter: [✅/⚠️/❌]
- Tests: [✅/❌]

[IF all ✅]:
**✅ All Verification Passed**
- No verification blockers
- Ready to proceed to deployment

[IF build ❌]:
**❌ Build Failure - Critical**
- Fix build errors immediately
- Do not proceed until build passes
- This is a hard blocker

[IF type check ❌]:
**❌ Type Errors - Critical**
- Fix all type errors
- TypeScript errors are deployment blockers
- Ensure type safety

[IF linter ❌]:
**⚠️ Linting Errors**
- Fix all linting errors
- Warnings are acceptable but minimize
- Ensure code quality standards met

[IF tests ❌]:
**❌ Test Failures - Critical**
- Fix all failing tests
- Investigate root causes
- Do not deploy with failing tests
```

---

## Standard Next Steps Combinations

### Successful Feature Implementation

```markdown
## Next Steps

### ✅ Implementation Successful

**Quality Gates**: All passed ✅
- Build: ✅ Pass
- Type Check: ✅ Pass
- Linter: ✅ Pass (0 errors, 3 warnings)
- Tests: ✅ 57/57 pass (100%)
- Coverage: ✅ 82%
- Code Review: ✅ 0 critical, 0 high, 2 medium

**Immediate Actions**:

1. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: implement user authentication system"
   ```

2. **Create Pull Request**
   ```bash
   gh pr create --title "feat: User Authentication System" --body "..."
   ```
   - Link to plan: `.agency/plans/plan-user-authentication.md`
   - Link to summary: `.agency/implementations/impl-user-auth-20241211-143022.md`

3. **Request Reviews**
   - Assign reviewers
   - Request security review (authentication feature)

**Optional Enhancements**:

4. **Additional Testing** (if time permits)
   - Add E2E tests for login/register flows
   - Add security penetration tests
   - Run `/agency:test authentication` for more tests

5. **Performance Testing** (recommended)
   - Test authentication flow performance
   - Verify JWT generation/validation speed
   - Check database query performance

**Deployment**:

6. **Merge After Approval**
   - Wait for peer review approval
   - Merge to main branch

7. **Deploy to Staging**
   - Test authentication in staging
   - Verify integration with other services
   - Check logs for errors

8. **Deploy to Production**
   - Deploy during low-traffic window
   - Monitor authentication metrics
   - Watch for errors in logs

**Documentation**:
- Implementation summary: `.agency/implementations/impl-user-auth-20241211-143022.md`
- API documentation: `docs/api/authentication.md`
- Architecture decision: `docs/architecture/auth-flow.md`

**Risk Level**: Low - safe to deploy
**Estimated Timeline**: Ready to deploy after PR approval
```

### Partial Success with Follow-up

```markdown
## Next Steps

### ⚠️ Implementation Partially Complete

**Quality Gates**: Mixed results
- Build: ✅ Pass
- Type Check: ✅ Pass
- Linter: ⚠️ Pass with warnings (8 warnings)
- Tests: ⚠️ 54/57 pass (94.7%)
- Coverage: ⚠️ 76% (below 80% target)
- Code Review: ⚠️ 0 critical, 2 high, 5 medium

**Required Actions**:

1. **Fix Failing Tests** (priority)
   - [ ] Fix test: `should handle invalid credentials`
   - [ ] Fix test: `should expire JWT after timeout`
   - [ ] Fix test: `should validate email format`
   - Estimated effort: 2 hours

2. **Address High Priority Issues** (priority)
   - [ ] Add input validation for email field (security)
   - [ ] Fix password hashing - use bcrypt instead of plain text (critical security)
   - Estimated effort: 3 hours

3. **Improve Test Coverage** (recommended)
   - Current: 76%
   - Target: 80%
   - Focus on:
     - `src/lib/auth.ts` (58% coverage)
     - `src/api/auth/register.ts` (65% coverage)
   - Run `/agency:test authentication` to add tests
   - Estimated effort: 2 hours

**After Fixes**:

4. **Re-run Verification**
   ```bash
   npm test
   npm run lint
   npm run test:coverage
   ```

5. **Re-run Code Review**
   - Verify high priority issues resolved
   - Ensure no new issues introduced

6. **Update Implementation Summary**
   - Document fixes applied
   - Update verification results
   - Update next steps

**Then Proceed**:
- Create git commit
- Create pull request
- Deploy after approval

**Alternative Path** (if time-constrained):
- Deploy with documented known issues
- Create follow-up issues for improvements
- Higher risk - not recommended for security features

**Risk Level**: Medium - requires fixes before deployment
**Estimated Effort**: 7 hours to address all issues
**Recommendation**: Fix high priority issues before deploying
```

---

## Best Practices

### Be Specific

**Bad**:
```markdown
- Fix the issues
- Improve the code
- Add more tests
```

**Good**:
```markdown
- Fix input validation in LoginForm.tsx (line 45)
- Improve error handling in auth.ts by adding try-catch
- Add tests for edge case: expired JWT token validation
```

### Be Actionable

**Bad**:
```markdown
- Coverage could be better
- Some code smells detected
```

**Good**:
```markdown
- Improve coverage from 76% to 80% by adding tests to:
  - src/lib/auth.ts (currently 58%)
  - src/api/auth/register.ts (currently 65%)
- Refactor `validateInput` function to reduce cyclomatic complexity from 12 to <8
```

### Provide Context

**Bad**:
```markdown
- Run tests
- Create PR
```

**Good**:
```markdown
- Run tests to verify fixes for 3 failing tests
- Create PR linking to implementation summary and noting 2 medium issues as technical debt
```

### Prioritize

**Use clear priority indicators**:
- **Critical**: Must fix before proceeding
- **High**: Should fix before deploying
- **Medium**: Consider fixing or create follow-up issue
- **Low**: Nice to have, create issue for later
- **Optional**: Enhancement opportunity

### Include Commands

**Always provide exact commands**:
```markdown
1. Run verification:
   ```bash
   npm run build && npm test && npm run lint
   ```

2. Create commit:
   ```bash
   git add .
   git commit -m "feat: user authentication system"
   ```

3. Create PR:
   ```bash
   gh pr create --title "feat: User Authentication" --body "Implements #123"
   ```
```

---

## Quick Decision Matrix

| Verification Results | Code Review | Coverage | Next Step |
|---------------------|-------------|----------|-----------|
| All ✅ | 0 critical/high | ≥80% | Ready for Deployment |
| All ✅ | 1-2 high | 70-79% | Conditional Deployment |
| Build ❌ or Tests ❌ | Any | Any | Remediation Required |
| All ✅ | 1+ critical | Any | Remediation Required |
| Mix ✅⚠️ | Medium/low only | 70-79% | Additional Work Required |

Use this matrix to quickly determine which next steps template to use.
