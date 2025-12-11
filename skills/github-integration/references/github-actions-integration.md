# GitHub Actions Integration

Comprehensive guide to integrating GitHub Actions into your development workflows, including common patterns, workflow templates, and automation strategies.

## Overview

GitHub Actions is a CI/CD platform that automates workflows directly from your GitHub repository. It allows you to build, test, and deploy code, as well as automate issue management, PR operations, and custom workflows.

---

## Workflow Basics

### Workflow File Structure

Workflows are defined in `.github/workflows/*.yml` files.

```yaml
name: Workflow Name

on:
  # Trigger events

jobs:
  job-name:
    runs-on: ubuntu-latest
    steps:
      - name: Step name
        # Step actions
```

### Common Triggers

```yaml
# Push to specific branches
on:
  push:
    branches: [main, develop]

# Pull request events
on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main]

# Multiple triggers
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:  # Manual trigger

# Scheduled (cron)
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight

# Issue events
on:
  issues:
    types: [opened, labeled, assigned]

# Release events
on:
  release:
    types: [published]
```

### Environment Variables and Secrets

```yaml
env:
  NODE_VERSION: '18'
  GLOBAL_VAR: 'value'

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      JOB_VAR: 'job-level'
    steps:
      - name: Use variables
        env:
          STEP_VAR: 'step-level'
          SECRET_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          echo "Global: $GLOBAL_VAR"
          echo "Job: $JOB_VAR"
          echo "Step: $STEP_VAR"
          # Use secret (never echo secrets!)
```

---

## CI/CD Workflows

### Node.js CI

```yaml
name: Node.js CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [16, 18, 20]

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
```

### TypeScript Build and Test

```yaml
name: TypeScript CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - run: npm ci

      - name: Type check
        run: npm run type-check

      - name: Run tests
        run: npm test -- --coverage

      - name: Build
        run: npm run build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build
          path: dist/
```

### Docker Build and Push

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  docker:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: my-org/my-app
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## Issue and PR Automation

### Auto-label PRs

```yaml
name: Auto-label PRs

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  label:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write

    steps:
      - uses: actions/checkout@v4

      - name: Label based on files changed
        uses: actions/labeler@v5
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}

      - name: Custom labeling logic
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          PR_NUMBER=${{ github.event.pull_request.number }}

          # Get changed files
          gh pr view $PR_NUMBER --json files --jq '.files[].path' > changed-files.txt

          # Label based on patterns
          if grep -q "\.ts$" changed-files.txt; then
            gh pr edit $PR_NUMBER --add-label "typescript"
          fi

          if grep -q "\.test\.ts$" changed-files.txt; then
            gh pr edit $PR_NUMBER --add-label "tests"
          fi

          if grep -q "^docs/" changed-files.txt; then
            gh pr edit $PR_NUMBER --add-label "documentation"
          fi
```

### Auto-assign Reviewers

```yaml
name: Auto-assign Reviewers

on:
  pull_request:
    types: [opened, ready_for_review]

jobs:
  assign:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write

    steps:
      - name: Assign team members
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          PR_NUMBER=${{ github.event.pull_request.number }}
          AUTHOR=${{ github.event.pull_request.user.login }}

          # Assign based on author
          if [ "$AUTHOR" == "junior-dev" ]; then
            gh pr edit $PR_NUMBER --add-reviewer senior-dev,team-lead
          else
            gh pr edit $PR_NUMBER --add-reviewer team-lead
          fi
```

### Link PRs to Issues

```yaml
name: Link PR to Issue

on:
  pull_request:
    types: [opened]

jobs:
  link:
    runs-on: ubuntu-latest
    permissions:
      issues: write
      pull-requests: read

    steps:
      - name: Extract issue number
        id: extract
        run: |
          TITLE="${{ github.event.pull_request.title }}"
          BODY="${{ github.event.pull_request.body }}"

          # Extract #123 from title
          ISSUE_NUM=$(echo "$TITLE" | grep -oP '#\K\d+' | head -1)

          # If not in title, try body
          if [ -z "$ISSUE_NUM" ]; then
            ISSUE_NUM=$(echo "$BODY" | grep -oP '#\K\d+' | head -1)
          fi

          echo "issue_number=$ISSUE_NUM" >> $GITHUB_OUTPUT

      - name: Comment on linked issue
        if: steps.extract.outputs.issue_number != ''
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh issue comment ${{ steps.extract.outputs.issue_number }} \
            --body "🔗 PR #${{ github.event.pull_request.number }} has been created to address this issue"
```

### Auto-close Stale Issues

```yaml
name: Close Stale Issues

on:
  schedule:
    - cron: '0 0 * * *'  # Daily
  workflow_dispatch:

jobs:
  stale:
    runs-on: ubuntu-latest
    permissions:
      issues: write

    steps:
      - name: Close stale issues
        uses: actions/stale@v9
        with:
          stale-issue-message: 'This issue has been automatically marked as stale because it has not had recent activity. It will be closed if no further activity occurs.'
          close-issue-message: 'Closing this issue due to inactivity.'
          days-before-stale: 30
          days-before-close: 7
          stale-issue-label: 'stale'
          exempt-issue-labels: 'pinned,security'
```

---

## Using gh CLI in Actions

### Issue Management

```yaml
name: Sprint Planning

on:
  workflow_dispatch:
    inputs:
      milestone:
        description: 'Milestone name'
        required: true
      label:
        description: 'Label to filter issues'
        required: true
        default: 'sprint-ready'

jobs:
  plan:
    runs-on: ubuntu-latest
    permissions:
      issues: write

    steps:
      - name: Add issues to milestone
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Get issues with label
          ISSUES=$(gh issue list \
            --label "${{ github.event.inputs.label }}" \
            --json number \
            --jq '.[].number')

          # Add to milestone
          for issue in $ISSUES; do
            gh issue edit $issue --milestone "${{ github.event.inputs.milestone }}"
            echo "Added issue #$issue to milestone"
          done
```

### PR Status Checks

```yaml
name: Check PR Status

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  checks:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: read

    steps:
      - name: Wait for checks
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          PR_NUMBER=${{ github.event.pull_request.number }}

          # Wait for all checks to complete
          while true; do
            STATUS=$(gh pr checks $PR_NUMBER --json state --jq '.[].state' | sort -u)

            if echo "$STATUS" | grep -q "PENDING"; then
              echo "Checks still running..."
              sleep 30
            else
              break
            fi
          done

          # Check if all passed
          if gh pr checks $PR_NUMBER --json conclusion --jq '.[].conclusion' | grep -q "FAILURE"; then
            echo "Some checks failed"
            exit 1
          fi

          echo "All checks passed!"
```

### Bulk Operations

```yaml
name: Bulk Label Update

on:
  workflow_dispatch:
    inputs:
      old_label:
        description: 'Old label name'
        required: true
      new_label:
        description: 'New label name'
        required: true

jobs:
  update:
    runs-on: ubuntu-latest
    permissions:
      issues: write

    steps:
      - name: Update labels
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Get all issues with old label
          ISSUES=$(gh issue list \
            --label "${{ github.event.inputs.old_label }}" \
            --state all \
            --limit 1000 \
            --json number \
            --jq '.[].number')

          # Update each issue
          for issue in $ISSUES; do
            gh issue edit $issue \
              --remove-label "${{ github.event.inputs.old_label }}" \
              --add-label "${{ github.event.inputs.new_label }}"
            echo "Updated issue #$issue"
          done
```

---

## Release Automation

### Auto-create Release

```yaml
name: Create Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4

      - name: Build artifacts
        run: |
          npm ci
          npm run build
          tar -czf dist.tar.gz dist/

      - name: Create release
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          TAG=${GITHUB_REF#refs/tags/}

          gh release create $TAG \
            --title "Release $TAG" \
            --generate-notes \
            dist.tar.gz
```

### Changelog Generation

```yaml
name: Update Changelog

on:
  release:
    types: [published]

jobs:
  changelog:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate changelog
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          TAG=${GITHUB_REF#refs/tags/}
          PREV_TAG=$(git describe --abbrev=0 --tags $TAG^ 2>/dev/null || echo "")

          if [ -z "$PREV_TAG" ]; then
            RANGE="$TAG"
          else
            RANGE="$PREV_TAG..$TAG"
          fi

          # Get PRs merged in this range
          git log $RANGE --merges --pretty=format:"%s" | \
            grep -oP "#\d+" | \
            sort -u | \
            while read pr; do
              PR_NUM=${pr#\#}
              PR_TITLE=$(gh pr view $PR_NUM --json title --jq '.title')
              echo "- $PR_TITLE ($pr)" >> CHANGELOG_NEW.md
            done

          # Prepend to existing changelog
          cat CHANGELOG_NEW.md CHANGELOG.md > CHANGELOG_TMP.md
          mv CHANGELOG_TMP.md CHANGELOG.md

          # Commit
          git config user.name github-actions
          git config user.email github-actions@github.com
          git add CHANGELOG.md
          git commit -m "Update changelog for $TAG"
          git push
```

---

## Deployment Workflows

### Deploy to Production

```yaml
name: Deploy to Production

on:
  release:
    types: [published]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '18'

      - run: npm ci
      - run: npm run build

      - name: Deploy to production
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: |
          # Deploy logic here
          npm run deploy:production
```

### Preview Deployments

```yaml
name: Preview Deployment

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  preview:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '18'

      - run: npm ci
      - run: npm run build

      - name: Deploy preview
        id: deploy
        run: |
          # Deploy to preview environment
          PREVIEW_URL=$(npm run deploy:preview)
          echo "url=$PREVIEW_URL" >> $GITHUB_OUTPUT

      - name: Comment preview URL
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh pr comment ${{ github.event.pull_request.number }} \
            --body "🚀 Preview deployed to ${{ steps.deploy.outputs.url }}"
```

---

## Security Scanning

### Dependency Scanning

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  security:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Run npm audit
        run: npm audit --audit-level=moderate

      - name: Run Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

      - name: Upload results
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: snyk.sarif
```

---

## Best Practices

### Reusable Workflows

Define reusable workflows in `.github/workflows/reusable-*.yml`:

```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci
      - run: npm test
```

Use in other workflows:

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test-node-18:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '18'

  test-node-20:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20'
```

### Composite Actions

Create custom actions in `.github/actions/`:

```yaml
# .github/actions/setup-project/action.yml
name: 'Setup Project'
description: 'Setup Node.js and install dependencies'

inputs:
  node-version:
    description: 'Node.js version'
    required: true

runs:
  using: 'composite'
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'

    - run: npm ci
      shell: bash

    - run: npm run setup
      shell: bash
```

Use in workflows:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: ./.github/actions/setup-project
    with:
      node-version: '18'
```

---

## Resources

- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **Workflow Syntax**: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- **Marketplace**: https://github.com/marketplace?type=actions
- **GitHub CLI in Actions**: https://cli.github.com/manual/gh_help_environment
