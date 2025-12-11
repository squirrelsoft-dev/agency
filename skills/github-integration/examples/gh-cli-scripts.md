# GitHub CLI Script Examples

Practical shell scripts demonstrating common GitHub automation patterns using the gh CLI. These scripts can be used directly or adapted for specific workflows.

## Issue Management Scripts

### Create Issue from Template

```bash
#!/bin/bash
# create-bug-report.sh - Create a bug report issue

TITLE="$1"
DESCRIPTION="$2"

if [ -z "$TITLE" ]; then
  echo "Usage: $0 'Title' 'Description'"
  exit 1
fi

gh issue create \
  --title "$TITLE" \
  --body "$DESCRIPTION" \
  --label bug \
  --label needs-triage

```

### Bulk Label Issues

```bash
#!/bin/bash
# bulk-label.sh - Add label to multiple issues

LABEL="$1"
shift
ISSUE_NUMBERS=("$@")

for issue in "${ISSUE_NUMBERS[@]}"; do
  gh issue edit "$issue" --add-label "$LABEL"
  echo "Added '$LABEL' to issue #$issue"
done
```

### Find Stale Issues

```bash
#!/bin/bash
# find-stale-issues.sh - Find issues with no activity for 30 days

DAYS_STALE=30
DATE_THRESHOLD=$(date -d "$DAYS_STALE days ago" +%Y-%m-%d 2>/dev/null || date -v-${DAYS_STALE}d +%Y-%m-%d)

gh issue list \
  --state open \
  --json number,title,updatedAt \
  --jq ".[] | select(.updatedAt < \"$DATE_THRESHOLD\") | \"#\(.number): \(.title)\""
```

### Close Issues by Label

```bash
#!/bin/bash
# close-by-label.sh - Close all issues with specific label

LABEL="$1"
REASON="${2:-completed}"

if [ -z "$LABEL" ]; then
  echo "Usage: $0 <label> [reason]"
  exit 1
fi

gh issue list --label "$LABEL" --json number --jq '.[].number' | while read -r num; do
  gh issue close "$num" --reason "$REASON" --comment "Closing issues labeled '$LABEL'"
  echo "Closed issue #$num"
done
```

### Report Issue Statistics

```bash
#!/bin/bash
# issue-stats.sh - Generate issue statistics report

echo "=== Issue Statistics ==="
echo ""

TOTAL=$(gh issue list --state all --json number --jq 'length')
OPEN=$(gh issue list --state open --json number --jq 'length')
CLOSED=$(gh issue list --state closed --json number --jq 'length')

echo "Total Issues: $TOTAL"
echo "Open: $OPEN"
echo "Closed: $CLOSED"
echo ""

echo "=== Top Labels ==="
gh issue list --state open --json labels --jq '.[].labels[].name' | sort | uniq -c | sort -rn | head -5

echo ""
echo "=== Issues by Assignee ==="
gh issue list --state open --json assignees --jq '.[].assignees[].login' | sort | uniq -c | sort -rn
```

---

## Pull Request Scripts

### Create PR with Template

```bash
#!/bin/bash
# create-pr.sh - Create pull request with standard template

TITLE="$1"
BASE="${2:-main}"

if [ -z "$TITLE" ]; then
  echo "Usage: $0 'PR Title' [base-branch]"
  exit 1
fi

BODY=$(cat <<EOF
## Summary
[Description of changes]

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No breaking changes
EOF
)

gh pr create \
  --title "$TITLE" \
  --body "$BODY" \
  --base "$BASE" \
  --draft
```

### Auto-merge When Ready

```bash
#!/bin/bash
# auto-merge-pr.sh - Enable auto-merge for PR

PR_NUMBER="$1"
MERGE_METHOD="${2:-squash}"

if [ -z "$PR_NUMBER" ]; then
  echo "Usage: $0 <pr-number> [merge-method]"
  exit 1
fi

gh pr merge "$PR_NUMBER" --auto --"$MERGE_METHOD"
echo "Auto-merge enabled for PR #$PR_NUMBER"
```

### List PRs Waiting for Review

```bash
#!/bin/bash
# prs-waiting-review.sh - List PRs awaiting review

echo "=== PRs Waiting for Review ==="

gh pr list \
  --state open \
  --json number,title,author,reviewDecision,isDraft \
  --jq '.[] | select(.isDraft == false and .reviewDecision == null) | "#\(.number): \(.title) (@\(.author.login))"'
```

### Check PR Status

```bash
#!/bin/bash
# check-pr-status.sh - Check if PR is ready to merge

PR_NUMBER="$1"

if [ -z "$PR_NUMBER" ]; then
  echo "Usage: $0 <pr-number>"
  exit 1
fi

echo "Checking PR #$PR_NUMBER..."

# Get PR details
PR_DATA=$(gh pr view "$PR_NUMBER" --json mergeable,mergeStateStatus,isDraft,reviewDecision)

IS_DRAFT=$(echo "$PR_DATA" | jq -r '.isDraft')
MERGEABLE=$(echo "$PR_DATA" | jq -r '.mergeable')
STATE=$(echo "$PR_DATA" | jq -r '.mergeStateStatus')
REVIEW=$(echo "$PR_DATA" | jq -r '.reviewDecision')

echo "Draft: $IS_DRAFT"
echo "Mergeable: $MERGEABLE"
echo "State: $STATE"
echo "Review Decision: $REVIEW"

if [ "$IS_DRAFT" = "false" ] && [ "$MERGEABLE" = "MERGEABLE" ] && [ "$REVIEW" = "APPROVED" ]; then
  echo "✅ PR is ready to merge!"
  exit 0
else
  echo "❌ PR is not ready to merge"
  exit 1
fi
```

### List Merge Conflicts

```bash
#!/bin/bash
# list-merge-conflicts.sh - Find PRs with merge conflicts

echo "=== PRs with Merge Conflicts ==="

gh pr list \
  --state open \
  --json number,title,mergeable \
  --jq '.[] | select(.mergeable == "CONFLICTING") | "#\(.number): \(.title)"'
```

---

## Project Management Scripts

### Add Issues to Milestone

```bash
#!/bin/bash
# add-to-milestone.sh - Add labeled issues to milestone

LABEL="$1"
MILESTONE="$2"

if [ -z "$MILESTONE" ]; then
  echo "Usage: $0 <label> <milestone>"
  exit 1
fi

gh issue list --label "$LABEL" --json number --jq '.[].number' | while read -r num; do
  gh issue edit "$num" --milestone "$MILESTONE"
  echo "Added issue #$num to milestone '$MILESTONE'"
done
```

### Sprint Report

```bash
#!/bin/bash
# sprint-report.sh - Generate sprint report

MILESTONE="$1"

if [ -z "$MILESTONE" ]; then
  echo "Usage: $0 <milestone>"
  exit 1
fi

echo "=== Sprint Report: $MILESTONE ==="
echo ""

TOTAL=$(gh issue list --milestone "$MILESTONE" --state all --json number --jq 'length')
COMPLETED=$(gh issue list --milestone "$MILESTONE" --state closed --json number --jq 'length')
IN_PROGRESS=$(gh issue list --milestone "$MILESTONE" --state open --label in-progress --json number --jq 'length')
TODO=$(gh issue list --milestone "$MILESTONE" --state open --json number --jq 'length')

echo "Total Stories: $TOTAL"
echo "Completed: $COMPLETED"
echo "In Progress: $IN_PROGRESS"
echo "To Do: $TODO"

if [ "$TOTAL" -gt 0 ]; then
  VELOCITY=$(( COMPLETED * 100 / TOTAL ))
  echo "Velocity: ${VELOCITY}%"
fi

echo ""
echo "=== Remaining Work ==="
gh issue list --milestone "$MILESTONE" --state open --json number,title,assignees \
  --jq '.[] | "#\(.number): \(.title) (\(.assignees | map(.login) | join(", ")))"'
```

### Create Sprint Milestone

```bash
#!/bin/bash
# create-sprint.sh - Create sprint milestone

SPRINT_NAME="$1"
DUE_DATE="$2"

if [ -z "$DUE_DATE" ]; then
  echo "Usage: $0 'Sprint Name' 'YYYY-MM-DD'"
  exit 1
fi

gh api repos/:owner/:repo/milestones \
  -f title="$SPRINT_NAME" \
  -f due_on="${DUE_DATE}T00:00:00Z" \
  -f state="open"

echo "Created milestone: $SPRINT_NAME (due $DUE_DATE)"
```

---

## Repository Management Scripts

### Clone All Organization Repos

```bash
#!/bin/bash
# clone-org-repos.sh - Clone all repos from organization

ORG="$1"
TARGET_DIR="${2:-.}"

if [ -z "$ORG" ]; then
  echo "Usage: $0 <org-name> [target-dir]"
  exit 1
fi

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || exit 1

gh repo list "$ORG" --limit 1000 --json name --jq '.[].name' | while read -r repo; do
  if [ ! -d "$repo" ]; then
    echo "Cloning $repo..."
    gh repo clone "$ORG/$repo"
  else
    echo "Skipping $repo (already exists)"
  fi
done
```

### List Repository Statistics

```bash
#!/bin/bash
# repo-stats.sh - Display repository statistics

REPO="${1:-.}"

echo "=== Repository Statistics ==="
echo ""

REPO_DATA=$(gh repo view "$REPO" --json name,owner,description,stargazersCount,forksCount,openIssuesCount,pushedAt)

echo "Repository: $(echo "$REPO_DATA" | jq -r '.owner.login')/$(echo "$REPO_DATA" | jq -r '.name')"
echo "Description: $(echo "$REPO_DATA" | jq -r '.description')"
echo "Stars: $(echo "$REPO_DATA" | jq -r '.stargazersCount')"
echo "Forks: $(echo "$REPO_DATA" | jq -r '.forksCount')"
echo "Open Issues: $(echo "$REPO_DATA" | jq -r '.openIssuesCount')"
echo "Last Push: $(echo "$REPO_DATA" | jq -r '.pushedAt')"
```

### Archive Old Repositories

```bash
#!/bin/bash
# archive-old-repos.sh - Archive repositories with no activity for 1 year

ORG="$1"
DAYS_INACTIVE=365

if [ -z "$ORG" ]; then
  echo "Usage: $0 <org-name>"
  exit 1
fi

DATE_THRESHOLD=$(date -d "$DAYS_INACTIVE days ago" +%Y-%m-%d 2>/dev/null || date -v-${DAYS_INACTIVE}d +%Y-%m-%d)

gh repo list "$ORG" --limit 1000 --json name,pushedAt | \
  jq -r ".[] | select(.pushedAt < \"$DATE_THRESHOLD\") | .name" | \
  while read -r repo; do
    echo "Archiving $ORG/$repo (last push: before $DATE_THRESHOLD)"
    gh repo archive "$ORG/$repo" --yes
  done
```

---

## Release Management Scripts

### Create Release from Tag

```bash
#!/bin/bash
# create-release.sh - Create GitHub release

TAG="$1"
TITLE="${2:-Release $TAG}"

if [ -z "$TAG" ]; then
  echo "Usage: $0 <tag> [title]"
  exit 1
fi

gh release create "$TAG" \
  --title "$TITLE" \
  --generate-notes
```

### Upload Release Assets

```bash
#!/bin/bash
# upload-assets.sh - Upload assets to release

TAG="$1"
shift
ASSETS=("$@")

if [ ${#ASSETS[@]} -eq 0 ]; then
  echo "Usage: $0 <tag> <asset1> [asset2...]"
  exit 1
fi

for asset in "${ASSETS[@]}"; do
  if [ -f "$asset" ]; then
    gh release upload "$TAG" "$asset"
    echo "Uploaded $asset"
  else
    echo "File not found: $asset"
  fi
done
```

### Download Latest Release

```bash
#!/bin/bash
# download-latest.sh - Download latest release assets

TARGET_DIR="${1:-.}"

mkdir -p "$TARGET_DIR"

echo "Downloading latest release assets..."
gh release download --dir "$TARGET_DIR"

echo "Assets downloaded to $TARGET_DIR"
```

---

## Workflow Automation Scripts

### Trigger Workflow

```bash
#!/bin/bash
# trigger-workflow.sh - Trigger GitHub Actions workflow

WORKFLOW="$1"
shift

if [ -z "$WORKFLOW" ]; then
  echo "Usage: $0 <workflow-name> [key=value...]"
  exit 1
fi

# Parse key=value inputs
INPUTS=()
for arg in "$@"; do
  if [[ $arg == *"="* ]]; then
    INPUTS+=(-f "$arg")
  fi
done

if [ ${#INPUTS[@]} -gt 0 ]; then
  gh workflow run "$WORKFLOW" "${INPUTS[@]}"
else
  gh workflow run "$WORKFLOW"
fi

echo "Triggered workflow: $WORKFLOW"
```

### Monitor Workflow Run

```bash
#!/bin/bash
# monitor-run.sh - Monitor workflow run until completion

RUN_ID="${1:-$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')}"

if [ -z "$RUN_ID" ]; then
  echo "No run ID specified and no recent runs found"
  exit 1
fi

echo "Monitoring run $RUN_ID..."

gh run watch "$RUN_ID"

# Check final status
STATUS=$(gh run view "$RUN_ID" --json conclusion --jq '.conclusion')

if [ "$STATUS" = "success" ]; then
  echo "✅ Run completed successfully"
  exit 0
else
  echo "❌ Run failed with status: $STATUS"
  exit 1
fi
```

### List Failed Runs

```bash
#!/bin/bash
# list-failed-runs.sh - List recent failed workflow runs

WORKFLOW="${1:-}"

if [ -n "$WORKFLOW" ]; then
  gh run list --workflow "$WORKFLOW" --status failure --limit 20
else
  gh run list --status failure --limit 20
fi
```

---

## Search and Reporting Scripts

### Find Issues by Keyword

```bash
#!/bin/bash
# search-issues.sh - Search issues by keyword

KEYWORD="$1"

if [ -z "$KEYWORD" ]; then
  echo "Usage: $0 <keyword>"
  exit 1
fi

gh issue list --search "$KEYWORD" --json number,title,state,labels \
  --jq '.[] | "#\(.number): \(.title) [\(.state)] (\(.labels | map(.name) | join(", ")))"'
```

### Generate Weekly Report

```bash
#!/bin/bash
# weekly-report.sh - Generate weekly activity report

SINCE_DATE=$(date -d "7 days ago" +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d)

echo "=== Weekly Report (since $SINCE_DATE) ==="
echo ""

echo "=== New Issues ==="
gh issue list --state all --json number,title,createdAt \
  --jq ".[] | select(.createdAt > \"$SINCE_DATE\") | \"#\(.number): \(.title)\""

echo ""
echo "=== Closed Issues ==="
gh issue list --state closed --json number,title,closedAt \
  --jq ".[] | select(.closedAt > \"$SINCE_DATE\") | \"#\(.number): \(.title)\""

echo ""
echo "=== Merged PRs ==="
gh pr list --state merged --json number,title,mergedAt \
  --jq ".[] | select(.mergedAt > \"$SINCE_DATE\") | \"#\(.number): \(.title)\""
```

### Find Most Active Contributors

```bash
#!/bin/bash
# top-contributors.sh - Find most active contributors

LIMIT="${1:-10}"

echo "=== Top $LIMIT Contributors (by PRs) ==="

gh pr list --state all --json author --jq '.[].author.login' | \
  sort | uniq -c | sort -rn | head -n "$LIMIT"
```

---

## Utility Scripts

### Setup Repository

```bash
#!/bin/bash
# setup-repo.sh - Setup standard labels and milestones

echo "Setting up repository..."

# Create standard labels
LABELS=(
  "bug:d73a4a:Something isn't working"
  "feature:a2eeef:New feature or request"
  "enhancement:84b6eb:Improvement to existing feature"
  "documentation:0075ca:Documentation updates"
  "high-priority:ff0000:Urgent issue"
  "in-progress:fbca04:Currently being worked on"
  "needs-review:c2e0c6:Awaiting code review"
)

for label in "${LABELS[@]}"; do
  IFS=':' read -r name color description <<< "$label"
  gh label create "$name" --color "$color" --description "$description" 2>/dev/null || \
    gh label edit "$name" --color "$color" --description "$description"
  echo "Created/updated label: $name"
done

echo "Repository setup complete!"
```

### Backup Issues

```bash
#!/bin/bash
# backup-issues.sh - Export all issues to JSON

OUTPUT_FILE="${1:-issues-backup-$(date +%Y%m%d).json}"

echo "Backing up issues to $OUTPUT_FILE..."

gh issue list --state all --limit 1000 --json number,title,body,state,labels,assignees,createdAt,closedAt > "$OUTPUT_FILE"

echo "Backup complete: $(jq 'length' "$OUTPUT_FILE") issues exported"
```

### Sync Labels Across Repos

```bash
#!/bin/bash
# sync-labels.sh - Sync labels from one repo to another

SOURCE_REPO="$1"
TARGET_REPO="$2"

if [ -z "$TARGET_REPO" ]; then
  echo "Usage: $0 <source-repo> <target-repo>"
  exit 1
fi

echo "Syncing labels from $SOURCE_REPO to $TARGET_REPO..."

gh label list --repo "$SOURCE_REPO" --json name,color,description --jq '.[]' | \
  jq -c '.' | \
  while read -r label; do
    NAME=$(echo "$label" | jq -r '.name')
    COLOR=$(echo "$label" | jq -r '.color')
    DESCRIPTION=$(echo "$label" | jq -r '.description')

    gh label create "$NAME" --color "$COLOR" --description "$DESCRIPTION" --repo "$TARGET_REPO" 2>/dev/null || \
      gh label edit "$NAME" --color "$COLOR" --description "$DESCRIPTION" --repo "$TARGET_REPO"

    echo "Synced label: $NAME"
  done

echo "Label sync complete!"
```

---

## Notes

- All scripts assume `gh` CLI is installed and authenticated
- Set `GH_REPO` environment variable to specify default repository: `export GH_REPO=owner/repo`
- Use `--repo owner/repo` flag to override default repository in any command
- For production use, add proper error handling and logging to these scripts
- Consider rate limits when running bulk operations (5000 requests/hour for authenticated users)
