# Pull Request Workflow

## PR Creation Checklist

### Pre-PR Checklist

**Code Quality**:
- [ ] All tests pass locally
- [ ] Linter passes with no warnings
- [ ] Code formatted (Prettier, Black, etc.)
- [ ] No console.log or debug statements
- [ ] No commented-out code

**Git Hygiene**:
- [ ] Branch up to date with main
- [ ] Commits are atomic and well-named
- [ ] No merge commits (rebase if needed)
- [ ] Sensitive data not committed

**Documentation**:
- [ ] Code comments where needed
- [ ] README updated if applicable
- [ ] API docs updated
- [ ] Migration guide if breaking changes

**Self-Review**:
- [ ] Review your own diff
- [ ] Check for unintended changes
- [ ] Verify file changes are relevant
- [ ] Remove unnecessary files

### PR Description Template

```markdown
## 🎯 Summary
Brief description of what this PR accomplishes and why.

## 📝 Changes
- Detailed change 1
- Detailed change 2
- Detailed change 3

## 🔗 Related Issues
Closes #123
Relates to #456
Blocked by #789

## 🧪 Testing
### Unit Tests
- [ ] Added tests for new features
- [ ] Updated tests for changed behavior
- [ ] All tests pass

### Integration Tests
- [ ] Integration tests pass
- [ ] E2E tests pass (if applicable)

### Manual Testing
- [ ] Tested on Chrome
- [ ] Tested on Firefox
- [ ] Tested on Safari
- [ ] Tested on mobile

**Test Steps**:
1. Step 1
2. Step 2
3. Expected result

## 📸 Screenshots
[Include for UI changes]

**Before**:
![Before](url)

**After**:
![After](url)

## 🚀 Deployment Notes
[Any special deployment considerations]
- Database migrations required
- Environment variables needed
- Feature flags to enable
- Cache to clear

## ⚠️ Breaking Changes
[List any breaking changes and migration path]
- Breaking change 1: Migration instructions
- Breaking change 2: Migration instructions

## 📋 Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] Dependent changes merged
```

## Review Process

### As Author

**Creating the PR**:
1. Write clear title following conventional commits
2. Fill out PR description template completely
3. Add relevant labels (feature, bug, documentation)
4. Link related issues
5. Request reviewers
6. Assign to yourself

**During Review**:
1. **Respond promptly** (within 24 hours)
2. **Ask questions** if feedback unclear
3. **Push fixes** in new commits (don't force push)
4. **Re-request review** after addressing comments
5. **Resolve conversations** when addressed
6. **Keep PR updated** with main

**Common Responses**:
```markdown
✅ "Good catch! Fixed in abc123"
🤔 "Interesting point. I chose this approach because..."
📖 "I'll add a comment explaining this"
🔄 "Updated to use your suggestion"
❓ "Could you clarify what you mean by...?"
```

**After Approval**:
1. Squash commits if needed
2. Update PR title if changed
3. Merge using agreed strategy
4. Delete branch
5. Close related issues

### As Reviewer

**Initial Review** (within 24 hours):
1. **Understand context** - Read issue, PR description
2. **Check tests** - Verify test coverage
3. **Review code** - Check quality, security, performance
4. **Try it out** - Pull and test locally if needed
5. **Provide feedback** - Constructive comments

**Review Levels**:

**💬 Comment** (Non-blocking):
```markdown
💡 Consider extracting this into a separate function for better readability.
```

**🔄 Request Changes** (Blocking):
```markdown
⚠️ This will cause a memory leak. Please use useEffect cleanup function.

**Suggested fix**:
\`\`\`javascript
useEffect(() => {
  const subscription = subscribe();
  return () => subscription.unsubscribe();
}, []);
\`\`\`
```

**✅ Approve**:
```markdown
LGTM! 🚀 Nice work on the error handling.
```

**Review Comment Guidelines**:
- ✅ Be specific and actionable
- ✅ Explain the "why" not just "what"
- ✅ Suggest code when helpful
- ✅ Praise good work
- ✅ Ask questions, don't demand
- ❌ Don't be vague ("this is bad")
- ❌ Don't nitpick style (use linter)
- ❌ Don't be condescending

### Review Checklist

**Functionality**:
- [ ] Code does what PR says
- [ ] Edge cases handled
- [ ] Error handling appropriate
- [ ] No obvious bugs

**Code Quality**:
- [ ] Readable and maintainable
- [ ] No code duplication
- [ ] Functions are focused (single responsibility)
- [ ] No overly complex logic
- [ ] Consistent with codebase style

**Security**:
- [ ] No SQL injection vulnerabilities
- [ ] Input validation present
- [ ] Authentication/authorization correct
- [ ] No exposed secrets
- [ ] XSS prevention
- [ ] CSRF tokens used

**Performance**:
- [ ] No N+1 queries
- [ ] Appropriate caching
- [ ] No unnecessary re-renders
- [ ] Database indexes used
- [ ] Large lists paginated

**Testing**:
- [ ] Sufficient test coverage
- [ ] Tests are meaningful
- [ ] Tests pass
- [ ] Edge cases tested

**Documentation**:
- [ ] Complex code has comments
- [ ] Public APIs documented
- [ ] README updated if needed
- [ ] Breaking changes noted

## PR Size Guidelines

### Ideal PR Sizes

| Size | Lines Changed | Review Time | Defect Rate |
|------|---------------|-------------|-------------|
| **XS** | < 10 | 5 min | Very Low |
| **S** | 10-100 | 10 min | Low |
| **M** | 100-400 | 30 min | Medium |
| **L** | 400-1000 | 60+ min | High |
| **XL** | 1000+ | Several hours | Very High |

**Target**: Keep PRs under 400 lines for optimal review quality.

### Breaking Down Large PRs

**Strategy 1: Vertical Slicing**
```
Large Feature PR
  ↓
PR 1: Database schema + migrations
PR 2: Backend API endpoints
PR 3: Frontend components
PR 4: Integration + tests
```

**Strategy 2: Horizontal Slicing**
```
Large Refactor PR
  ↓
PR 1: Extract utility functions
PR 2: Refactor component A
PR 3: Refactor component B
PR 4: Remove deprecated code
```

**Strategy 3: Feature Flags**
```
Merge incomplete feature behind flag
  ↓
PR 1: Feature structure (flag off)
PR 2: Implementation (flag off)
PR 3: Tests (flag off)
PR 4: Enable feature (flag on)
```

## Merge Strategies

### Squash and Merge

**When to Use**:
- Multiple small commits
- Messy commit history
- Want clean main history

**Result**:
```
Before: 15 commits in PR
After: 1 commit in main
```

**Command**:
```bash
gh pr merge 123 --squash
```

### Merge Commit

**When to Use**:
- Preserve commit history
- Feature branches with good commits
- Want to see feature boundaries

**Result**:
```
Before: 5 commits in PR
After: 5 commits + 1 merge commit in main
```

**Command**:
```bash
gh pr merge 123 --merge
```

### Rebase and Merge

**When to Use**:
- Clean linear history
- Well-crafted commits
- No desire for merge commits

**Result**:
```
Before: 5 commits in PR
After: 5 commits in main (rebased)
```

**Command**:
```bash
gh pr merge 123 --rebase
```

### Strategy Comparison

| Strategy | History | Traceability | Simplicity |
|----------|---------|--------------|------------|
| **Squash** | Clean | Low | High |
| **Merge** | Detailed | High | Medium |
| **Rebase** | Linear | Medium | Low |

**Recommendation**: Use **squash** for most PRs, **merge** for important features.

## PR Automation

### GitHub Actions for PRs

**Auto-label PRs**:
```yaml
# .github/workflows/label-pr.yml
name: Label PRs
on:
  pull_request:
    types: [opened]

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/labeler@v4
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
```

**Auto-assign Reviewers**:
```yaml
# .github/workflows/assign-reviewer.yml
name: Assign Reviewer
on:
  pull_request:
    types: [opened]

jobs:
  assign:
    runs-on: ubuntu-latest
    steps:
      - uses: kentaro-m/auto-assign-action@v1
```

**Check PR Size**:
```yaml
# .github/workflows/pr-size.yml
name: PR Size Check
on: pull_request

jobs:
  size:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check size
        run: |
          LINES=$(git diff --shortstat origin/main | awk '{print $4+$6}')
          if [ $LINES -gt 400 ]; then
            echo "::warning::PR has $LINES lines. Consider breaking it down."
          fi
```

### PR Templates

**Multiple Templates**:
```
.github/
  PULL_REQUEST_TEMPLATE/
    feature.md
    bugfix.md
    hotfix.md
  PULL_REQUEST_TEMPLATE.md  # Default
```

**Usage**:
```
?template=feature
?template=bugfix
```

## Advanced Workflows

### Draft PRs

**When to Use**:
- Work in progress
- Want early feedback
- Need CI to run

**Creating**:
```bash
gh pr create --draft
```

**Benefits**:
- Shows intent
- Can't be merged accidentally
- Gets CI feedback
- Enables collaboration

**Converting to Ready**:
```bash
gh pr ready 123
```

### PR Chains

**Stacked PRs**:
```
PR 1: main ← feature/step-1
PR 2: feature/step-1 ← feature/step-2
PR 3: feature/step-2 ← feature/step-3
```

**Workflow**:
1. Create and merge PR 1
2. Rebase PR 2 onto main
3. Change PR 2 base to main
4. Repeat for PR 3

### Auto-merge

**Enable Auto-merge**:
```bash
gh pr merge 123 --auto --squash
```

**Requirements**:
- All checks pass
- Required reviews approved
- Conflicts resolved

**Benefits**:
- Merge when ready
- No manual intervention
- Respects protection rules

## Troubleshooting

### PR Shows Too Many Changes

**Cause**: Wrong base branch
**Fix**:
```bash
gh pr edit 123 --base main
```

### Conflicts After Review

**Fix**:
```bash
git checkout feature/123
git pull origin main --rebase
git push --force-with-lease
```

### Accidentally Merged Wrong PR

**Fix**:
```bash
# Revert the merge commit
git revert -m 1 <merge-commit-hash>
git push origin main
```

### CI Failing on PR

**Debug**:
1. Check workflow logs
2. Run tests locally
3. Check for flaky tests
4. Verify environment variables

## Best Practices

1. **Keep PRs Small** - Under 400 lines
2. **Write Good Descriptions** - Explain why, not just what
3. **Respond Quickly** - Review within 24 hours
4. **Test Thoroughly** - Don't rely on CI alone
5. **Be Respectful** - Constructive, not critical
6. **Update Regularly** - Keep in sync with main
7. **Use Templates** - Consistency helps reviews
8. **Automate Checks** - Let CI handle style/linting
9. **Link Issues** - Provide context
10. **Clean Up** - Delete branches after merge

## References

- [GitHub PR Best Practices](https://github.blog/2015-01-21-how-to-write-the-perfect-pull-request/)
- [Google Code Review Guidelines](https://google.github.io/eng-practices/review/)
- [Conventional Comments](https://conventionalcomments.org/)
