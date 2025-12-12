# Quality Gate: Rollback on Failure

**Gate Priority**: CRITICAL (Triggered on any blocking failure)
**Blocking**: N/A - This is the failure handler
**Execution**: Triggered automatically when any blocking gate fails

## Purpose

Provide a standardized, safe rollback procedure when quality gates fail. Ensures the codebase remains in a stable state and prevents partially-completed changes from causing issues.

## When Rollback is Triggered

Rollback is automatically triggered when any **BLOCKING** gate fails after maximum retry attempts:

- **Gate 1 (Build Verification)**: BLOCKING - Fails after 3 attempts
- **Gate 2 (Type Checking)**: BLOCKING - Fails after 3 attempts
- **Gate 3 (Linting)**: PARTIAL BLOCKING - Fails after 3 attempts (errors only)
- **Gate 4 (Test Execution)**: BLOCKING - Fails after 3 attempts
- **Gate 6 (Security Scan)**: PARTIAL BLOCKING - Fails after 2 attempts (critical/high only)

**Note**: Gate 5 (Coverage Validation) is non-blocking and never triggers rollback.

## Rollback Scenarios

### Scenario 1: Uncommitted Changes (Local Development)
**Situation**: Changes exist only in working directory, not committed to git.

**Rollback Strategy**: Discard working directory changes

### Scenario 2: Committed Changes (Local, Not Pushed)
**Situation**: Changes committed to local git repository, but not pushed to remote.

**Rollback Strategy**: Reset to previous commit

### Scenario 3: Pushed Changes (Remote)
**Situation**: Changes pushed to remote feature branch.

**Rollback Strategy**: Revert commit or reset branch (depending on collaboration status)

### Scenario 4: Merged to Main/Production
**Situation**: Changes already merged to main branch or deployed.

**Rollback Strategy**: Create revert commit (preserves history)

## Rollback Execution Flow

```pseudo
function handle_quality_gate_failure(failed_gate, attempt_count):
    # Log failure
    log_failure(failed_gate, attempt_count)

    # Determine rollback scenario
    scenario = detect_rollback_scenario()

    # Confirm rollback with user
    confirmed = prompt_user_for_rollback_confirmation(scenario)

    if not confirmed:
        # User declines rollback
        log_user_declined_rollback()
        provide_manual_fix_instructions()
        return ABORT_ROLLBACK

    # Execute rollback
    result = execute_rollback(scenario)

    if result.success:
        report_rollback_success(scenario)
        verify_system_state()
        return ROLLBACK_SUCCESS
    else:
        report_rollback_failure(result.error)
        provide_manual_recovery_steps()
        return ROLLBACK_FAILED
```

## Rollback Procedures by Scenario

### Scenario 1: Uncommitted Changes

#### Detection
```bash
# Check if there are uncommitted changes
git status --porcelain | grep -E '^(M| M|A| A|D| D)'

# Check if any commits exist that aren't pushed
git log origin/$(git branch --show-current)..HEAD --oneline

# If output is empty for second command AND first has changes: Scenario 1
```

#### Rollback Commands

```bash
# Option A: Discard all changes (DESTRUCTIVE)
git restore .
git clean -fd

# Option B: Stash changes for later review
git stash push -u -m "Stashed due to quality gate failure: [gate name]"

# Verify rollback
git status  # Should show clean working directory
```

#### Recommendation
Use **Option B (stash)** to preserve work for analysis. Only use Option A if changes are genuinely unwanted.

---

### Scenario 2: Committed But Not Pushed

#### Detection
```bash
# Check for unpushed commits
git log origin/$(git branch --show-current)..HEAD --oneline

# If output exists: Scenario 2
```

#### Rollback Commands

```bash
# Check how many commits to roll back
commits_ahead=$(git rev-list --count origin/$(git branch --show-current)..HEAD)

# Option A: Soft reset (keeps changes in working directory)
git reset --soft HEAD~${commits_ahead}

# Option B: Hard reset (DESTRUCTIVE - discards changes)
git reset --hard origin/$(git branch --show-current)

# Verify rollback
git log --oneline -5
git status
```

#### Recommendation
Use **Option A (soft reset)** if you want to preserve changes for fixing. Use **Option B (hard reset)** if you want to completely discard failed changes.

---

### Scenario 3: Pushed to Remote Feature Branch

#### Detection
```bash
# Check if current branch is pushed and has commits
git branch -r | grep "origin/$(git branch --show-current)"

# Check if branch is a feature branch (not main/master/develop)
current_branch=$(git branch --show-current)
if [[ ! "$current_branch" =~ ^(main|master|develop)$ ]]; then
    # Scenario 3
fi
```

#### Rollback Commands

```bash
# Check if anyone else has commits on this branch
git fetch origin
git log HEAD..origin/$(git branch --show-current) --oneline

# If no one else has pushed (safe to force push):
# Option A: Reset and force push (DESTRUCTIVE - rewrites remote history)
git reset --hard origin/main  # or appropriate base branch
git push --force-with-lease origin $(git branch --show-current)

# If others have pushed (preserve history):
# Option B: Revert commits
git revert HEAD~${commits_to_revert}..HEAD
git push origin $(git branch --show-current)

# Verify rollback
git log --oneline -5
```

#### Recommendation
- **Solo development**: Use Option A (reset + force push) for clean history
- **Team development**: Use Option B (revert) to preserve history and not disrupt collaborators

---

### Scenario 4: Merged to Main/Production

#### Detection
```bash
# Check if current branch is main/master/develop
current_branch=$(git branch --show-current)
if [[ "$current_branch" =~ ^(main|master|develop)$ ]]; then
    # Scenario 4
fi

# Or check if commit exists in main
git branch --contains HEAD | grep -E '^[* ] (main|master)$'
```

#### Rollback Commands

```bash
# NEVER use reset or force push on main/master
# Always use revert to preserve history

# Option A: Revert the last commit
git revert HEAD

# Option B: Revert a range of commits
git revert HEAD~3..HEAD  # Reverts last 3 commits

# Option C: Revert a specific commit by hash
git revert <commit-hash>

# Push revert commit
git push origin $(git branch --show-current)

# Verify rollback
git log --oneline -5
git diff HEAD~1 HEAD  # Should show changes being undone
```

#### Critical Rules for Main/Production
- **NEVER** use `git reset` on main/master/develop
- **NEVER** use `git push --force` on main/master/develop
- **ALWAYS** use `git revert` to preserve history
- **ALWAYS** test revert commit before pushing

---

## Pre-Rollback Checklist

Before executing rollback, verify:

1. **Backup Current State**
   ```bash
   # Create a backup branch
   git branch backup/$(date +%Y%m%d-%H%M%S)-$(git branch --show-current)
   ```

2. **Verify No Uncommitted Work**
   ```bash
   git status
   # If work exists, stash it
   git stash push -u -m "Pre-rollback stash"
   ```

3. **Fetch Latest Remote State**
   ```bash
   git fetch --all
   ```

4. **Identify Target Rollback Point**
   ```bash
   # Show recent commits
   git log --oneline -10

   # Identify the commit to roll back to
   target_commit=$(git rev-parse origin/main)  # or appropriate target
   ```

5. **Confirm User Consent**
   - Explain what will be rolled back
   - Show diff of changes that will be lost/reverted
   - Get explicit user confirmation

## Post-Rollback Verification

After rollback, verify system state:

1. **Verify Git State**
   ```bash
   git status  # Should show clean or expected state
   git log --oneline -5  # Verify commit history
   git diff origin/$(git branch --show-current)  # Check diff with remote
   ```

2. **Verify Build State**
   ```bash
   # Run build verification
   npm run build || cargo build || go build ./...
   ```

3. **Verify Tests Pass**
   ```bash
   # Run quick smoke tests
   npm test || pytest || cargo test
   ```

4. **Verify Dependencies**
   ```bash
   # Check dependency integrity
   npm install || pip install -r requirements.txt
   ```

## Rollback Reporting

### Success Report

```markdown
### Rollback: ✅ SUCCESS

- **Trigger**: [Gate Name] failed after [X] attempts
- **Scenario**: [Scenario 1-4 description]
- **Rollback Method**: [reset/revert/stash/restore]
- **Commits Affected**: [count]
- **Files Affected**: [count]
- **Rollback Time**: [X.X seconds]

**Actions Taken**:
1. [Specific git command executed]
2. [Specific git command executed]
3. [Verification steps]

**Current State**:
- Working Directory: Clean / [X] stashed files
- Branch: [branch name]
- HEAD: [commit hash] [commit message]
- Diff with Remote: [X] commits behind/ahead

**Backup Created**: Yes - Branch: backup/[timestamp]-[branch-name]

**Next Steps**:
1. Review what caused the quality gate failure
2. Fix the issues in the code
3. Re-run the quality gate sequence
4. If needed, restore from backup: git checkout backup/[name]
```

### Failure Report

```markdown
### Rollback: ❌ FAILED

- **Trigger**: [Gate Name] failed after [X] attempts
- **Scenario**: [Scenario 1-4 description]
- **Rollback Method Attempted**: [reset/revert/stash/restore]
- **Error**: [Error message]
- **Exit Code**: [code]

**What Went Wrong**:
[Detailed explanation of rollback failure]

**Current State** (potentially inconsistent):
- Working Directory: [status]
- Branch: [branch name]
- HEAD: [commit hash]
- Uncommitted Changes: [count] files

**Manual Recovery Steps**:
1. [Specific recovery step]
2. [Specific recovery step]
3. [Specific recovery step]

**Emergency Contacts**:
- Backup branch (if created): backup/[timestamp]-[branch-name]
- Original remote state: origin/[branch-name]

**To Manually Recover**:
```bash
# [Specific commands to manually recover]
```

**Warning**: Do NOT proceed with commit/push until state is verified.
```

## User Prompts and Confirmations

### Rollback Confirmation Prompt

```
⚠️ Quality Gate Failed: [Gate Name]

The [gate name] quality gate has failed after [X] attempts.

Current situation:
- Branch: [branch-name]
- Uncommitted changes: [count] files
- Unpushed commits: [count] commits
- Last commit: [commit hash] [commit message]

Recommended rollback action:
[Scenario-specific description]

This will:
✓ [What will be preserved]
✗ [What will be lost]

⚠️ WARNING: [Any destructive actions]

A backup branch will be created: backup/[timestamp]-[branch-name]

Do you want to proceed with rollback? (y/n)
```

### User Declined Rollback

```
Rollback declined by user.

You can manually fix the issues and retry the quality gate, or perform a manual rollback later.

To manually rollback:
```bash
# [Scenario-specific manual rollback commands]
```

To retry the quality gate after fixing:
```bash
# [Command to re-run quality gate]
```

Current state preserved. No changes made.
```

## Special Considerations

### Partial Rollback
In some cases, only specific files need rollback:

```bash
# Rollback specific files
git restore [file1] [file2]

# Or from specific commit
git restore --source=HEAD~1 [file]
```

### Dependency Rollback
If dependencies changed, restore them:

```bash
# npm
git restore package.json package-lock.json
npm install

# Python
git restore requirements.txt
pip install -r requirements.txt

# Rust
git restore Cargo.toml Cargo.lock
cargo build
```

### Database Migrations
If database migrations were involved:

```bash
# Rollback database migrations (framework-specific)
# Django
python manage.py migrate [app] [previous_migration]

# Rails
rake db:rollback

# Alembic (Python)
alembic downgrade -1
```

### Configuration Rollback
If configuration files changed:

```bash
# Restore configuration files
git restore .env.example config/ .eslintrc.json tsconfig.json
```

## Integration with Quality Gate Sequence

Rollback is **triggered by failure** of any blocking gate:

```
Gate 1: Build Verification → FAIL (after 3 attempts) → TRIGGER ROLLBACK
Gate 2: Type Checking → FAIL (after 3 attempts) → TRIGGER ROLLBACK
Gate 3: Linting → FAIL (after 3 attempts, errors) → TRIGGER ROLLBACK
Gate 4: Test Execution → FAIL (after 3 attempts) → TRIGGER ROLLBACK
Gate 5: Coverage Validation → FAIL → NO ROLLBACK (non-blocking)
Gate 6: Security Scan → FAIL (critical/high, after 2 attempts) → TRIGGER ROLLBACK
```

## Preventing Rollback Necessity

### Best Practices to Avoid Rollbacks

1. **Run Quality Gates Locally Before Commit**
   - Use pre-commit hooks
   - Run gates manually: `npm run verify`
   - Test incrementally during development

2. **Small, Incremental Changes**
   - Commit small, focused changes
   - Easier to rollback if needed
   - Faster to identify issues

3. **Feature Branches**
   - Work on feature branches, not main
   - Test thoroughly before merging
   - Use pull requests with CI checks

4. **Continuous Testing**
   - Run tests during development
   - Fix issues immediately when detected
   - Don't accumulate technical debt

5. **Code Review**
   - Peer review before merging
   - Automated CI/CD checks
   - Enforce quality gate passage before merge

## Related Quality Gates

- **All Blocking Gates**: Build, Type Check, Linting (errors), Tests, Security (critical/high)
- **Triggered by**: Any blocking gate failure after max retry attempts
