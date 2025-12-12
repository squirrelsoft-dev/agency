# Git Operations: Tag Creation

Create deployment and release tags with semantic versioning.

## When to Use

**For release management**:
- Creating version tags for releases
- Marking deployment points
- Creating hotfix tags
- Tagging stable milestones
- Release candidate tagging

**Purpose**:
- Track release versions
- Enable rollback to specific versions
- Support semantic versioning
- Create release notes
- Trigger deployment pipelines

---

## Semantic Versioning (SemVer)

**Format**: `MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]`

```
v1.2.3
│ │ │
│ │ └─ PATCH: Bug fixes, backwards compatible
│ └─── MINOR: New features, backwards compatible
└───── MAJOR: Breaking changes, not backwards compatible
```

**Examples**:
```bash
v1.0.0        # Major release
v1.1.0        # Minor release (new features)
v1.1.1        # Patch release (bug fixes)
v2.0.0        # Major release (breaking changes)

# Pre-release versions
v1.2.0-alpha.1    # Alpha release
v1.2.0-beta.2     # Beta release
v1.2.0-rc.1       # Release candidate

# With build metadata
v1.2.3+20241211   # Build date
v1.2.3+build.123  # Build number
```

---

## Tag Types

### Lightweight Tags (Simple)

**When to use**: Development milestones, temporary markers

```bash
# Create lightweight tag
git tag v1.2.3

# Tag specific commit
git tag v1.2.3 abc123d

# List lightweight tags
git tag
```

### Annotated Tags (RECOMMENDED for Releases)

**When to use**: Official releases, production deployments

```bash
# Create annotated tag with message
git tag -a v1.2.3 -m "Release version 1.2.3"

# Create tag with detailed message using HEREDOC
git tag -a v1.2.3 -m "$(cat <<'EOF'
Release v1.2.3

Features:
- Add user authentication with JWT
- Implement real-time notifications
- Add dark mode support

Bug Fixes:
- Fix login redirect issue
- Resolve memory leak in event listeners

Breaking Changes:
- User API endpoint response format changed
- See CHANGELOG.md for migration guide
EOF
)"

# Tag specific commit
git tag -a v1.2.3 abc123d -m "Release v1.2.3"

# List annotated tags with messages
git tag -n
```

**Annotated tags include**:
- Tagger name and email
- Tag date
- Tag message
- GPG signature (if signed)

---

## Pre-Flight Checks

**Before creating release tag**:

```bash
# 1. Ensure on correct branch (usually main/master)
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]] && [[ "$CURRENT_BRANCH" != "master" ]]; then
  echo "⚠️ WARNING: Not on main branch (on $CURRENT_BRANCH)"
  # Ask: "Continue with tag on $CURRENT_BRANCH? (y/n)"
fi

# 2. Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
  echo "❌ ERROR: Uncommitted changes detected"
  git status
  exit 1
fi

# 3. Ensure branch is up to date with remote
git fetch origin
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u} 2>/dev/null)
if [[ "$LOCAL" != "$REMOTE" ]]; then
  echo "❌ ERROR: Local branch differs from remote"
  echo "Pull changes first: git pull"
  exit 1
fi

# 4. Check if tag already exists
TAG_NAME="v1.2.3"
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
  echo "❌ ERROR: Tag $TAG_NAME already exists"
  git show $TAG_NAME
  exit 1
fi

# 5. Verify tests pass
npm test || exit 1

# 6. Verify build succeeds
npm run build || exit 1
```

---

## Determining Version Number

### Analyzing Changes Since Last Tag

```bash
# Get latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Latest tag: $LATEST_TAG"

# Analyze commits since last tag
echo "Commits since $LATEST_TAG:"
git log $LATEST_TAG..HEAD --oneline

# Count commit types
BREAKING=$(git log $LATEST_TAG..HEAD --format=%s | grep -E "BREAKING CHANGE|^[^:]+!:" | wc -l)
FEATURES=$(git log $LATEST_TAG..HEAD --format=%s | grep "^feat" | wc -l)
FIXES=$(git log $LATEST_TAG..HEAD --format=%s | grep "^fix" | wc -l)

echo ""
echo "Change analysis:"
echo "- Breaking changes: $BREAKING"
echo "- New features: $FEATURES"
echo "- Bug fixes: $FIXES"

# Suggest version bump
if [[ $BREAKING -gt 0 ]]; then
  echo "Suggested: MAJOR version bump (breaking changes detected)"
elif [[ $FEATURES -gt 0 ]]; then
  echo "Suggested: MINOR version bump (new features added)"
elif [[ $FIXES -gt 0 ]]; then
  echo "Suggested: PATCH version bump (bug fixes only)"
else
  echo "Suggested: No changes to release"
fi
```

### Calculating Next Version

```bash
# Parse current version
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
VERSION=${LATEST_TAG#v}  # Remove 'v' prefix

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

# Increment based on change type
bump_major() {
  MAJOR=$((MAJOR + 1))
  MINOR=0
  PATCH=0
  echo "v${MAJOR}.${MINOR}.${PATCH}"
}

bump_minor() {
  MINOR=$((MINOR + 1))
  PATCH=0
  echo "v${MAJOR}.${MINOR}.${PATCH}"
}

bump_patch() {
  PATCH=$((PATCH + 1))
  echo "v${MAJOR}.${MINOR}.${PATCH}"
}

# Usage based on commit analysis
if [[ $BREAKING -gt 0 ]]; then
  NEXT_VERSION=$(bump_major)
elif [[ $FEATURES -gt 0 ]]; then
  NEXT_VERSION=$(bump_minor)
else
  NEXT_VERSION=$(bump_patch)
fi

echo "Current version: $LATEST_TAG"
echo "Next version: $NEXT_VERSION"
```

---

## Creating Release Tags

### Standard Release Tag

```bash
# Get next version (from calculation above)
NEXT_VERSION="v1.2.3"

# Generate changelog
CHANGELOG=$(git log $(git describe --tags --abbrev=0)..HEAD --format="- %s (%h)" --no-merges)

# Create annotated tag
git tag -a "$NEXT_VERSION" -m "$(cat <<EOF
Release $NEXT_VERSION

Changes:
$CHANGELOG
EOF
)"

# Verify tag created
git tag -n | grep "$NEXT_VERSION"
```

### Release with Categorized Changelog

```bash
NEXT_VERSION="v1.2.3"
PREV_VERSION=$(git describe --tags --abbrev=0)

# Categorize commits
FEATURES=$(git log $PREV_VERSION..HEAD --format="- %s (%h)" --grep="^feat")
FIXES=$(git log $PREV_VERSION..HEAD --format="- %s (%h)" --grep="^fix")
BREAKING=$(git log $PREV_VERSION..HEAD --format="- %s (%h)" --grep="BREAKING CHANGE\|!")
REFACTOR=$(git log $PREV_VERSION..HEAD --format="- %s (%h)" --grep="^refactor")
DOCS=$(git log $PREV_VERSION..HEAD --format="- %s (%h)" --grep="^docs")

# Create comprehensive tag message
git tag -a "$NEXT_VERSION" -m "$(cat <<'EOF'
Release $NEXT_VERSION

## Breaking Changes
$BREAKING

## New Features
$FEATURES

## Bug Fixes
$FIXES

## Refactoring
$REFACTOR

## Documentation
$DOCS

## Contributors
$(git log $PREV_VERSION..HEAD --format="- %an" | sort -u)
EOF
)"
```

---

## Pre-Release Tags

### Alpha Release

```bash
# For internal testing, unstable
VERSION="v1.2.0-alpha.1"

git tag -a "$VERSION" -m "$(cat <<'EOF'
Alpha Release v1.2.0-alpha.1

WARNING: This is an unstable alpha release for internal testing only.
Not recommended for production use.

Features (in progress):
- User authentication (80% complete)
- Real-time notifications (testing)

Known Issues:
- Login flow needs refinement
- Performance optimization pending
EOF
)"
```

### Beta Release

```bash
# For wider testing, mostly stable
VERSION="v1.2.0-beta.1"

git tag -a "$VERSION" -m "$(cat <<'EOF'
Beta Release v1.2.0-beta.1

Feature-complete beta release for testing.
Suitable for staging environments.

Features:
- User authentication complete
- Real-time notifications functional

Known Issues:
- Minor UI polish needed
- Performance optimization in progress

Testing needed:
- Cross-browser compatibility
- Load testing
- Security audit
EOF
)"
```

### Release Candidate

```bash
# Final testing before stable release
VERSION="v1.2.0-rc.1"

git tag -a "$VERSION" -m "$(cat <<'EOF'
Release Candidate v1.2.0-rc.1

Release candidate for v1.2.0.
All features complete and tested.

If no critical issues found, this will become v1.2.0.

Changes since v1.1.0:
- User authentication with JWT
- Real-time notifications
- Dark mode support

Testing: All tests passing, ready for production validation
EOF
)"
```

---

## Hotfix Tags

### Critical Production Fix

```bash
# Hotfix for urgent production issue
CURRENT_PROD="v1.2.3"
HOTFIX_VERSION="v1.2.4"

# Typically created from production tag
git checkout $CURRENT_PROD
git checkout -b hotfix/critical-security-fix

# Make urgent fix
# ... code changes ...

# Commit
git commit -m "fix: resolve critical security vulnerability"

# Create hotfix tag
git tag -a "$HOTFIX_VERSION" -m "$(cat <<'EOF'
Hotfix v1.2.4

CRITICAL: Security vulnerability fix

Issue: SQL injection vulnerability in login endpoint
Fix: Add input sanitization and parameterized queries
Impact: All versions from v1.0.0 to v1.2.3

Action Required: Deploy immediately to production
EOF
)"

# Merge back to main
git checkout main
git merge hotfix/critical-security-fix
```

---

## Pushing Tags to Remote

### Push Single Tag

```bash
# Push specific tag
git push origin v1.2.3

# Verify tag pushed
git ls-remote --tags origin | grep v1.2.3
```

### Push All Tags

```bash
# Push all tags at once
git push origin --tags

# Or using --follow-tags (only annotated tags)
git push --follow-tags
```

### Delete Remote Tag (If Mistake)

```bash
# Delete local tag
git tag -d v1.2.3

# Delete remote tag
git push origin :refs/tags/v1.2.3

# Or using --delete flag
git push origin --delete v1.2.3
```

---

## Signed Tags (GPG)

### Creating Signed Tag

```bash
# Configure GPG key (one-time setup)
git config --global user.signingkey YOUR_GPG_KEY_ID

# Create signed tag
git tag -s v1.2.3 -m "Release v1.2.3"

# Verify signature
git tag -v v1.2.3
```

---

## Listing and Viewing Tags

### List Tags

```bash
# List all tags
git tag

# List tags matching pattern
git tag -l "v1.2.*"
git tag -l "v2.*"

# List with messages (annotated tags)
git tag -n
git tag -n5  # Show 5 lines of message

# Sort tags by version
git tag -l --sort=-version:refname

# Show latest tag
git describe --tags --abbrev=0
```

### View Tag Details

```bash
# Show tag information
git show v1.2.3

# Show tag commit
git rev-parse v1.2.3

# Show files at tag
git ls-tree -r v1.2.3 --name-only

# Show diff between tags
git diff v1.2.0..v1.2.3
git log v1.2.0..v1.2.3 --oneline
```

---

## Checking Out Tags

### Checkout Tag (Read-Only)

```bash
# Checkout tag (enters detached HEAD state)
git checkout v1.2.3

# View state at this tag
git status

# Return to branch
git checkout main
```

### Create Branch from Tag

```bash
# Create branch from tag for making changes
git checkout -b hotfix/from-v1.2.3 v1.2.3

# Or two-step
git checkout v1.2.3
git checkout -b hotfix/from-v1.2.3
```

---

## Integration with GitHub Releases

### Create GitHub Release from Tag

```bash
# Create tag first
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3

# Create GitHub release from tag
gh release create v1.2.3 \
  --title "Release v1.2.3" \
  --notes "$(cat <<'EOF'
## What's New

### Features
- User authentication with JWT
- Real-time notifications
- Dark mode support

### Bug Fixes
- Fix login redirect issue
- Resolve memory leak

### Breaking Changes
- User API endpoint response format changed
- See migration guide: MIGRATION.md

## Installation

npm install @org/package@1.2.3

## Full Changelog
https://github.com/org/repo/compare/v1.2.0...v1.2.3
EOF
)"

# Create release with artifacts
gh release create v1.2.3 \
  --title "Release v1.2.3" \
  --notes "Release notes" \
  dist/app-v1.2.3.zip \
  dist/checksums.txt
```

### List GitHub Releases

```bash
# List releases
gh release list

# View specific release
gh release view v1.2.3

# Download release assets
gh release download v1.2.3
```

---

## Tag Naming Conventions

### Standard Conventions

```bash
# Semantic versioning (RECOMMENDED)
v1.2.3
v2.0.0-beta.1

# Without 'v' prefix (alternative)
1.2.3
2.0.0-rc.1

# Dated releases
v2024.12.11
release-2024-12-11

# Environment-specific
prod/v1.2.3
staging/v1.2.3-rc.1

# Build tags
build/2024-12-11-123
deploy/production-v1.2.3
```

### Project-Specific Tags

```bash
# Mobile app versions
ios/v1.2.3
android/v1.2.3
mobile/v1.2.3

# Service-specific (monorepo)
api/v1.2.3
frontend/v1.2.3
backend/v1.2.3

# Component releases
@components/v1.0.0
@shared/v2.1.0
```

---

## Automated Tagging

### Tag from CI/CD

```bash
# In GitHub Actions workflow
name: Create Release Tag
on:
  push:
    branches: [main]

jobs:
  tag:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for versioning

      - name: Determine version
        id: version
        run: |
          # Calculate next version based on commits
          LATEST=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
          # Version bump logic here
          echo "version=$NEXT_VERSION" >> $GITHUB_OUTPUT

      - name: Create tag
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git tag -a "${{ steps.version.outputs.version }}" -m "Release ${{ steps.version.outputs.version }}"
          git push origin "${{ steps.version.outputs.version }}"

      - name: Create GitHub release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ steps.version.outputs.version }}
          release_name: Release ${{ steps.version.outputs.version }}
```

---

## Best Practices

1. **Use Semantic Versioning**: Follow semver for predictable versioning
2. **Annotated Tags for Releases**: Always use `git tag -a` for release tags
3. **Meaningful Messages**: Include changelog in tag message
4. **Tag from Main**: Create release tags from main/master branch
5. **Clean State**: Ensure no uncommitted changes before tagging
6. **Test First**: Run tests and build before creating tag
7. **Sign Tags**: Use GPG signatures for security-critical releases
8. **Push Tags**: Don't forget to push tags to remote
9. **GitHub Releases**: Create GitHub releases for public visibility
10. **Never Move Tags**: Don't delete and recreate tags with same name

---

## Common Workflows

### Standard Release Process

```bash
# 1. Ensure on main branch with latest changes
git checkout main
git pull origin main

# 2. Run quality checks
npm test
npm run build
npm run lint

# 3. Determine next version
PREV_TAG=$(git describe --tags --abbrev=0)
# Analyze commits and determine bump type
NEXT_VERSION="v1.2.3"

# 4. Update version in package.json (if applicable)
npm version 1.2.3 --no-git-tag-version
git add package.json package-lock.json
git commit -m "chore: bump version to 1.2.3"

# 5. Create tag
git tag -a "$NEXT_VERSION" -m "Release $NEXT_VERSION"

# 6. Push everything
git push origin main
git push origin "$NEXT_VERSION"

# 7. Create GitHub release
gh release create "$NEXT_VERSION" --generate-notes
```

### Emergency Hotfix Process

```bash
# 1. Checkout production tag
git checkout v1.2.3

# 2. Create hotfix branch
git checkout -b hotfix/security-fix

# 3. Make urgent fix
# ... code changes ...
git commit -m "fix: resolve critical security issue"

# 4. Create hotfix tag
git tag -a v1.2.4 -m "Hotfix v1.2.4: Critical security fix"

# 5. Push hotfix
git push origin hotfix/security-fix
git push origin v1.2.4

# 6. Merge to main
git checkout main
git merge hotfix/security-fix
git push origin main

# 7. Clean up
git branch -d hotfix/security-fix
```

---

## Error Handling

### Tag Already Exists

```bash
# Error: tag 'v1.2.3' already exists
# Solution 1: Use different version
git tag -a v1.2.4 -m "Release v1.2.4"

# Solution 2: Delete and recreate (NOT RECOMMENDED if pushed)
git tag -d v1.2.3
git tag -a v1.2.3 -m "Release v1.2.3"

# Solution 3: Force update (DANGEROUS)
git tag -f -a v1.2.3 -m "Release v1.2.3"
```

### Uncommitted Changes

```bash
# Error: refusing to create tag with uncommitted changes
# Solution: Commit or stash
git add .
git commit -m "chore: prepare for release"
# Then create tag
```

### Wrong Branch

```bash
# Created tag on wrong branch
# Solution: Delete tag and recreate
git tag -d v1.2.3
git checkout main
git tag -a v1.2.3 -m "Release v1.2.3"
```

---

## Reporting Format

```markdown
## Release Tag Created

**Version**: v1.2.3
**Type**: Annotated Tag
**Branch**: main
**Commit**: abc123d

### Version Bump
- Previous: v1.2.0
- Current: v1.2.3
- Type: MINOR (new features)

### Changes Summary
- Features: 5
- Bug Fixes: 3
- Breaking Changes: 0

### Tag Message
Release v1.2.3

Features:
- User authentication with JWT
- Real-time notifications
- Dark mode support

Bug Fixes:
- Fix login redirect issue
- Resolve memory leak
- Correct form validation

### Status
✅ Tag created locally
✅ Tag pushed to origin
✅ GitHub release created

**Next Steps**:
1. Verify CI/CD deployment triggered
2. Monitor production deployment
3. Update release documentation
4. Announce release to team
```

---

## Related Components

- `prompts/git/branch-creation.md` - Create release branches
- `prompts/git/commit-formatting.md` - Format commits for changelog
- `prompts/git/pr-creation.md` - Create release PRs
- `prompts/git/status-validation.md` - Validate before tagging
