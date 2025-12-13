---
description: Create git worktrees for issues, sprints, milestones, or epics for parallel development
argument-hint: <identifier> [--issue|--epic|--milestone|--sprint] [--cleanup]
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, TodoWrite, AskUserQuestion
---

# Worktree Management: $ARGUMENTS

Create isolated git worktrees for parallel issue development or clean up completed worktrees.

**Git worktrees** enable you to work on multiple issues simultaneously without branch switching. Each worktree is an independent working directory with its own branch, allowing true parallel development.

## Your Mission

Execute worktree operation: **$ARGUMENTS**

**Creation Mode** (default):
- Fetch issue(s) from GitHub or Jira
- Create git worktrees in parent directory (siblings to current repo)
- Provide clear instructions for working in each worktree

**Cleanup Mode** (`--cleanup` flag):
- Remove worktrees for specified grouping (sprint/milestone/epic)
- Optionally delete associated branches
- Archive state tracking

**Explicit Type Flags** (optional):
- `--issue`: Treat identifier as single issue
- `--epic`: Treat identifier as epic (Jira) or milestone (GitHub fallback)
- `--milestone`: Treat identifier as milestone (GitHub) or sprint (Jira fallback)
- `--sprint`: Treat identifier as sprint (Jira) or milestone (GitHub fallback)

**Usage Examples**:
```bash
# Auto-detect (works with URLs and clear patterns)
/agency:worktree 123
/agency:worktree https://github.com/org/repo/issues/123

# Explicit type (when identifier is ambiguous)
/agency:worktree 123 --issue          # Force treat as single issue
/agency:worktree PROJ-123 --epic      # Force treat as Jira epic
/agency:worktree 5 --milestone        # Force treat as GitHub milestone
/agency:worktree 42 --sprint          # Force treat as Jira sprint

# Cleanup
/agency:worktree milestone-5 --cleanup
```

---

## Critical Instructions

### 1. Use TodoWrite Throughout

Track progress at every major step:
- Arguments parsed ✅
- Issues fetched (3/5) 🔄
- Worktrees created (2/3) 🔄
- Instructions generated ✅

### 2. Error Handling

Be resilient:
- **Critical errors**: Display helpful message and exit
- **Recoverable errors**: Ask user for guidance
- **Partial failures**: Continue with successful operations

---

## Phase 0: Argument Parsing & Provider Detection

Parse `$ARGUMENTS` to determine operation mode and platform.

### Step 0.1: Parse Flags

```bash
# Parse all flags
CLEANUP_FLAG=false
EXPLICIT_TYPE=""  # Can be: issue, epic, milestone, sprint
ARGUMENTS_CLEAN="$ARGUMENTS"

# Check for --cleanup flag
if [[ "$ARGUMENTS" == *"--cleanup"* ]]; then
  CLEANUP_FLAG=true
  ARGUMENTS_CLEAN=$(echo "$ARGUMENTS_CLEAN" | sed 's/--cleanup//g' | xargs)
fi

# Check for explicit type flags
if [[ "$ARGUMENTS" == *"--issue"* ]]; then
  EXPLICIT_TYPE="issue"
  ARGUMENTS_CLEAN=$(echo "$ARGUMENTS_CLEAN" | sed 's/--issue//g' | xargs)
elif [[ "$ARGUMENTS" == *"--epic"* ]]; then
  EXPLICIT_TYPE="epic"
  ARGUMENTS_CLEAN=$(echo "$ARGUMENTS_CLEAN" | sed 's/--epic//g' | xargs)
elif [[ "$ARGUMENTS" == *"--milestone"* ]]; then
  EXPLICIT_TYPE="milestone"
  ARGUMENTS_CLEAN=$(echo "$ARGUMENTS_CLEAN" | sed 's/--milestone//g' | xargs)
elif [[ "$ARGUMENTS" == *"--sprint"* ]]; then
  EXPLICIT_TYPE="sprint"
  ARGUMENTS_CLEAN=$(echo "$ARGUMENTS_CLEAN" | sed 's/--sprint//g' | xargs)
fi

echo "Operation mode: $([ "$CLEANUP_FLAG" = true ] && echo "CLEANUP" || echo "CREATE")"
if [ -n "$EXPLICIT_TYPE" ]; then
  echo "Explicit type: $EXPLICIT_TYPE"
fi
echo "Arguments: $ARGUMENTS_CLEAN"
```

### Step 0.2: Detect Grouping Type

```bash
# Initialize variables
GROUPING_TYPE=""
PROVIDER=""
ISSUE_NUM=""
ISSUE_KEY=""
MILESTONE_NUM=""
SPRINT_ID=""
EPIC_KEY=""
GROUPING_ID=""
GROUPING_DISPLAY=""

# If explicit type flag provided, use it
if [ -n "$EXPLICIT_TYPE" ]; then
  echo "Using explicit type: $EXPLICIT_TYPE"

  # Detect provider from argument or git remote
  if [[ "$ARGUMENTS_CLEAN" =~ github\.com ]] || [[ "$ARGUMENTS_CLEAN" =~ ^[0-9]+$ && $(git remote get-url origin 2>/dev/null) =~ github\.com ]]; then
    PROVIDER="github"
  elif [[ "$ARGUMENTS_CLEAN" =~ atlassian\.net ]] || [[ "$ARGUMENTS_CLEAN" =~ ^[A-Z]+-[0-9]+$ ]]; then
    PROVIDER="jira"
  else
    # Fallback: check git remote
    GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ "$GIT_REMOTE" =~ github\.com ]]; then
      PROVIDER="github"
    else
      PROVIDER="jira"
    fi
  fi

  # Set grouping type based on explicit flag and provider
  case "$EXPLICIT_TYPE" in
    issue)
      if [ "$PROVIDER" = "github" ]; then
        GROUPING_TYPE="single-github"
        ISSUE_NUM="$ARGUMENTS_CLEAN"
        GROUPING_ID="issue-${ISSUE_NUM}"
        echo "✓ Treating as GitHub issue #${ISSUE_NUM}"
      else
        GROUPING_TYPE="single-jira"
        ISSUE_KEY="$ARGUMENTS_CLEAN"
        GROUPING_ID="issue-${ISSUE_KEY}"
        echo "✓ Treating as Jira issue ${ISSUE_KEY}"
      fi
      ;;

    epic)
      if [ "$PROVIDER" = "github" ]; then
        echo "⚠️  Warning: GitHub doesn't have native epics"
        echo "Treating as milestone instead"
        GROUPING_TYPE="milestone-github"
        MILESTONE_NUM="$ARGUMENTS_CLEAN"
        GROUPING_ID="milestone-${MILESTONE_NUM}"
        echo "✓ Treating as GitHub milestone #${MILESTONE_NUM}"
      else
        GROUPING_TYPE="epic-jira"
        EPIC_KEY="$ARGUMENTS_CLEAN"
        GROUPING_ID="epic-${EPIC_KEY}"
        echo "✓ Treating as Jira epic ${EPIC_KEY}"
      fi
      ;;

    milestone)
      if [ "$PROVIDER" = "github" ]; then
        GROUPING_TYPE="milestone-github"
        MILESTONE_NUM="$ARGUMENTS_CLEAN"
        GROUPING_ID="milestone-${MILESTONE_NUM}"
        echo "✓ Treating as GitHub milestone #${MILESTONE_NUM}"
      else
        echo "⚠️  Warning: Jira uses sprints, not milestones"
        echo "Treating as sprint instead"
        GROUPING_TYPE="sprint-jira"
        SPRINT_ID="$ARGUMENTS_CLEAN"
        GROUPING_ID="sprint-${SPRINT_ID}"
        echo "✓ Treating as Jira sprint ${SPRINT_ID}"
      fi
      ;;

    sprint)
      if [ "$PROVIDER" = "github" ]; then
        echo "⚠️  Warning: GitHub uses milestones, not sprints"
        echo "Treating as milestone instead"
        GROUPING_TYPE="milestone-github"
        MILESTONE_NUM="$ARGUMENTS_CLEAN"
        GROUPING_ID="milestone-${MILESTONE_NUM}"
        echo "✓ Treating as GitHub milestone #${MILESTONE_NUM}"
      else
        GROUPING_TYPE="sprint-jira"
        SPRINT_ID="$ARGUMENTS_CLEAN"
        GROUPING_ID="sprint-${SPRINT_ID}"
        echo "✓ Treating as Jira sprint ${SPRINT_ID}"
      fi
      ;;
  esac

# Auto-detect from URL patterns and formats
elif [[ "$ARGUMENTS_CLEAN" =~ github\.com/([^/]+)/([^/]+)/issues/([0-9]+) ]]; then
  PROVIDER="github"
  GROUPING_TYPE="single-github"
  ISSUE_NUM="${BASH_REMATCH[3]}"
  GROUPING_ID="issue-${ISSUE_NUM}"
  echo "✓ Detected: GitHub issue #${ISSUE_NUM}"

elif [[ "$ARGUMENTS_CLEAN" =~ github\.com/([^/]+)/([^/]+)/milestone/([0-9]+) ]]; then
  PROVIDER="github"
  GROUPING_TYPE="milestone-github"
  MILESTONE_NUM="${BASH_REMATCH[3]}"
  GROUPING_ID="milestone-${MILESTONE_NUM}"
  echo "✓ Detected: GitHub milestone #${MILESTONE_NUM}"

# Jira URL Patterns
elif [[ "$ARGUMENTS_CLEAN" =~ atlassian\.net/browse/([A-Z]+-[0-9]+) ]]; then
  PROVIDER="jira"
  ISSUE_KEY="${BASH_REMATCH[1]}"
  GROUPING_TYPE="single-jira"
  GROUPING_ID="issue-${ISSUE_KEY}"
  echo "✓ Detected: Jira issue ${ISSUE_KEY}"

elif [[ "$ARGUMENTS_CLEAN" =~ rapidView=([0-9]+).*sprint=([0-9]+) ]]; then
  PROVIDER="jira"
  GROUPING_TYPE="sprint-jira"
  SPRINT_ID="${BASH_REMATCH[2]}"
  GROUPING_ID="sprint-${SPRINT_ID}"
  echo "✓ Detected: Jira sprint ${SPRINT_ID}"

# Jira Key Format (PROJ-123)
elif [[ "$ARGUMENTS_CLEAN" =~ ^([A-Z]+-[0-9]+)$ ]]; then
  PROVIDER="jira"
  ISSUE_KEY="${BASH_REMATCH[1]}"
  GROUPING_TYPE="single-jira"
  GROUPING_ID="issue-${ISSUE_KEY}"
  echo "✓ Detected: Jira issue ${ISSUE_KEY}"

# Pure Number (ambiguous)
elif [[ "$ARGUMENTS_CLEAN" =~ ^[0-9]+$ ]]; then
  # Check git remote for hints
  GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")

  if [[ "$GIT_REMOTE" =~ github\.com ]]; then
    # Likely GitHub - but still ambiguous (issue vs milestone)
    echo "⚠️  Ambiguous: Could be GitHub issue or milestone"

    # Ask user to clarify
    Use AskUserQuestion tool:
      question: "Is '${ARGUMENTS_CLEAN}' a GitHub issue number or milestone number?"
      header: "Clarify type"
      multiSelect: false
      options:
        - label: "GitHub issue #${ARGUMENTS_CLEAN}"
          description: "Single issue to create worktree for"
        - label: "GitHub milestone #${ARGUMENTS_CLEAN}"
          description: "Create worktrees for all issues in milestone"

    # Process response
    if [response contains "issue"]; then
      PROVIDER="github"
      GROUPING_TYPE="single-github"
      ISSUE_NUM="$ARGUMENTS_CLEAN"
      GROUPING_ID="issue-${ISSUE_NUM}"
    else
      PROVIDER="github"
      GROUPING_TYPE="milestone-github"
      MILESTONE_NUM="$ARGUMENTS_CLEAN"
      GROUPING_ID="milestone-${MILESTONE_NUM}"
    fi
  else
    # Likely Jira
    echo "⚠️  Ambiguous: Could be Jira issue or sprint"

    Use AskUserQuestion tool:
      question: "Is '${ARGUMENTS_CLEAN}' a Jira issue number or sprint ID?"
      header: "Clarify type"
      multiSelect: false
      options:
        - label: "Jira issue ${ARGUMENTS_CLEAN}"
          description: "Single issue to create worktree for"
        - label: "Jira sprint ${ARGUMENTS_CLEAN}"
          description: "Create worktrees for all issues in sprint"

    # Process response
    if [response contains "issue"]; then
      PROVIDER="jira"
      GROUPING_TYPE="single-jira"
      ISSUE_KEY="$ARGUMENTS_CLEAN"
      GROUPING_ID="issue-${ISSUE_KEY}"
    else
      PROVIDER="jira"
      GROUPING_TYPE="sprint-jira"
      SPRINT_ID="$ARGUMENTS_CLEAN"
      GROUPING_ID="sprint-${SPRINT_ID}"
    fi
  fi

# Text (check for epic or milestone name)
else
  # Check git remote first
  GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")

  if [[ "$GIT_REMOTE" =~ github\.com ]]; then
    PROVIDER="github"
    GROUPING_TYPE="milestone-github"
    MILESTONE_NUM="$ARGUMENTS_CLEAN"
    GROUPING_ID="milestone-${MILESTONE_NUM}"
    echo "✓ Detected: GitHub milestone '${MILESTONE_NUM}'"
  else
    # Assume Jira epic
    PROVIDER="jira"
    GROUPING_TYPE="epic-jira"
    EPIC_KEY="$ARGUMENTS_CLEAN"
    GROUPING_ID="epic-${EPIC_KEY}"
    echo "✓ Detected: Jira epic '${EPIC_KEY}'"
  fi
fi
```

### Step 0.3: Validate Detection

```bash
if [ -z "$GROUPING_TYPE" ] || [ -z "$PROVIDER" ]; then
  echo "❌ Error: Could not determine grouping type from: $ARGUMENTS_CLEAN"
  echo ""
  echo "Supported formats:"
  echo "  GitHub:"
  echo "    - Issue: 123 or https://github.com/owner/repo/issues/123"
  echo "    - Milestone: 5 or https://github.com/owner/repo/milestone/5"
  echo ""
  echo "  Jira:"
  echo "    - Issue: PROJ-123 or https://company.atlassian.net/browse/PROJ-123"
  echo "    - Sprint: sprint-id or sprint URL"
  echo "    - Epic: EPIC-456"
  echo ""
  echo "  Use explicit type flags to disambiguate:"
  echo "    - /agency:worktree 123 --issue       # Single issue"
  echo "    - /agency:worktree PROJ-123 --epic   # Jira epic"
  echo "    - /agency:worktree 5 --milestone     # GitHub milestone"
  echo "    - /agency:worktree 42 --sprint       # Jira sprint"
  echo ""
  echo "  Cleanup:"
  echo "    - /agency:worktree <grouping> --cleanup"
  exit 1
fi

echo ""
echo "Grouping ID: $GROUPING_ID"
echo "Provider: $PROVIDER"
echo "Type: $GROUPING_TYPE"
```

---

## Phase 1: Cleanup Mode (if --cleanup flag present)

**Skip this phase entirely if `CLEANUP_FLAG` is false**

### Step 1.1: Load State File

```bash
# State file location
REPO_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
STATE_DIR="${REPO_DIR}/.agency/worktrees"
STATE_FILE="${STATE_DIR}/${GROUPING_ID}-worktrees.json"

echo "Looking for state file: $STATE_FILE"

# Check if state file exists
if [ ! -f "$STATE_FILE" ]; then
  echo ""
  echo "ℹ️  No worktrees found for grouping: ${GROUPING_ID}"
  echo ""
  echo "State file does not exist: $STATE_FILE"
  echo ""
  echo "This could mean:"
  echo "  - No worktrees were created for this grouping"
  echo "  - Worktrees were already cleaned up"
  echo "  - Incorrect grouping ID specified"
  echo ""
  echo "To see all worktrees:"
  echo "  git worktree list"
  exit 0
fi

# Load state
WORKTREE_DATA=$(cat "$STATE_FILE")
WORKTREE_COUNT=$(echo "$WORKTREE_DATA" | jq -r '.worktrees | length')
GROUPING_DISPLAY=$(echo "$WORKTREE_DATA" | jq -r '.grouping_id')

echo "✓ Found ${WORKTREE_COUNT} worktrees for: ${GROUPING_DISPLAY}"
```

### Step 1.2: Display Worktrees

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Worktrees for ${GROUPING_DISPLAY}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# List each worktree
echo "$WORKTREE_DATA" | jq -r '.worktrees[] | "• Issue: \(if .issue_number then "#" + .issue_number else .issue_key end) - \(.issue_title)
  Branch: \(.branch_name)
  Path: \(.worktree_path)
  Status: \(.status)
"'

echo ""
```

### Step 1.3: Confirm Removal

```bash
Use AskUserQuestion tool:
  question: "Remove all ${WORKTREE_COUNT} worktrees for ${GROUPING_DISPLAY}?

⚠️  WARNING: This will:
  • Remove worktree directories (uncommitted changes will be LOST)
  • Keep branches (you can delete them separately)
  • Archive state tracking

This action CANNOT be undone!"

  header: "Confirm cleanup"
  multiSelect: false
  options:
    - label: "Yes, remove all worktrees"
      description: "Proceed with cleanup (branches will be kept)"
    - label: "No, cancel cleanup"
      description: "Exit without making changes"

# If user cancels
if [response contains "No"]; then
  echo "Cleanup cancelled by user."
  exit 0
fi
```

### Step 1.4: Remove Worktrees

```bash
echo ""
echo "Removing worktrees..."
echo ""

# Track results
REMOVED_COUNT=0
FAILED_COUNT=0
declare -a FAILED_WORKTREES

# Process each worktree
while IFS= read -r worktree; do
  WORKTREE_PATH=$(echo "$worktree" | jq -r '.worktree_path')
  BRANCH_NAME=$(echo "$worktree" | jq -r '.branch_name')
  ISSUE_ID=$(echo "$worktree" | jq -r 'if .issue_number then "#" + .issue_number else .issue_key end')

  echo "Removing worktree for ${ISSUE_ID}..."
  echo "  Path: $WORKTREE_PATH"

  # Check if worktree exists
  if [ ! -d "$WORKTREE_PATH" ]; then
    echo "  ⚠️  Directory not found (may have been manually deleted)"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
    continue
  fi

  # Check for uncommitted changes
  cd "$WORKTREE_PATH"
  if [ -n "$(git status --porcelain)" ]; then
    echo "  ⚠️  Uncommitted changes detected"

    # Show changes
    git status --short | head -n 10

    Use AskUserQuestion tool:
      question: "Worktree for ${ISSUE_ID} has uncommitted changes. What should I do?"
      header: "Uncommitted work"
      multiSelect: false
      options:
        - label: "Discard changes and remove"
          description: "Delete worktree with all uncommitted work (cannot be recovered)"
        - label: "Skip this worktree"
          description: "Keep this worktree, continue with others"
        - label: "Cancel entire cleanup"
          description: "Stop cleanup operation now"

    if [response contains "Cancel"]; then
      echo "Cleanup cancelled by user."
      exit 0
    elif [response contains "Skip"]; then
      echo "  ⏭️  Skipped"
      FAILED_WORKTREES+=("${ISSUE_ID}: Skipped (uncommitted changes)")
      FAILED_COUNT=$((FAILED_COUNT + 1))
      cd "$REPO_DIR"
      continue
    fi
    # If "Discard", continue to removal
  fi

  # Return to repo root
  cd "$REPO_DIR"

  # Remove worktree
  git worktree remove "$WORKTREE_PATH" --force 2>&1

  if [ $? -eq 0 ]; then
    echo "  ✅ Removed successfully"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  else
    echo "  ❌ Failed to remove"
    FAILED_WORKTREES+=("${ISSUE_ID}: Removal failed")
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi

  echo ""
done < <(echo "$WORKTREE_DATA" | jq -c '.worktrees[]')
```

### Step 1.5: Branch Cleanup (Optional)

```bash
# Ask about branch cleanup
Use AskUserQuestion tool:
  question: "Worktrees removed. Do you also want to delete the associated branches?

Branches:
$(echo "$WORKTREE_DATA" | jq -r '.worktrees[].branch_name' | sed 's/^/  • /')

⚠️  Note: Only delete branches if:
  • Work is merged or abandoned
  • No open pull requests exist"

  header: "Delete branches"
  multiSelect: false
  options:
    - label: "No, keep branches (Recommended)"
      description: "Branches remain available for future work or PRs"
    - label: "Yes, delete all branches"
      description: "Permanently delete all branches (cannot be recovered)"

if [response contains "Yes"]; then
  echo ""
  echo "Deleting branches..."
  echo ""

  while IFS= read -r branch; do
    echo "Deleting branch: $branch"
    git branch -D "$branch" 2>&1

    if [ $? -eq 0 ]; then
      echo "  ✅ Deleted"
    else
      echo "  ⚠️  Could not delete (may be checked out or protected)"
    fi
  done < <(echo "$WORKTREE_DATA" | jq -r '.worktrees[].branch_name')

  echo ""
  BRANCHES_DELETED=true
else
  BRANCHES_DELETED=false
fi
```

### Step 1.6: Archive State File

```bash
# Create archive directory
ARCHIVE_DIR="${STATE_DIR}/archive"
mkdir -p "$ARCHIVE_DIR"

# Archive with timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARCHIVE_FILE="${ARCHIVE_DIR}/${GROUPING_ID}-${TIMESTAMP}.json"

mv "$STATE_FILE" "$ARCHIVE_FILE"

echo "State archived to: ${ARCHIVE_FILE#$REPO_DIR/}"
```

### Step 1.7: Cleanup Report

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Worktree Cleanup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Grouping: ${GROUPING_DISPLAY}"
echo "Worktrees Removed: ${REMOVED_COUNT} / ${WORKTREE_COUNT}"

if [ ${FAILED_COUNT} -gt 0 ]; then
  echo "Failed/Skipped: ${FAILED_COUNT}"
  echo ""
  echo "Issues:"
  for failure in "${FAILED_WORKTREES[@]}"; do
    echo "  • $failure"
  done
fi

echo "Branches: $([ "$BRANCHES_DELETED" = true ] && echo "Deleted" || echo "Kept")"
echo ""
echo "Archived State: ${ARCHIVE_FILE#$REPO_DIR/}"
echo ""

if [ ${REMOVED_COUNT} -eq ${WORKTREE_COUNT} ]; then
  echo "✅ All worktrees cleaned up successfully!"
else
  echo "⚠️  Some worktrees were not removed. Check the issues above."
fi

echo ""
echo "To view remaining worktrees:"
echo "  git worktree list"
```

### Step 1.8: Exit (Skip to Phase 6)

```bash
# Cleanup mode complete - exit
exit 0
```

---

## Phase 2: Issue Fetching (CREATE mode only)

Fetch issue(s) from GitHub or Jira based on grouping type.

### Step 2.1: Initialize Issues Array

```bash
# Array to store issue data
declare -a ISSUES

echo ""
echo "Fetching issues..."
echo ""
```

### Step 2.2: Fetch Issues

**GitHub Single Issue:**
```bash
if [ "$GROUPING_TYPE" = "single-github" ]; then
  echo "Fetching GitHub issue #${ISSUE_NUM}..."

  # Fetch issue details
  ISSUE_DATA=$(gh issue view "$ISSUE_NUM" \
    --json number,title,labels,state \
    2>&1)

  if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Error: Could not fetch GitHub issue #${ISSUE_NUM}"
    echo ""
    echo "$ISSUE_DATA"
    echo ""
    echo "Possible causes:"
    echo "  • Issue does not exist"
    echo "  • No permission to view issue"
    echo "  • GitHub CLI not authenticated (run: gh auth login)"
    echo "  • Network connectivity issues"
    exit 1
  fi

  # Parse issue data
  ISSUE_TITLE=$(echo "$ISSUE_DATA" | jq -r '.title')
  ISSUE_STATE=$(echo "$ISSUE_DATA" | jq -r '.state')

  # Determine type from labels
  ISSUE_TYPE="feat"
  if echo "$ISSUE_DATA" | jq -e '.labels[] | select(.name | test("bug|fix"; "i"))' > /dev/null; then
    ISSUE_TYPE="fix"
  elif echo "$ISSUE_DATA" | jq -e '.labels[] | select(.name | test("refactor"; "i"))' > /dev/null; then
    ISSUE_TYPE="refactor"
  elif echo "$ISSUE_DATA" | jq -e '.labels[] | select(.name | test("docs|documentation"; "i"))' > /dev/null; then
    ISSUE_TYPE="docs"
  elif echo "$ISSUE_DATA" | jq -e '.labels[] | select(.name | test("chore"; "i"))' > /dev/null; then
    ISSUE_TYPE="chore"
  fi

  # Add to issues array
  ISSUES+=("$(jq -n \
    --arg num "$ISSUE_NUM" \
    --arg title "$ISSUE_TITLE" \
    --arg type "$ISSUE_TYPE" \
    --arg state "$ISSUE_STATE" \
    '{number: $num, title: $title, type: $type, state: $state}')")

  GROUPING_DISPLAY="Issue #${ISSUE_NUM}"

  echo "✓ Fetched: #${ISSUE_NUM} - ${ISSUE_TITLE} (${ISSUE_TYPE})"
fi
```

**GitHub Milestone:**
```bash
if [ "$GROUPING_TYPE" = "milestone-github" ]; then
  echo "Fetching GitHub milestone ${MILESTONE_NUM}..."

  # Get milestone name
  MILESTONE_DATA=$(gh api "repos/:owner/:repo/milestones/${MILESTONE_NUM}" 2>&1)

  if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Error: Could not fetch GitHub milestone ${MILESTONE_NUM}"
    echo ""
    echo "$MILESTONE_DATA"
    exit 1
  fi

  MILESTONE_TITLE=$(echo "$MILESTONE_DATA" | jq -r '.title')
  GROUPING_DISPLAY="Milestone: ${MILESTONE_TITLE}"

  # Fetch all open issues in milestone
  ISSUES_DATA=$(gh issue list \
    --milestone "$MILESTONE_NUM" \
    --state open \
    --limit 100 \
    --json number,title,labels \
    2>&1)

  if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Error: Could not fetch issues for milestone ${MILESTONE_NUM}"
    echo ""
    echo "$ISSUES_DATA"
    exit 1
  fi

  # Parse each issue
  ISSUE_COUNT=$(echo "$ISSUES_DATA" | jq '. | length')

  if [ "$ISSUE_COUNT" -eq 0 ]; then
    echo ""
    echo "ℹ️  No open issues found in milestone: ${MILESTONE_TITLE}"
    echo ""
    echo "All issues may be closed or the milestone is empty."
    exit 0
  fi

  echo "✓ Found ${ISSUE_COUNT} open issues in ${MILESTONE_TITLE}"
  echo ""

  # Process each issue
  while IFS= read -r issue; do
    ISSUE_NUM=$(echo "$issue" | jq -r '.number')
    ISSUE_TITLE=$(echo "$issue" | jq -r '.title')

    # Determine type from labels
    ISSUE_TYPE="feat"
    if echo "$issue" | jq -e '.labels[] | select(.name | test("bug|fix"; "i"))' > /dev/null; then
      ISSUE_TYPE="fix"
    elif echo "$issue" | jq -e '.labels[] | select(.name | test("refactor"; "i"))' > /dev/null; then
      ISSUE_TYPE="refactor"
    elif echo "$issue" | jq -e '.labels[] | select(.name | test("docs|documentation"; "i"))' > /dev/null; then
      ISSUE_TYPE="docs"
    elif echo "$issue" | jq -e '.labels[] | select(.name | test("chore"; "i"))' > /dev/null; then
      ISSUE_TYPE="chore"
    fi

    ISSUES+=("$(jq -n \
      --arg num "$ISSUE_NUM" \
      --arg title "$ISSUE_TITLE" \
      --arg type "$ISSUE_TYPE" \
      '{number: $num, title: $title, type: $type}')")

    echo "  • #${ISSUE_NUM}: ${ISSUE_TITLE} (${ISSUE_TYPE})"
  done < <(echo "$ISSUES_DATA" | jq -c '.[]')
fi
```

**Jira Single Issue:**
```bash
if [ "$GROUPING_TYPE" = "single-jira" ]; then
  echo "Fetching Jira issue ${ISSUE_KEY}..."

  # Fetch issue details
  ISSUE_DATA=$(acli jira --action getIssue \
    --issue "$ISSUE_KEY" \
    --outputFormat 2 \
    2>&1)

  if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Error: Could not fetch Jira issue ${ISSUE_KEY}"
    echo ""
    echo "$ISSUE_DATA"
    echo ""
    echo "Possible causes:"
    echo "  • Issue does not exist"
    echo "  • No permission to view issue"
    echo "  • acli not configured (check acli configuration)"
    exit 1
  fi

  # Parse issue data (acli output format)
  ISSUE_TITLE=$(echo "$ISSUE_DATA" | grep "Summary:" | cut -d: -f2- | xargs)
  ISSUE_TYPE_RAW=$(echo "$ISSUE_DATA" | grep "Issue Type:" | cut -d: -f2 | xargs)

  # Map Jira issue type to git prefix
  case "$ISSUE_TYPE_RAW" in
    Bug) ISSUE_TYPE="fix" ;;
    Story|Task|Epic) ISSUE_TYPE="feat" ;;
    "Technical task"|Subtask) ISSUE_TYPE="chore" ;;
    *) ISSUE_TYPE="feat" ;;
  esac

  # Add to issues array
  ISSUES+=("$(jq -n \
    --arg key "$ISSUE_KEY" \
    --arg title "$ISSUE_TITLE" \
    --arg type "$ISSUE_TYPE" \
    '{key: $key, title: $title, type: $type}')")

  GROUPING_DISPLAY="Issue ${ISSUE_KEY}"

  echo "✓ Fetched: ${ISSUE_KEY} - ${ISSUE_TITLE} (${ISSUE_TYPE})"
fi
```

**Jira Sprint:**
```bash
if [ "$GROUPING_TYPE" = "sprint-jira" ]; then
  echo "Fetching Jira sprint ${SPRINT_ID}..."

  # Fetch issues in sprint
  ISSUES_DATA=$(acli jira --action getIssueList \
    --jql "sprint = ${SPRINT_ID} AND status != Done AND status != Closed" \
    --outputFormat 2 \
    --columns "key,summary,issuetype" \
    2>&1)

  if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Error: Could not fetch Jira sprint ${SPRINT_ID}"
    echo ""
    echo "$ISSUES_DATA"
    exit 1
  fi

  # Count issues (skip header line)
  ISSUE_COUNT=$(echo "$ISSUES_DATA" | grep -v "^Key" | wc -l | xargs)

  if [ "$ISSUE_COUNT" -eq 0 ]; then
    echo ""
    echo "ℹ️  No open issues found in sprint ${SPRINT_ID}"
    echo ""
    echo "All issues may be completed or the sprint is empty."
    exit 0
  fi

  GROUPING_DISPLAY="Sprint ${SPRINT_ID}"
  echo "✓ Found ${ISSUE_COUNT} open issues in Sprint ${SPRINT_ID}"
  echo ""

  # Process each issue (skip header)
  while IFS= read -r line; do
    # Parse acli output format (tab or pipe separated)
    ISSUE_KEY=$(echo "$line" | awk '{print $1}')
    ISSUE_TYPE_RAW=$(echo "$line" | rev | cut -d'|' -f1 | rev | xargs)
    ISSUE_TITLE=$(echo "$line" | cut -d'|' -f2 | xargs)

    # Map type
    case "$ISSUE_TYPE_RAW" in
      Bug) ISSUE_TYPE="fix" ;;
      Story|Task|Epic) ISSUE_TYPE="feat" ;;
      *) ISSUE_TYPE="feat" ;;
    esac

    ISSUES+=("$(jq -n \
      --arg key "$ISSUE_KEY" \
      --arg title "$ISSUE_TITLE" \
      --arg type "$ISSUE_TYPE" \
      '{key: $key, title: $title, type: $type}')")

    echo "  • ${ISSUE_KEY}: ${ISSUE_TITLE} (${ISSUE_TYPE})"
  done < <(echo "$ISSUES_DATA" | grep -v "^Key")
fi
```

**Jira Epic:**
```bash
if [ "$GROUPING_TYPE" = "epic-jira" ]; then
  echo "Fetching Jira epic ${EPIC_KEY}..."

  # Fetch issues in epic
  ISSUES_DATA=$(acli jira --action getIssueList \
    --jql "'Epic Link' = ${EPIC_KEY} AND status != Done AND status != Closed" \
    --outputFormat 2 \
    --columns "key,summary,issuetype" \
    2>&1)

  if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Error: Could not fetch Jira epic ${EPIC_KEY}"
    echo ""
    echo "$ISSUES_DATA"
    exit 1
  fi

  # Count issues
  ISSUE_COUNT=$(echo "$ISSUES_DATA" | grep -v "^Key" | wc -l | xargs)

  if [ "$ISSUE_COUNT" -eq 0 ]; then
    echo ""
    echo "ℹ️  No open issues found in epic ${EPIC_KEY}"
    exit 0
  fi

  GROUPING_DISPLAY="Epic ${EPIC_KEY}"
  echo "✓ Found ${ISSUE_COUNT} open issues in Epic ${EPIC_KEY}"
  echo ""

  # Process issues (same as sprint)
  while IFS= read -r line; do
    ISSUE_KEY=$(echo "$line" | awk '{print $1}')
    ISSUE_TYPE_RAW=$(echo "$line" | rev | cut -d'|' -f1 | rev | xargs)
    ISSUE_TITLE=$(echo "$line" | cut -d'|' -f2 | xargs)

    case "$ISSUE_TYPE_RAW" in
      Bug) ISSUE_TYPE="fix" ;;
      Story|Task|Epic) ISSUE_TYPE="feat" ;;
      *) ISSUE_TYPE="feat" ;;
    esac

    ISSUES+=("$(jq -n \
      --arg key "$ISSUE_KEY" \
      --arg title "$ISSUE_TITLE" \
      --arg type "$ISSUE_TYPE" \
      '{key: $key, title: $title, type: $type}')")

    echo "  • ${ISSUE_KEY}: ${ISSUE_TITLE} (${ISSUE_TYPE})"
  done < <(echo "$ISSUES_DATA" | grep -v "^Key")
fi
```

### Step 2.3: Display Summary

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Issues for Worktree Creation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Grouping: ${GROUPING_DISPLAY}"
echo "Total Issues: ${#ISSUES[@]}"
echo ""
echo "Creating ${#ISSUES[@]} worktree(s)..."
echo ""
```

---

## Phase 3: Repository Validation

Ensure we're in a valid git repository and prepare for worktree creation.

### Step 3.1: Verify Git Repository

```bash
echo "Validating repository..."
echo ""

# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: Not in a git repository"
  echo ""
  echo "Current directory: $(pwd)"
  echo ""
  echo "The worktree command must be run from within a git repository."
  echo ""
  echo "Please navigate to your repository and try again:"
  echo "  cd /path/to/your/repo"
  echo "  /agency:worktree $ARGUMENTS"
  exit 1
fi

REPO_DIR=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_DIR")

echo "✓ Repository: $REPO_NAME"
echo "  Path: $REPO_DIR"
```

### Step 3.2: Detect Default Branch

```bash
# Get default branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

if [ -z "$DEFAULT_BRANCH" ]; then
  # Fallback: check for common branch names
  if git show-ref --verify --quiet refs/heads/main; then
    DEFAULT_BRANCH="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    DEFAULT_BRANCH="master"
  elif git show-ref --verify --quiet refs/heads/develop; then
    DEFAULT_BRANCH="develop"
  else
    echo "⚠️  Could not determine default branch"

    Use AskUserQuestion tool:
      question: "Please specify the default branch to create worktrees from:"
      header: "Default branch"
      multiSelect: false
      options:
        - label: "main"
          description: "Use main as default branch"
        - label: "master"
          description: "Use master as default branch"
        - label: "develop"
          description: "Use develop as default branch"

    # Process response
    if [response contains "main"]; then
      DEFAULT_BRANCH="main"
    elif [response contains "master"]; then
      DEFAULT_BRANCH="master"
    else
      DEFAULT_BRANCH="develop"
    fi
  fi
fi

echo "✓ Default branch: $DEFAULT_BRANCH"
```

### Step 3.3: Checkout and Update Default Branch

```bash
CURRENT_BRANCH=$(git branch --show-current)

if [[ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]]; then
  echo "  Current branch: $CURRENT_BRANCH"
  echo "  Switching to: $DEFAULT_BRANCH"

  # Check for uncommitted changes
  if [ -n "$(git status --porcelain)" ]; then
    echo ""
    echo "⚠️  Uncommitted changes detected on $CURRENT_BRANCH"
    echo ""
    git status --short
    echo ""

    Use AskUserQuestion tool:
      question: "You have uncommitted changes on $CURRENT_BRANCH. What would you like to do?"
      header: "Uncommitted work"
      multiSelect: false
      options:
        - label: "Stash changes and continue"
          description: "Save changes to stash and switch to $DEFAULT_BRANCH"
        - label: "Cancel worktree creation"
          description: "Exit without making changes"

    if [response contains "Cancel"]; then
      echo "Worktree creation cancelled by user."
      exit 0
    else
      echo "Stashing changes..."
      git stash push -m "Auto-stash before worktree creation at $(date)"
      echo "✓ Changes stashed"
    fi
  fi

  # Switch to default branch
  git checkout "$DEFAULT_BRANCH" 2>&1

  if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Error: Could not checkout $DEFAULT_BRANCH"
    exit 1
  fi
fi

echo "✓ On default branch: $DEFAULT_BRANCH"

# Pull latest changes
echo ""
echo "Pulling latest changes from origin/${DEFAULT_BRANCH}..."
git pull origin "$DEFAULT_BRANCH" 2>&1

if [ $? -ne 0 ]; then
  echo "⚠️  Warning: Could not pull latest changes"
  echo "Continuing with current local state..."
fi

echo "✓ Repository ready for worktree creation"
```

### Step 3.4: Validate Parent Directory

```bash
# Parent directory (where worktrees will be created as siblings)
PARENT_DIR=$(dirname "$REPO_DIR")

echo ""
echo "Worktree location:"
echo "  Parent directory: $PARENT_DIR"
echo "  Current repo: ${REPO_DIR}"
echo "  Worktrees will be created as siblings to the current repo"
echo ""

# Validate parent directory is writable
if [ ! -w "$PARENT_DIR" ]; then
  echo "❌ Error: Cannot create worktrees - parent directory is not writable"
  echo ""
  echo "Parent directory: $PARENT_DIR"
  echo "Repository: $REPO_DIR"
  echo ""
  echo "Worktrees will be created as siblings to your repository:"
  echo "  ${PARENT_DIR}/"
  echo "  ├── ${REPO_NAME}/              (current repo)"
  echo "  ├── feat-issue-123-...         (worktree 1)"
  echo "  └── feat-issue-124-...         (worktree 2)"
  echo ""
  echo "Please ensure you have write permissions to: $PARENT_DIR"
  exit 1
fi

echo "✓ Parent directory is writable"
```

---

## Phase 4: Worktree Creation Loop

Create a worktree for each issue.

### Step 4.1: Initialize State Tracking

```bash
# Create state directory
STATE_DIR="${REPO_DIR}/.agency/worktrees"
mkdir -p "$STATE_DIR"

STATE_FILE="${STATE_DIR}/${GROUPING_ID}-worktrees.json"

# Initialize state file
cat > "$STATE_FILE" <<EOF
{
  "grouping_type": "${GROUPING_TYPE}",
  "grouping_id": "${GROUPING_ID}",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "worktrees": []
}
EOF

echo ""
echo "State tracking initialized: ${STATE_FILE#$REPO_DIR/}"
echo ""
```

### Step 4.2: Create Worktrees

```bash
# Track results
declare -a CREATED_WORKTREES
declare -a FAILED_WORKTREES

# Process each issue
for issue in "${ISSUES[@]}"; do
  # Extract issue details
  if [[ "$PROVIDER" == "github" ]]; then
    ISSUE_NUM=$(echo "$issue" | jq -r '.number')
    ISSUE_TITLE=$(echo "$issue" | jq -r '.title')
    ISSUE_TYPE=$(echo "$issue" | jq -r '.type')
    ISSUE_ID="#${ISSUE_NUM}"
    ISSUE_KEY_VAL="null"
  else
    ISSUE_KEY_VAL=$(echo "$issue" | jq -r '.key')
    ISSUE_TITLE=$(echo "$issue" | jq -r '.title')
    ISSUE_TYPE=$(echo "$issue" | jq -r '.type')
    ISSUE_ID="${ISSUE_KEY_VAL}"
    ISSUE_NUM="null"
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Creating worktree for: ${ISSUE_ID} - ${ISSUE_TITLE}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Sanitize title for branch name
  # 1. Convert to lowercase
  # 2. Replace non-alphanumeric with hyphens
  # 3. Remove consecutive hyphens
  # 4. Trim leading/trailing hyphens
  # 5. Limit to 50 characters
  TITLE_SLUG=$(echo "$ISSUE_TITLE" | \
    tr '[:upper:]' '[:lower:]' | \
    sed 's/[^a-z0-9]/-/g' | \
    sed 's/-\+/-/g' | \
    sed 's/^-//;s/-$//' | \
    cut -c1-50)

  # Generate branch name
  if [[ "$PROVIDER" == "github" ]]; then
    BRANCH_NAME="${ISSUE_TYPE}/issue-${ISSUE_NUM}-${TITLE_SLUG}"
  else
    BRANCH_NAME="${ISSUE_TYPE}/${ISSUE_KEY_VAL}-${TITLE_SLUG}"
  fi

  echo "Branch: $BRANCH_NAME"

  # Generate worktree directory name
  # Format: <type>-issue-<number>-<description>
  if [[ "$PROVIDER" == "github" ]]; then
    WORKTREE_DIR_NAME="${ISSUE_TYPE}-issue-${ISSUE_NUM}-${TITLE_SLUG}"
  else
    WORKTREE_DIR_NAME="${ISSUE_TYPE}-${ISSUE_KEY_VAL}-${TITLE_SLUG}"
  fi

  WORKTREE_PATH="${PARENT_DIR}/${WORKTREE_DIR_NAME}"

  echo "Path: $WORKTREE_PATH"
  echo ""

  # Check if branch already exists
  if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
    echo "⚠️  Branch already exists: $BRANCH_NAME"
    echo ""

    Use AskUserQuestion tool:
      question: "Branch $BRANCH_NAME already exists for issue $ISSUE_ID.

This could mean:
  • You already created a worktree for this issue
  • Someone else is working on this issue
  • The branch wasn't cleaned up after a previous PR

What would you like to do?"

      header: "Branch exists"
      multiSelect: false
      options:
        - label: "Use existing branch and create worktree"
          description: "Create worktree with existing branch (if it's your work)"
        - label: "Skip this issue (Recommended)"
          description: "Skip creating worktree for this issue"
        - label: "Delete branch and create new one"
          description: "Delete existing branch and start fresh (dangerous!)"

    if [response contains "Skip"]; then
      echo "⏭️  Skipped issue ${ISSUE_ID}"
      FAILED_WORKTREES+=("${ISSUE_ID}: Branch already exists (skipped)")
      echo ""
      continue
    elif [response contains "Delete"]; then
      echo "Deleting existing branch..."
      git branch -D "$BRANCH_NAME" 2>&1
    fi
    # If "Use existing", continue to worktree creation without creating branch
  fi

  # Check if worktree path already exists
  if [ -d "$WORKTREE_PATH" ]; then
    echo "⚠️  Directory already exists: $WORKTREE_PATH"

    # Check if it's a worktree
    if git worktree list | grep -q "$WORKTREE_PATH"; then
      echo "This is an existing git worktree."
    else
      echo "This directory exists but is not a git worktree."
    fi

    echo "⏭️  Skipped issue ${ISSUE_ID}"
    FAILED_WORKTREES+=("${ISSUE_ID}: Directory already exists")
    echo ""
    continue
  fi

  # Create worktree
  echo "Creating worktree..."

  # If branch already exists, create worktree without -b flag
  if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME" 2>&1
  else
    git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "$DEFAULT_BRANCH" 2>&1
  fi

  if [ $? -eq 0 ]; then
    echo "✅ Worktree created successfully"

    # Create worktree metadata entry
    WORKTREE_ENTRY=$(jq -n \
      --arg num "$ISSUE_NUM" \
      --arg key "$ISSUE_KEY_VAL" \
      --arg title "$ISSUE_TITLE" \
      --arg branch "$BRANCH_NAME" \
      --arg path "$WORKTREE_PATH" \
      --arg created "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '{
        issue_number: (if $num == "null" then null else $num end),
        issue_key: (if $key == "null" then null else $key end),
        issue_title: $title,
        branch_name: $branch,
        worktree_path: $path,
        created_at: $created,
        status: "active"
      }')

    # Append to state file
    TEMP_STATE=$(jq ".worktrees += [$WORKTREE_ENTRY]" "$STATE_FILE")
    echo "$TEMP_STATE" > "$STATE_FILE"

    CREATED_WORKTREES+=("${ISSUE_ID}")
  else
    echo "❌ Failed to create worktree"
    FAILED_WORKTREES+=("${ISSUE_ID}: Worktree creation failed")
  fi

  echo ""
done
```

---

## Phase 5: User Instructions & Reporting

Provide clear next steps and save report.

### Step 5.1: Generate Summary Report

```bash
CREATED_COUNT=${#CREATED_WORKTREES[@]}
FAILED_COUNT=${#FAILED_WORKTREES[@]}
TOTAL_COUNT=${#ISSUES[@]}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Worktree Creation Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Grouping: ${GROUPING_DISPLAY}"
echo "Total Issues: ${TOTAL_COUNT}"
echo "Worktrees Created: ${CREATED_COUNT} ✅"

if [ ${FAILED_COUNT} -gt 0 ]; then
  echo "Failed: ${FAILED_COUNT} ❌"
fi

echo ""
```

### Step 5.2: List Created Worktrees

```bash
if [ ${CREATED_COUNT} -gt 0 ]; then
  echo "Created Worktrees:"
  echo ""

  # Read from state file and display
  COUNTER=1
  while IFS= read -r worktree; do
    ISSUE_NUM_VAL=$(echo "$worktree" | jq -r '.issue_number')
    ISSUE_KEY_VAL=$(echo "$worktree" | jq -r '.issue_key')
    ISSUE_TITLE=$(echo "$worktree" | jq -r '.issue_title')
    BRANCH_NAME=$(echo "$worktree" | jq -r '.branch_name')
    WORKTREE_PATH=$(echo "$worktree" | jq -r '.worktree_path')

    if [ "$ISSUE_NUM_VAL" != "null" ]; then
      ISSUE_DISPLAY="#${ISSUE_NUM_VAL}"
    else
      ISSUE_DISPLAY="${ISSUE_KEY_VAL}"
    fi

    echo "${COUNTER}. Issue ${ISSUE_DISPLAY}: ${ISSUE_TITLE}"
    echo "   Branch: ${BRANCH_NAME}"
    echo "   Path: ${WORKTREE_PATH}"
    echo "   Status: ✅ Ready"
    echo ""

    COUNTER=$((COUNTER + 1))
  done < <(jq -c '.worktrees[]' "$STATE_FILE")
fi
```

### Step 5.3: List Failed Worktrees

```bash
if [ ${FAILED_COUNT} -gt 0 ]; then
  echo "Failed Worktrees:"
  echo ""

  for failure in "${FAILED_WORKTREES[@]}"; do
    echo "  • $failure"
  done

  echo ""
fi
```

### Step 5.4: Provide Next Steps Instructions

```bash
cat <<'INSTRUCTIONS'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Next Steps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Working with Worktrees

Each worktree is an independent working directory where you can work on an
issue in isolation. The worktree is already on the correct branch!

### Navigate to a worktree:

INSTRUCTIONS

# Show first worktree as example
FIRST_WORKTREE=$(jq -r '.worktrees[0].worktree_path' "$STATE_FILE")
FIRST_ISSUE=$(jq -r 'if .worktrees[0].issue_number then "#" + .worktrees[0].issue_number else .worktrees[0].issue_key end' "$STATE_FILE")

if [ "$FIRST_WORKTREE" != "null" ]; then
  echo "  cd $FIRST_WORKTREE"
fi

cat <<'INSTRUCTIONS'

### Work on the issue:

You can use any of these Agency commands in the worktree:

  /agency:work <issue>              # Full end-to-end workflow
  /agency:plan <issue>              # Just create implementation plan
  /agency:implement plan.md --branch # Implement from existing plan

### Example workflow:

INSTRUCTIONS

if [ "$FIRST_WORKTREE" != "null" ]; then
  echo "  cd $FIRST_WORKTREE"
  echo "  /agency:work $FIRST_ISSUE"
fi

cat <<'INSTRUCTIONS'

### Parallel Development:

You can work on multiple issues simultaneously by opening each worktree in
a separate terminal or editor window:

  Terminal 1:           Terminal 2:           Terminal 3:
  ───────────           ───────────           ───────────
  cd worktree-1         cd worktree-2         cd worktree-3
  /agency:work 123      /agency:work 124      /agency:work 125

Each worktree operates independently - no branch switching required!

### View all worktrees:

  git worktree list

### View worktree branches:

  git branch --all

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Cleanup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

When you're done working and PRs are merged, clean up worktrees:

INSTRUCTIONS

echo "  /agency:worktree ${GROUPING_ID} --cleanup"

cat <<'INSTRUCTIONS'

This will:
  • Remove all worktree directories
  • Optionally delete branches (if merged)
  • Archive state tracking

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSTRUCTIONS
```

### Step 5.5: Save Report

```bash
# Generate full report
REPORT_FILE="${STATE_DIR}/${GROUPING_ID}-creation-report.md"

cat > "$REPORT_FILE" <<EOF
# Worktree Creation Report

**Date**: $(date)
**Grouping**: ${GROUPING_DISPLAY}

## Summary

- **Total Issues**: ${TOTAL_COUNT}
- **Worktrees Created**: ${CREATED_COUNT} ✅
- **Failed**: ${FAILED_COUNT} ❌

## Created Worktrees

EOF

# Append worktree list
COUNTER=1
while IFS= read -r worktree; do
  ISSUE_NUM_VAL=$(echo "$worktree" | jq -r '.issue_number')
  ISSUE_KEY_VAL=$(echo "$worktree" | jq -r '.issue_key')
  ISSUE_TITLE=$(echo "$worktree" | jq -r '.issue_title')
  BRANCH_NAME=$(echo "$worktree" | jq -r '.branch_name')
  WORKTREE_PATH=$(echo "$worktree" | jq -r '.worktree_path')

  if [ "$ISSUE_NUM_VAL" != "null" ]; then
    ISSUE_DISPLAY="#${ISSUE_NUM_VAL}"
  else
    ISSUE_DISPLAY="${ISSUE_KEY_VAL}"
  fi

  cat >> "$REPORT_FILE" <<EOF
### ${COUNTER}. Issue ${ISSUE_DISPLAY}: ${ISSUE_TITLE}

- **Branch**: \`${BRANCH_NAME}\`
- **Path**: \`${WORKTREE_PATH}\`
- **Status**: ✅ Ready

EOF

  COUNTER=$((COUNTER + 1))
done < <(jq -c '.worktrees[]' "$STATE_FILE")

# Append failed worktrees
if [ ${FAILED_COUNT} -gt 0 ]; then
  cat >> "$REPORT_FILE" <<EOF
## Failed Worktrees

EOF

  for failure in "${FAILED_WORKTREES[@]}"; do
    echo "- $failure" >> "$REPORT_FILE"
  done

  echo "" >> "$REPORT_FILE"
fi

# Append instructions
cat >> "$REPORT_FILE" <<'EOF'
## Next Steps

See terminal output for detailed instructions on:
- Navigating to worktrees
- Working on issues
- Parallel development workflow
- Cleanup when complete

## State Tracking

Worktree metadata is tracked in:
EOF

echo "\`${STATE_FILE#$REPO_DIR/}\`" >> "$REPORT_FILE"

echo ""
echo "Full report saved to: ${REPORT_FILE#$REPO_DIR/}"
```

---

## Phase 6: Completion

Final summary and cleanup.

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ ${CREATED_COUNT} -eq ${TOTAL_COUNT} ]; then
  echo "✅ All worktrees created successfully!"
elif [ ${CREATED_COUNT} -gt 0 ]; then
  echo "⚠️  ${CREATED_COUNT} of ${TOTAL_COUNT} worktrees created"
  echo ""
  echo "Some worktrees could not be created. See details above."
else
  echo "❌ No worktrees were created"
  echo ""
  echo "Please resolve the issues above and try again."
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
```

---

## Tips & Best Practices

### Working with Worktrees

1. **One worktree per issue**: Each worktree should focus on a single issue
2. **Independent work**: Changes in one worktree don't affect others
3. **No branch switching**: Each worktree is always on its designated branch
4. **Parallel editors**: Open each worktree in a separate IDE/editor window

### Cleanup

- **After merging PRs**: Clean up worktrees to free disk space
- **Before cleanup**: Ensure all work is committed and pushed
- **Branch management**: Decide whether to keep or delete branches based on PR status

### State Management

- **State files**: Track worktree metadata in `.agency/worktrees/`
- **Archive**: Cleanup archives state files for historical reference
- **Manual removal**: If you manually delete a worktree directory, use `git worktree prune`

### Troubleshooting

**Worktree locked error**:
```bash
git worktree prune
```

**View all worktrees**:
```bash
git worktree list
```

**Remove specific worktree**:
```bash
git worktree remove /path/to/worktree
```

---

## Related Commands

- `/agency:work [issue]` - Work on single issue end-to-end
- `/agency:plan [issue]` - Create implementation plan
- `/agency:implement plan.md` - Implement from plan
- `/agency:sprint [sprint-id]` - Implement entire sprint with dependency resolution
