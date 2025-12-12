# Issue Management: Dependency Parsing

Parse dependency references from issue descriptions to identify blockers and prerequisites.

## When to Use

**After extracting issue metadata** with:
- `issue-metadata-extraction.md` - Parsed description available

**Purpose**: Identify dependencies, blockers, and related work before planning implementation.

---

## Common Dependency Patterns

### GitHub Issue References

**Pattern 1: Direct issue number**
```markdown
Depends on #123
Blocked by #456
Requires #789
```

**Pattern 2: Full URL**
```markdown
Depends on https://github.com/owner/repo/issues/123
Blocked by https://github.com/owner/repo/pull/456
```

**Pattern 3: Inline mentions**
```markdown
This builds on the work from #123 and #124.
Cannot proceed until #456 is merged.
```

**Pattern 4: Checklist dependencies**
```markdown
## Prerequisites
- [ ] #123 - User authentication must be complete
- [ ] #124 - Database schema migration
```

### Jira Issue References

**Pattern 1: Direct issue key**
```markdown
Depends on PROJ-123
Blocked by PROJ-456
Requires PROJ-789
```

**Pattern 2: Full URL**
```markdown
Depends on https://company.atlassian.net/browse/PROJ-123
```

**Pattern 3: Jira link syntax**
```markdown
This is blocked by [PROJ-123]
Requires [PROJ-456] and [PROJ-789]
```

### Keyword Patterns

**Dependency keywords**:
- `depends on`
- `depends upon`
- `blocked by`
- `blocks`
- `requires`
- `needs`
- `prerequisite`
- `must complete`
- `after`
- `builds on`
- `related to` (softer dependency)

---

## Parsing Logic

### Extract GitHub Dependencies

```bash
# Search for dependency patterns in description
extract_github_dependencies() {
  local description="$1"

  # Pattern 1: "depends on #123" or "blocked by #456"
  echo "$description" | grep -oiP '(depends on|blocked by|requires|needs|prerequisite)\s*#\d+' | \
    grep -oP '#\d+' | sed 's/#//'

  # Pattern 2: Full GitHub URLs
  echo "$description" | grep -oP 'https://github\.com/[\w-]+/[\w-]+/issues/\d+' | \
    grep -oP '\d+$'

  # Pattern 3: Checklist items with issue numbers
  echo "$description" | grep -E '^\s*-\s*\[[ x]\].*#\d+' | \
    grep -oP '#\d+' | sed 's/#//'
}

# Get unique dependencies
DEPENDENCIES=$(extract_github_dependencies "$DESCRIPTION" | sort -u)
```

### Extract Jira Dependencies

```bash
# Search for Jira dependency patterns
extract_jira_dependencies() {
  local description="$1"

  # Pattern 1: "depends on PROJ-123" or "blocked by PROJ-456"
  echo "$description" | grep -oiP '(depends on|blocked by|requires|needs|prerequisite)\s*[A-Z]+-\d+' | \
    grep -oP '[A-Z]+-\d+'

  # Pattern 2: Full Jira URLs
  echo "$description" | grep -oP 'https://[^/]+\.atlassian\.net/browse/[A-Z]+-\d+' | \
    grep -oP '[A-Z]+-\d+'

  # Pattern 3: Jira link syntax [PROJ-123]
  echo "$description" | grep -oP '\[[A-Z]+-\d+\]' | sed 's/\[//;s/\]//'
}

# Get unique dependencies
DEPENDENCIES=$(extract_jira_dependencies "$DESCRIPTION" | sort -u)
```

---

## Check Dependency Status

### For GitHub Dependencies

```bash
check_github_dependency_status() {
  local issue_number="$1"

  # Fetch issue status
  local status=$(gh issue view "$issue_number" --json state,closedAt --jq '{state: .state, closedAt: .closedAt}')

  local state=$(echo "$status" | jq -r '.state')
  local closed=$(echo "$status" | jq -r '.closedAt')

  if [ "$state" = "CLOSED" ]; then
    echo "✅ #$issue_number: COMPLETE"
  else
    echo "⚠️ #$issue_number: OPEN (blocking)"
  fi
}

# Check all dependencies
if [ -n "$DEPENDENCIES" ]; then
  echo "Checking dependencies..."
  while read -r dep; do
    check_github_dependency_status "$dep"
  done <<< "$DEPENDENCIES"
fi
```

### For Jira Dependencies

```bash
check_jira_dependency_status() {
  local issue_key="$1"

  # Fetch issue status
  local status=$(acli jira --action getIssue \
    --issue "$issue_key" \
    --outputFormat 2 \
    --columns "status" | tail -n +2 | cut -d',' -f1)

  if [ "$status" = "Done" ] || [ "$status" = "Closed" ]; then
    echo "✅ $issue_key: COMPLETE"
  else
    echo "⚠️ $issue_key: $status (blocking)"
  fi
}

# Check all dependencies
if [ -n "$DEPENDENCIES" ]; then
  echo "Checking dependencies..."
  while read -r dep; do
    check_jira_dependency_status "$dep"
  done <<< "$DEPENDENCIES"
fi
```

---

## Dependency Analysis

### Categorize Dependencies

```bash
analyze_dependencies() {
  local dependencies="$1"

  BLOCKING_COUNT=0
  COMPLETED_COUNT=0

  while read -r dep; do
    if [ -z "$dep" ]; then continue; fi

    # Check status (GitHub example)
    status=$(gh issue view "$dep" --json state --jq '.state' 2>/dev/null)

    if [ "$status" = "CLOSED" ]; then
      COMPLETED_COUNT=$((COMPLETED_COUNT + 1))
    else
      BLOCKING_COUNT=$((BLOCKING_COUNT + 1))
    fi
  done <<< "$dependencies"

  echo "Total dependencies: $(echo "$dependencies" | wc -l)"
  echo "Completed: $COMPLETED_COUNT"
  echo "Blocking: $BLOCKING_COUNT"
}
```

### Determine Work Readiness

```bash
# After analyzing dependencies, determine if work can proceed
if [ "$BLOCKING_COUNT" -gt 0 ]; then
  echo "⚠️ Warning: $BLOCKING_COUNT blocking dependencies"

  # Use AskUserQuestion tool:
  # "This issue has $BLOCKING_COUNT open dependencies:
  # [list blocking issues]
  #
  # Would you like to:
  # - Wait and work on dependencies first
  # - Proceed anyway (may require rework)
  # - Choose a different issue"
fi
```

---

## Extract Related Work

Beyond hard dependencies, identify related issues:

```bash
extract_related_issues() {
  local description="$1"

  # Look for "related to" mentions
  echo "$description" | grep -oiP '(related to|see also|similar to)\s*#\d+' | \
    grep -oP '#\d+' | sed 's/#//'

  # Or for Jira
  echo "$description" | grep -oiP '(related to|see also|similar to)\s*[A-Z]+-\d+' | \
    grep -oP '[A-Z]+-\d+'
}

RELATED_ISSUES=$(extract_related_issues "$DESCRIPTION" | sort -u)

if [ -n "$RELATED_ISSUES" ]; then
  echo "Related work found:"
  while read -r issue; do
    echo "  - #$issue (may provide context)"
  done <<< "$RELATED_ISSUES"
fi
```

---

## Parse Version Dependencies

Some issues depend on specific versions or releases:

```bash
extract_version_dependencies() {
  local description="$1"

  # Look for version mentions
  echo "$description" | grep -oiP '(requires|needs|depends on)\s+v?\d+\.\d+(\.\d+)?'

  # Look for milestone dependencies
  echo "$description" | grep -oiP '(after|needs)\s+milestone:?\s*[\w.-]+'
}
```

---

## Build Dependency Graph

For complex dependencies, build a structured graph:

```bash
# Create dependency metadata
cat > /tmp/dependency-graph.json <<EOF
{
  "current_issue": "$ISSUE_ID",
  "dependencies": {
    "blocking": [
      $(echo "$DEPENDENCIES" | while read -r dep; do
        status=$(gh issue view "$dep" --json state,title --jq '{number: .number, title: .title, state: .state}' 2>/dev/null)
        if [ -n "$status" ]; then
          echo "$status,"
        fi
      done | sed '$ s/,$//')
    ],
    "related": [
      $(echo "$RELATED_ISSUES" | while read -r dep; do
        echo "\"#$dep\","
      done | sed '$ s/,$//')
    ]
  },
  "blocked_count": $BLOCKING_COUNT,
  "ready_to_start": $([ "$BLOCKING_COUNT" -eq 0 ] && echo "true" || echo "false")
}
EOF
```

---

## Validation

After dependency parsing:

- [ ] All dependency references are valid issue numbers/keys
- [ ] Dependency status has been checked
- [ ] Blocking dependencies are identified
- [ ] User is warned if blockers exist
- [ ] Related work is noted for context

---

## Integration with Planning

Include dependency information in plan:

```bash
# Add to plan file
cat >> "$PLAN_FILE" <<EOF

## Dependencies

### Blocking Dependencies

$(if [ "$BLOCKING_COUNT" -gt 0 ]; then
  echo "$DEPENDENCIES" | while read -r dep; do
    echo "- [ ] #$dep - [Brief description]"
  done
else
  echo "None - ready to start"
fi)

### Related Work

$(if [ -n "$RELATED_ISSUES" ]; then
  echo "$RELATED_ISSUES" | while read -r issue; do
    echo "- #$issue - (contextual reference)"
  done
else
  echo "None identified"
fi)

EOF
```

---

## Notes

- Dependency parsing is best-effort - issue descriptions vary widely
- Consider both explicit keywords and implicit references
- Check linked issues in GitHub/Jira API for complete dependency graph
- Some teams use formal linking (GitHub: "closes", Jira: issue links)
- Soft dependencies ("related to") vs hard dependencies ("blocked by")
- False positives possible - verify before treating as blockers
- Consider transitive dependencies (A depends on B, B depends on C)
