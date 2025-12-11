# Branching Strategy Details

## Git Flow

Classic branching model for scheduled releases:

```
main
  ├── develop
  │   ├── feature/123-new-feature
  │   ├── feature/456-another-feature
  │   └── release/1.2.0
  └── hotfix/789-critical-fix
```

**Branches**:
- `main` - Production code
- `develop` - Integration branch
- `feature/*` - New features (from develop)
- `release/*` - Release preparation (from develop)
- `hotfix/*` - Urgent fixes (from main)

**Flow**:
1. Feature branches merge to develop
2. Release branch created from develop
3. Release tested and merged to main + develop
4. Hotfixes merged to main + develop

**Best For**: Teams with scheduled releases, complex projects

## GitHub Flow

Simplified flow for continuous deployment:

```
main
  ├── feature/123-new-feature
  ├── bugfix/456-fix-bug
  └── hotfix/789-urgent-fix
```

**Branches**:
- `main` - Always deployable
- `feature/*` - All changes (features, bugs, docs)

**Flow**:
1. Create branch from main
2. Make changes
3. Create PR
4. Review and test
5. Merge to main
6. Deploy immediately

**Best For**: Continuous deployment, small teams, SaaS products

## Trunk-Based Development

Minimal branching for high-velocity teams:

```
main
  ├── short-lived-branch-1 (< 1 day)
  └── short-lived-branch-2 (< 1 day)
```

**Branches**:
- `main` - Single long-lived branch
- Short-lived feature branches (< 1 day)

**Flow**:
1. Small changes in short-lived branches
2. Frequent integration to main
3. Feature flags for incomplete features
4. Continuous integration/deployment

**Best For**: High-velocity teams, microservices, experienced teams

## Release Branching

For maintaining multiple versions:

```
main
  ├── release/1.x
  ├── release/2.x
  └── release/3.x
      ├── feature/123
      └── bugfix/456
```

**Branches**:
- `main` - Current development
- `release/X.x` - Support branches for versions

**Flow**:
1. Create release branch when shipping version
2. Cherry-pick bug fixes to supported versions
3. Tag releases on release branches

**Best For**: Products with LTS versions, on-premise software

## Branch Protection Rules

### Required for Main Branch

**Status Checks**:
- ✅ All tests must pass
- ✅ Linter must pass
- ✅ Build must succeed
- ✅ Security scan must pass

**Review Requirements**:
- ✅ Require 1+ reviews
- ✅ Dismiss stale reviews
- ✅ Require review from code owners
- ✅ Require conversation resolution

**Restrictions**:
- ✅ Restrict force pushes
- ✅ Restrict deletions
- ✅ Require branches to be up to date
- ✅ Require signed commits (optional)

**Example GitHub Configuration**:
```yaml
# .github/branch-protection.yml
pattern: main
required_status_checks:
  strict: true
  contexts:
    - "test"
    - "lint"
    - "build"
required_pull_request_reviews:
  required_approving_review_count: 1
  dismiss_stale_reviews: true
  require_code_owner_reviews: true
enforce_admins: false
restrictions: null
```

## Branch Cleanup

### Automated Cleanup

**Delete After Merge**:
- Enable "Automatically delete head branches" in GitHub settings

**Prune Remote Tracking**:
```bash
git fetch --prune
```

**Delete Local Gone Branches**:
```bash
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
```

**Cleanup Script**:
```bash
#!/bin/bash
# cleanup-branches.sh

echo "🧹 Cleaning up merged branches..."

# Fetch and prune
git fetch --prune

# Delete local branches that are gone on remote
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -D

# Delete local branches merged to main
git branch --merged main | grep -v "main" | grep -v "develop" | xargs -r git branch -d

echo "✅ Cleanup complete"
```

### Manual Review

**List Stale Branches**:
```bash
# Branches not updated in 30 days
git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)' | awk '$1 < "'$(date -d '30 days ago' +%Y-%m-%d)'" {print $2}'
```

## Conflict Resolution

### Before Conflicts

**Keep Branch Updated**:
```bash
# Regularly merge or rebase from main
git checkout feature/123
git pull origin main --rebase
```

**Small PRs**:
- Smaller changes = fewer conflicts
- Aim for < 400 lines changed

**Communication**:
- Coordinate on shared files
- Use code owners
- Review daily

### During Conflicts

**Merge Conflicts**:
```bash
# Update from main
git checkout feature/123
git merge main

# Resolve conflicts in editor
# Stage resolved files
git add resolved-file.js

# Complete merge
git commit
```

**Rebase Conflicts**:
```bash
# Rebase on main
git checkout feature/123
git rebase main

# Resolve conflicts in editor
# Stage resolved files
git add resolved-file.js

# Continue rebase
git rebase --continue
```

**Abort if Needed**:
```bash
git merge --abort
# or
git rebase --abort
```

## Advanced Patterns

### Feature Flags

**Long-Lived Features**:
```javascript
// Merge incomplete feature behind flag
if (featureFlags.newDashboard) {
  return <NewDashboard />;
}
return <OldDashboard />;
```

**Benefits**:
- Merge to main early
- Enable for testing
- Gradual rollout
- Easy rollback

### Stacked Branches

**Dependent Features**:
```
main
  └── feature/123-base
      └── feature/456-builds-on-123
          └── feature/789-builds-on-456
```

**Workflow**:
1. Create feature/123 from main
2. Create feature/456 from feature/123
3. PR feature/123 → main
4. After merge, rebase feature/456 onto main
5. PR feature/456 → main

### Co-authored Commits

**Pair Programming**:
```
feat(auth): implement OAuth2 flow

Co-authored-by: Jane Doe <jane@example.com>
Co-authored-by: John Smith <john@example.com>
```

**GitHub Recognizes**:
- Both authors credited
- Contributions tracked
- Appears in history

## Choosing the Right Strategy

| Factor | Git Flow | GitHub Flow | Trunk-Based |
|--------|----------|-------------|-------------|
| **Team Size** | Medium-Large | Small-Medium | Small-Large |
| **Release Cycle** | Scheduled | Continuous | Continuous |
| **Deployment** | Manual | Automated | Automated |
| **Complexity** | High | Low | Very Low |
| **Learning Curve** | Steep | Gentle | Gentle |
| **Best For** | Enterprise | Startups | High-velocity |

**Decision Tree**:
1. Continuous deployment? → GitHub Flow or Trunk-Based
2. Multiple versions? → Git Flow or Release Branching
3. Scheduled releases? → Git Flow
4. High velocity? → Trunk-Based
5. Default choice → GitHub Flow

## References

- [Git Flow Original](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Trunk-Based Development](https://trunkbaseddevelopment.com/)
