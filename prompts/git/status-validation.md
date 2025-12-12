# Git Operations: Status Validation

Validate git repository state and detect common issues.

## When to Use

**Before critical operations**:
- Before creating branches
- Before committing changes
- Before pushing to remote
- Before creating pull requests
- Before rebasing or merging
- At start of any git workflow

**Purpose**:
- Ensure clean working state
- Detect uncommitted changes
- Identify merge conflicts
- Verify remote sync status
- Prevent data loss
- Catch common git issues early

---

## Basic Status Checks

### Check Working Directory Status

```bash
# Full status
git status

# Porcelain format (machine-readable)
git status --porcelain

# Short format
git status -s

# Branch info only
git status -sb
```

**Status Output Interpretation**:
```
On branch feat/user-authentication
Your branch is up to date with 'origin/feat/user-authentication'.

Changes to be committed:  ← Staged changes (green)
  (use "git restore --staged <file>..." to unstage)
        modified:   src/auth/service.ts

Changes not staged for commit:  ← Unstaged changes (red)
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   src/auth/types.ts

Untracked files:  ← New files not in git
  (use "git add <file>..." to include in what will be committed)
        src/auth/utils.ts
```

---

## Clean State Validation

**Check if working directory is clean**:

```bash
# Method 1: Using git status
if [[ -z $(git status --porcelain) ]]; then
  echo "✅ Working directory clean"
else
  echo "⚠️ Uncommitted changes detected"
  git status
fi

# Method 2: Specific checks
STAGED=$(git diff --cached --name-only)
UNSTAGED=$(git diff --name-only)
UNTRACKED=$(git ls-files --others --exclude-standard)

if [[ -z "$STAGED" ]] && [[ -z "$UNSTAGED" ]] && [[ -z "$UNTRACKED" ]]; then
  echo "✅ Working directory clean"
else
  echo "⚠️ Working directory has changes"
  [[ -n "$STAGED" ]] && echo "  Staged files: $(echo $STAGED | wc -l)"
  [[ -n "$UNSTAGED" ]] && echo "  Unstaged files: $(echo $UNSTAGED | wc -l)"
  [[ -n "$UNTRACKED" ]] && echo "  Untracked files: $(echo $UNTRACKED | wc -l)"
fi
```

---

## Branch Status Validation

### Current Branch Check

```bash
# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Check if on main/master
if [[ "$CURRENT_BRANCH" == "main" ]] || [[ "$CURRENT_BRANCH" == "master" ]]; then
  echo "⚠️ On main branch - consider creating feature branch"
fi

# Check for detached HEAD state
if [[ -z "$CURRENT_BRANCH" ]]; then
  echo "❌ ERROR: Detached HEAD state detected"
  echo "Current commit: $(git rev-parse --short HEAD)"
  echo "Create branch: git checkout -b recovery-branch"
fi
```

### Remote Tracking Status

```bash
# Check if branch tracks remote
REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)

if [[ -n "$REMOTE_BRANCH" ]]; then
  echo "✅ Branch tracks: $REMOTE_BRANCH"
else
  echo "⚠️ No remote tracking branch set"
  echo "Set with: git push -u origin $(git branch --show-current)"
fi

# Check tracking status
git status -sb
# Output format:
# ## feat/user-auth...origin/feat/user-auth [ahead 2, behind 1]
# [ahead N] = local has N commits not pushed
# [behind N] = remote has N commits not pulled
```

### Ahead/Behind Status

```bash
# Check if local is ahead of remote
git fetch origin --quiet

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u} 2>/dev/null)
BASE=$(git merge-base @ @{u} 2>/dev/null)

if [[ -z "$REMOTE" ]]; then
  echo "⚠️ No remote tracking branch"
elif [[ "$LOCAL" == "$REMOTE" ]]; then
  echo "✅ Up to date with remote"
elif [[ "$LOCAL" == "$BASE" ]]; then
  echo "⚠️ Behind remote - pull needed"
  git log --oneline HEAD..@{u}
elif [[ "$REMOTE" == "$BASE" ]]; then
  echo "⚠️ Ahead of remote - push needed"
  git log --oneline @{u}..HEAD
else
  echo "⚠️ Diverged from remote - rebase or merge needed"
  echo "Ahead: $(git rev-list --count @{u}..HEAD)"
  echo "Behind: $(git rev-list --count HEAD..@{u})"
fi
```

---

## Uncommitted Changes Detection

### List All Uncommitted Changes

```bash
# Staged changes
echo "=== Staged Changes ==="
git diff --cached --name-status
# A = Added, M = Modified, D = Deleted

# Unstaged changes
echo "=== Unstaged Changes ==="
git diff --name-status

# Untracked files
echo "=== Untracked Files ==="
git ls-files --others --exclude-standard

# Combined summary
echo "=== Summary ==="
echo "Staged: $(git diff --cached --name-only | wc -l) files"
echo "Unstaged: $(git diff --name-only | wc -l) files"
echo "Untracked: $(git ls-files --others --exclude-standard | wc -l) files"
```

### Check for Specific File Types

```bash
# Check for uncommitted .env files (dangerous!)
ENV_FILES=$(git status --porcelain | grep "\.env")
if [[ -n "$ENV_FILES" ]]; then
  echo "❌ WARNING: .env files detected in working directory"
  echo "$ENV_FILES"
  echo "Add to .gitignore and remove with: git rm --cached .env"
fi

# Check for large files
LARGE_FILES=$(git status --porcelain | while read status file; do
  if [[ -f "$file" ]]; then
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    if [[ $size -gt 1048576 ]]; then  # > 1MB
      echo "$file ($((size / 1024))KB)"
    fi
  fi
done)

if [[ -n "$LARGE_FILES" ]]; then
  echo "⚠️ Large files detected:"
  echo "$LARGE_FILES"
fi

# Check for node_modules or build artifacts
ARTIFACTS=$(git status --porcelain | grep -E "node_modules|dist|build|\.next")
if [[ -n "$ARTIFACTS" ]]; then
  echo "⚠️ Build artifacts detected (should be in .gitignore):"
  echo "$ARTIFACTS"
fi
```

---

## Merge Conflict Detection

### Check for Merge Conflicts

```bash
# Check if in merge state
if [[ -f .git/MERGE_HEAD ]]; then
  echo "⚠️ Merge in progress"

  # List conflicted files
  CONFLICTS=$(git diff --name-only --diff-filter=U)
  if [[ -n "$CONFLICTS" ]]; then
    echo "❌ Merge conflicts detected in:"
    echo "$CONFLICTS"
    echo ""
    echo "Resolve conflicts then:"
    echo "  git add <resolved-files>"
    echo "  git commit"
  fi
fi

# Check if in rebase state
if [[ -d .git/rebase-merge ]] || [[ -d .git/rebase-apply ]]; then
  echo "⚠️ Rebase in progress"
  echo "Continue: git rebase --continue"
  echo "Abort: git rebase --abort"
fi

# Check if in cherry-pick state
if [[ -f .git/CHERRY_PICK_HEAD ]]; then
  echo "⚠️ Cherry-pick in progress"
  echo "Continue: git cherry-pick --continue"
  echo "Abort: git cherry-pick --abort"
fi
```

### Validate Clean State for Operations

```bash
# Function to ensure clean state before operations
validate_clean_state() {
  local operation=$1

  # Check for uncommitted changes
  if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Cannot $operation: uncommitted changes detected"
    echo ""
    git status -s
    echo ""
    echo "Options:"
    echo "  1. Commit changes: git add . && git commit"
    echo "  2. Stash changes: git stash"
    echo "  3. Discard changes: git restore . (DANGEROUS)"
    return 1
  fi

  # Check for merge/rebase in progress
  if [[ -f .git/MERGE_HEAD ]] || [[ -d .git/rebase-merge ]]; then
    echo "❌ Cannot $operation: merge/rebase in progress"
    echo "Finish current operation first"
    return 1
  fi

  echo "✅ Clean state validated for $operation"
  return 0
}

# Usage
validate_clean_state "create branch" || exit 1
validate_clean_state "checkout branch" || exit 1
validate_clean_state "rebase" || exit 1
```

---

## Commit History Validation

### Recent Commits Check

```bash
# Show recent commits
git log --oneline -10

# Check if commits follow conventional format
echo "=== Commit Message Validation ==="
git log --format=%s -10 | while read msg; do
  if [[ "$msg" =~ ^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?:.+ ]]; then
    echo "✅ $msg"
  else
    echo "⚠️ Non-conventional: $msg"
  fi
done

# Check for WIP commits
WIP_COMMITS=$(git log --oneline -20 | grep -i "wip\|work in progress\|todo")
if [[ -n "$WIP_COMMITS" ]]; then
  echo "⚠️ WIP commits detected:"
  echo "$WIP_COMMITS"
  echo "Consider squashing or amending before push"
fi
```

### Unpushed Commits Check

```bash
# List unpushed commits
if git rev-parse --abbrev-ref @{u} > /dev/null 2>&1; then
  UNPUSHED=$(git log @{u}..HEAD --oneline)

  if [[ -n "$UNPUSHED" ]]; then
    COUNT=$(echo "$UNPUSHED" | wc -l)
    echo "⚠️ $COUNT unpushed commits:"
    echo "$UNPUSHED"
  else
    echo "✅ All commits pushed to remote"
  fi
else
  echo "⚠️ No remote tracking branch - commits not pushed"
fi
```

---

## Stash Status Check

### Check Stash List

```bash
# List stashes
STASH_COUNT=$(git stash list | wc -l)

if [[ $STASH_COUNT -gt 0 ]]; then
  echo "⚠️ $STASH_COUNT stash(es) present:"
  git stash list
  echo ""
  echo "Review with: git stash show -p stash@{0}"
  echo "Apply with: git stash pop"
else
  echo "✅ No stashes"
fi
```

---

## .gitignore Validation

### Check for Ignored Files in Working Directory

```bash
# List ignored files that would normally be committed
git ls-files --others --ignored --exclude-standard | head -20

# Check if ignored files are accidentally staged
IGNORED_STAGED=$(git ls-files -c -i --exclude-standard)
if [[ -n "$IGNORED_STAGED" ]]; then
  echo "❌ WARNING: Ignored files are staged for commit!"
  echo "$IGNORED_STAGED"
  echo ""
  echo "Remove with: git rm --cached <file>"
fi
```

---

## Remote Repository Validation

### Check Remote Configuration

```bash
# List remotes
echo "=== Remotes ==="
git remote -v

# Verify origin exists
if git remote | grep -q "^origin$"; then
  echo "✅ Origin remote configured"
  ORIGIN_URL=$(git remote get-url origin)
  echo "   URL: $ORIGIN_URL"
else
  echo "❌ No origin remote configured"
  echo "Add with: git remote add origin <url>"
fi

# Check remote reachability
if git ls-remote origin > /dev/null 2>&1; then
  echo "✅ Remote reachable"
else
  echo "❌ Cannot reach remote (network issue or authentication)"
fi
```

---

## Comprehensive Status Report

### Full Repository Status

```bash
generate_status_report() {
  echo "======================================"
  echo "Git Repository Status Report"
  echo "======================================"
  echo ""

  # Repository info
  echo "Repository: $(basename $(git rev-parse --show-toplevel))"
  echo "Location: $(git rev-parse --show-toplevel)"
  echo ""

  # Branch info
  echo "--- Branch Status ---"
  CURRENT_BRANCH=$(git branch --show-current)
  echo "Current branch: $CURRENT_BRANCH"

  if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "❌ DETACHED HEAD"
  elif [[ "$CURRENT_BRANCH" == "main" ]] || [[ "$CURRENT_BRANCH" == "master" ]]; then
    echo "⚠️ On main branch"
  fi

  REMOTE_BRANCH=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
  if [[ -n "$REMOTE_BRANCH" ]]; then
    echo "Tracks: $REMOTE_BRANCH"

    # Ahead/behind
    AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
    BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

    if [[ $AHEAD -gt 0 ]]; then
      echo "⚠️ Ahead by $AHEAD commit(s)"
    fi
    if [[ $BEHIND -gt 0 ]]; then
      echo "⚠️ Behind by $BEHIND commit(s)"
    fi
    if [[ $AHEAD -eq 0 ]] && [[ $BEHIND -eq 0 ]]; then
      echo "✅ Up to date with remote"
    fi
  else
    echo "⚠️ No remote tracking"
  fi
  echo ""

  # Working directory status
  echo "--- Working Directory ---"
  STAGED=$(git diff --cached --name-only | wc -l | xargs)
  UNSTAGED=$(git diff --name-only | wc -l | xargs)
  UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | xargs)

  echo "Staged files: $STAGED"
  echo "Unstaged files: $UNSTAGED"
  echo "Untracked files: $UNTRACKED"

  if [[ $STAGED -eq 0 ]] && [[ $UNSTAGED -eq 0 ]] && [[ $UNTRACKED -eq 0 ]]; then
    echo "✅ Working directory clean"
  else
    echo "⚠️ Uncommitted changes present"
    if [[ $STAGED -gt 0 ]]; then
      echo ""
      echo "Staged files:"
      git diff --cached --name-status
    fi
    if [[ $UNSTAGED -gt 0 ]]; then
      echo ""
      echo "Unstaged files:"
      git diff --name-status
    fi
    if [[ $UNTRACKED -gt 0 ]]; then
      echo ""
      echo "Untracked files (first 10):"
      git ls-files --others --exclude-standard | head -10
    fi
  fi
  echo ""

  # Recent commits
  echo "--- Recent Commits (5) ---"
  git log --oneline -5
  echo ""

  # Stashes
  STASH_COUNT=$(git stash list | wc -l | xargs)
  echo "--- Stashes ---"
  echo "Stash count: $STASH_COUNT"
  if [[ $STASH_COUNT -gt 0 ]]; then
    git stash list | head -3
  fi
  echo ""

  # Overall health
  echo "--- Overall Status ---"

  ISSUES=0

  if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "❌ Detached HEAD state"
    ((ISSUES++))
  fi

  if [[ -f .git/MERGE_HEAD ]] || [[ -d .git/rebase-merge ]]; then
    echo "❌ Merge/rebase in progress"
    ((ISSUES++))
  fi

  if [[ $STAGED -gt 0 ]] || [[ $UNSTAGED -gt 0 ]] || [[ $UNTRACKED -gt 0 ]]; then
    echo "⚠️ Uncommitted changes present"
    ((ISSUES++))
  fi

  if [[ -z "$REMOTE_BRANCH" ]]; then
    echo "⚠️ No remote tracking configured"
    ((ISSUES++))
  fi

  if [[ $ISSUES -eq 0 ]]; then
    echo "✅ Repository in good state"
  else
    echo "⚠️ $ISSUES issue(s) detected"
  fi

  echo "======================================"
}

# Usage
generate_status_report
```

---

## Pre-Operation Validation Templates

### Before Branch Creation

```bash
echo "=== Pre-Branch Creation Validation ==="
if validate_clean_state "create branch"; then
  CURRENT=$(git branch --show-current)
  if [[ "$CURRENT" == "main" ]] || [[ "$CURRENT" == "master" ]]; then
    echo "✅ On main branch - ready to create feature branch"
  else
    echo "⚠️ Not on main - will create branch from $CURRENT"
  fi
fi
```

### Before Commit

```bash
echo "=== Pre-Commit Validation ==="

# Check for staged files
STAGED=$(git diff --cached --name-only)
if [[ -z "$STAGED" ]]; then
  echo "❌ No files staged for commit"
  echo "Stage with: git add <files>"
  exit 1
fi

# Check for secrets
if git diff --cached | grep -qE "(API_KEY|SECRET|PASSWORD|TOKEN).*="; then
  echo "❌ WARNING: Potential secrets detected in staged changes"
  git diff --cached | grep -E "(API_KEY|SECRET|PASSWORD|TOKEN).*="
fi

# Check for large files
git diff --cached --name-only | while read file; do
  if [[ -f "$file" ]]; then
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    if [[ $size -gt 1048576 ]]; then
      echo "⚠️ Large file: $file ($((size / 1024))KB)"
    fi
  fi
done

echo "✅ Ready to commit"
```

### Before Push

```bash
echo "=== Pre-Push Validation ==="

# Check for unpushed commits
UNPUSHED=$(git log @{u}..HEAD --oneline 2>/dev/null)
if [[ -z "$UNPUSHED" ]]; then
  echo "⚠️ No commits to push"
  exit 1
fi

echo "Commits to push:"
echo "$UNPUSHED"

# Check for WIP commits
if echo "$UNPUSHED" | grep -qi "wip\|todo\|fixme"; then
  echo "⚠️ WARNING: WIP commits detected"
  echo "Consider squashing or amending"
fi

echo "✅ Ready to push"
```

### Before PR Creation

```bash
echo "=== Pre-PR Validation ==="

# Must not be on main
CURRENT=$(git branch --show-current)
if [[ "$CURRENT" == "main" ]] || [[ "$CURRENT" == "master" ]]; then
  echo "❌ Cannot create PR from main branch"
  exit 1
fi

# Must be pushed to remote
if ! git rev-parse --abbrev-ref @{u} > /dev/null 2>&1; then
  echo "❌ Branch not pushed to remote"
  echo "Push with: git push -u origin $CURRENT"
  exit 1
fi

# Must be up to date
if [[ -n $(git status --porcelain) ]]; then
  echo "⚠️ Uncommitted changes detected"
  git status -s
fi

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
if [[ "$LOCAL" != "$REMOTE" ]]; then
  echo "⚠️ Local differs from remote - push changes"
  exit 1
fi

echo "✅ Ready to create PR"
```

---

## Error Handling

### Common Issues and Solutions

**Detached HEAD**:
```bash
# Detect
if [[ -z $(git branch --show-current) ]]; then
  echo "❌ Detached HEAD detected"
  echo "Create recovery branch: git checkout -b recovery-branch"
fi
```

**Merge Conflicts**:
```bash
# Detect
if [[ -f .git/MERGE_HEAD ]]; then
  echo "❌ Merge in progress with conflicts"
  git diff --name-only --diff-filter=U
  echo "Resolve conflicts and commit"
fi
```

**Diverged Branches**:
```bash
# Detect
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

if [[ $AHEAD -gt 0 ]] && [[ $BEHIND -gt 0 ]]; then
  echo "❌ Branch diverged from remote"
  echo "Options:"
  echo "  1. Rebase: git pull --rebase"
  echo "  2. Merge: git pull"
fi
```

---

## Reporting Format

```markdown
## Git Status Validation

**Repository**: /path/to/repo
**Branch**: feat/user-authentication
**Tracking**: origin/feat/user-authentication

### Working Directory
- Staged files: 3
- Unstaged files: 1
- Untracked files: 0
- Status: ⚠️ Uncommitted changes

### Remote Status
- Ahead: 2 commits
- Behind: 0 commits
- Status: ⚠️ Push needed

### Recent Activity
- Last commit: abc123d - feat: add authentication
- Commits since main: 5
- Stashes: 0

### Overall Health
⚠️ 2 issues detected:
- Uncommitted changes present
- Local ahead of remote - push needed

**Recommended Actions**:
1. Review uncommitted changes: git status
2. Commit or stash changes
3. Push to remote: git push
```

---

## Related Components

- `prompts/git/branch-creation.md` - Validate before creating branch
- `prompts/git/commit-formatting.md` - Validate before commit
- `prompts/git/pr-creation.md` - Validate before PR
