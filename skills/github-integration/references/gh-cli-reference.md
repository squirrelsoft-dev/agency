# GitHub CLI (gh) Complete Reference

Comprehensive reference for the GitHub CLI (`gh`), covering all major commands, flags, and usage patterns for automating GitHub workflows.

## Installation

```bash
# macOS
brew install gh

# Linux (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Windows
winget install --id GitHub.cli
# Or via scoop
scoop install gh
```

---

## Authentication

### gh auth login

Interactive authentication flow.

```bash
# Interactive login
gh auth login

# Login with specific account
gh auth login --with-token < token.txt

# Login with specific hostname (GitHub Enterprise)
gh auth login --hostname github.enterprise.com

# Login with specific protocol
gh auth login --git-protocol ssh
gh auth login --git-protocol https

# Login with specific scope
gh auth login --scopes read:org,write:public_key
```

### gh auth status

Check authentication status.

```bash
# Check current authentication
gh auth status

# Check for specific hostname
gh auth status --hostname github.enterprise.com

# Show token
gh auth status --show-token
```

### gh auth logout

Logout from GitHub.

```bash
# Logout from current host
gh auth logout

# Logout from specific hostname
gh auth logout --hostname github.enterprise.com
```

### gh auth refresh

Refresh authentication token with additional scopes.

```bash
# Add read:org scope
gh auth refresh --scopes read:org

# Reset to default scopes
gh auth refresh --reset-scopes
```

---

## Repository Commands

### gh repo create

Create a new repository.

```bash
# Interactive creation
gh repo create

# Create with name
gh repo create my-project

# Create with organization
gh repo create org-name/my-project

# Create from current directory
gh repo create --source=. --remote=origin

# Create with options
gh repo create my-project --public --description "My awesome project"
gh repo create my-project --private --clone
gh repo create my-project --template owner/template-repo

# Disable issues, wiki, projects
gh repo create my-project --disable-issues --disable-wiki
```

### gh repo clone

Clone a repository.

```bash
# Clone repository
gh repo clone owner/repo

# Clone to specific directory
gh repo clone owner/repo target-dir

# Clone with submodules
gh repo clone owner/repo -- --recurse-submodules
```

### gh repo fork

Fork a repository.

```bash
# Fork current repository
gh repo fork

# Fork specific repository
gh repo fork owner/repo

# Fork and clone
gh repo fork owner/repo --clone

# Fork with custom name
gh repo fork owner/repo --fork-name my-fork
```

### gh repo view

View repository details.

```bash
# View current repository
gh repo view

# View specific repository
gh repo view owner/repo

# View in browser
gh repo view --web

# View as JSON
gh repo view --json name,description,owner,url

# View with specific fields
gh repo view --json name,stargazersCount,forkCount --jq '.stargazersCount'
```

### gh repo list

List repositories.

```bash
# List your repositories
gh repo list

# List organization repositories
gh repo list org-name

# Limit results
gh repo list --limit 50

# Filter by visibility
gh repo list --public
gh repo list --private

# Filter by language
gh repo list --language typescript

# Filter by topic
gh repo list --topic react

# Sort options
gh repo list --sort created
gh repo list --sort updated
gh repo list --sort pushed
gh repo list --sort full_name

# Output as JSON
gh repo list --json name,owner,description,url
```

### gh repo archive/unarchive

Archive or unarchive a repository.

```bash
# Archive current repository
gh repo archive

# Archive specific repository
gh repo archive owner/repo

# Unarchive
gh repo unarchive owner/repo
```

### gh repo delete

Delete a repository.

```bash
# Delete with confirmation
gh repo delete owner/repo

# Delete without confirmation
gh repo delete owner/repo --yes
```

---

## Issue Commands

### gh issue list

List issues.

```bash
# List open issues
gh issue list

# List all issues (including closed)
gh issue list --state all
gh issue list --state closed

# Filter by label
gh issue list --label bug
gh issue list --label "high priority,bug"

# Filter by assignee
gh issue list --assignee @me
gh issue list --assignee username

# Filter by author
gh issue list --author username

# Filter by milestone
gh issue list --milestone "Sprint 24"

# Search in title/body
gh issue list --search "login error"

# Limit results
gh issue list --limit 50

# Output as JSON
gh issue list --json number,title,labels,state,author

# Custom template
gh issue list --json number,title --template '{{range .}}#{{.number}}: {{.title}}{{"\n"}}{{end}}'

# Filter by mention
gh issue list --mention username
```

### gh issue view

View issue details.

```bash
# View issue by number
gh issue view 123

# View in browser
gh issue view 123 --web

# View with comments
gh issue view 123 --comments

# View as JSON
gh issue view 123 --json number,title,body,state,labels,assignees,comments

# View specific fields
gh issue view 123 --json title,state --jq '.title'
```

### gh issue create

Create a new issue.

```bash
# Interactive creation
gh issue create

# With title and body
gh issue create --title "Bug: Login fails" --body "Description of the bug"

# With title from stdin
echo "Bug report" | gh issue create --title "Login issue" --body-file -

# With template
gh issue create --template bug_report.md

# With labels
gh issue create --title "Feature request" --label feature,enhancement

# With assignees
gh issue create --title "Task" --assignee username1,username2

# With milestone
gh issue create --title "Sprint task" --milestone "Sprint 24"

# With project
gh issue create --title "Task" --project "Project Board"

# Open in editor
gh issue create --editor

# Output as JSON
gh issue create --title "Test" --body "Test issue" --json number,url
```

### gh issue edit

Edit an issue.

```bash
# Edit title
gh issue edit 123 --title "Updated title"

# Edit body
gh issue edit 123 --body "Updated description"

# Add labels
gh issue edit 123 --add-label bug,high-priority

# Remove labels
gh issue edit 123 --remove-label wontfix

# Add assignees
gh issue edit 123 --add-assignee username1,username2

# Remove assignees
gh issue edit 123 --remove-assignee username1

# Set milestone
gh issue edit 123 --milestone "Sprint 24"

# Remove milestone
gh issue edit 123 --milestone ""

# Add to project
gh issue edit 123 --add-project "Project Board"

# Remove from project
gh issue edit 123 --remove-project "Project Board"
```

### gh issue close

Close an issue.

```bash
# Close issue
gh issue close 123

# Close with comment
gh issue close 123 --comment "Fixed in PR #456"

# Close as completed
gh issue close 123 --reason completed

# Close as not planned
gh issue close 123 --reason "not planned"
```

### gh issue reopen

Reopen a closed issue.

```bash
# Reopen issue
gh issue reopen 123

# Reopen with comment
gh issue reopen 123 --comment "Reopening due to regression"
```

### gh issue comment

Add a comment to an issue.

```bash
# Add comment
gh issue comment 123 --body "This looks good"

# Add comment from file
gh issue comment 123 --body-file comment.md

# Edit comment (with editor)
gh issue comment 123 --edit

# Edit specific comment
gh issue comment 123 --edit-last
```

### gh issue delete

Delete an issue.

```bash
# Delete issue with confirmation
gh issue delete 123

# Delete without confirmation
gh issue delete 123 --yes
```

### gh issue transfer

Transfer an issue to another repository.

```bash
# Transfer issue
gh issue transfer 123 owner/target-repo
```

---

## Pull Request Commands

### gh pr list

List pull requests.

```bash
# List open PRs
gh pr list

# List all PRs
gh pr list --state all
gh pr list --state closed
gh pr list --state merged

# Filter by label
gh pr list --label ready-for-review

# Filter by author
gh pr list --author @me
gh pr list --author username

# Filter by assignee
gh pr list --assignee username

# Filter by base branch
gh pr list --base main

# Filter by head branch
gh pr list --head feature-branch

# Draft PRs only
gh pr list --draft

# Search
gh pr list --search "fix login"

# Output as JSON
gh pr list --json number,title,state,author,isDraft

# Limit results
gh pr list --limit 30
```

### gh pr view

View pull request details.

```bash
# View PR by number
gh pr view 456

# View in browser
gh pr view 456 --web

# View with comments
gh pr view 456 --comments

# View as JSON
gh pr view 456 --json number,title,body,state,reviews,commits

# View specific fields
gh pr view 456 --json mergeable,mergeStateStatus --jq '.mergeable'
```

### gh pr create

Create a pull request.

```bash
# Interactive creation
gh pr create

# With title and body
gh pr create --title "feat: Add authentication" --body "Implementation details"

# Auto-fill from commits
gh pr create --fill

# Use pull request template
gh pr create --template pull_request_template.md

# Set base branch
gh pr create --base develop --head feature-branch

# Create draft PR
gh pr create --draft

# Add reviewers
gh pr create --reviewer username1,username2

# Add assignees
gh pr create --assignee @me

# Add labels
gh pr create --label feature,needs-review

# Set milestone
gh pr create --milestone "Sprint 24"

# Open in editor
gh pr create --editor

# Open in browser after creation
gh pr create --web

# Output as JSON
gh pr create --title "Test" --body "Test PR" --json number,url
```

### gh pr edit

Edit a pull request.

```bash
# Edit title
gh pr edit 456 --title "Updated title"

# Edit body
gh pr edit 456 --body "Updated description"

# Add reviewers
gh pr edit 456 --add-reviewer username1,username2

# Remove reviewers
gh pr edit 456 --remove-reviewer username1

# Add assignees
gh pr edit 456 --add-assignee username

# Add labels
gh pr edit 456 --add-label bug,high-priority

# Set base branch
gh pr edit 456 --base main

# Set milestone
gh pr edit 456 --milestone "Sprint 24"

# Convert to/from draft
gh pr ready 456  # Mark as ready for review
gh pr edit 456 --draft  # Convert to draft
```

### gh pr close

Close a pull request without merging.

```bash
# Close PR
gh pr close 456

# Close with comment
gh pr close 456 --comment "Closing due to alternative approach"

# Delete branch after closing
gh pr close 456 --delete-branch
```

### gh pr reopen

Reopen a closed pull request.

```bash
# Reopen PR
gh pr reopen 456

# Reopen with comment
gh pr reopen 456 --comment "Reopening after fixes"
```

### gh pr merge

Merge a pull request.

```bash
# Interactive merge
gh pr merge 456

# Merge with squash
gh pr merge 456 --squash

# Merge with merge commit
gh pr merge 456 --merge

# Merge with rebase
gh pr merge 456 --rebase

# Auto-merge when checks pass
gh pr merge 456 --auto --squash

# Delete branch after merge
gh pr merge 456 --delete-branch

# Custom commit message
gh pr merge 456 --squash --subject "feat: Add feature" --body "Closes #123"

# Disable auto-merge
gh pr merge 456 --disable-auto
```

### gh pr review

Review a pull request.

```bash
# Interactive review
gh pr review 456

# Approve PR
gh pr review 456 --approve

# Request changes
gh pr review 456 --request-changes --body "Please fix the tests"

# Comment on PR
gh pr review 456 --comment --body "Looks good overall"

# Approve with comment
gh pr review 456 --approve --body "LGTM! Great work"

# Review from file
gh pr review 456 --approve --body-file review.md
```

### gh pr comment

Add a comment to a pull request.

```bash
# Add comment
gh pr comment 456 --body "Thanks for the contribution!"

# Add comment from file
gh pr comment 456 --body-file comment.md

# Edit last comment
gh pr comment 456 --edit-last
```

### gh pr diff

View pull request diff.

```bash
# View diff
gh pr diff 456

# View diff with context
gh pr diff 456 --patch

# View diff for specific file
gh pr diff 456 -- path/to/file.ts
```

### gh pr checkout

Checkout a pull request locally.

```bash
# Checkout PR by number
gh pr checkout 456

# Checkout PR by branch
gh pr checkout feature-branch

# Checkout and create new branch
gh pr checkout 456 --branch local-branch-name

# Force checkout (discard local changes)
gh pr checkout 456 --force
```

### gh pr checks

View pull request checks.

```bash
# View all checks
gh pr checks 456

# Watch checks (auto-refresh)
gh pr checks 456 --watch

# View checks as JSON
gh pr checks 456 --json name,conclusion,status
```

---

## Release Commands

### gh release list

List releases.

```bash
# List releases
gh release list

# Limit results
gh release list --limit 20

# Exclude drafts
gh release list --exclude-drafts

# Exclude pre-releases
gh release list --exclude-pre-releases
```

### gh release view

View release details.

```bash
# View latest release
gh release view

# View specific release
gh release view v1.0.0

# View in browser
gh release view v1.0.0 --web

# View as JSON
gh release view v1.0.0 --json tagName,name,body,assets
```

### gh release create

Create a release.

```bash
# Interactive creation
gh release create v1.0.0

# With title and notes
gh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes here"

# Auto-generate notes
gh release create v1.0.0 --generate-notes

# Upload assets
gh release create v1.0.0 --notes "Release" dist/*.zip

# Create draft
gh release create v1.0.0 --draft

# Mark as pre-release
gh release create v1.0.0 --prerelease

# Set target branch
gh release create v1.0.0 --target develop
```

### gh release delete

Delete a release.

```bash
# Delete release
gh release delete v1.0.0

# Delete without confirmation
gh release delete v1.0.0 --yes

# Keep the git tag
gh release delete v1.0.0 --yes --cleanup-tag=false
```

### gh release download

Download release assets.

```bash
# Download all assets from latest release
gh release download

# Download from specific release
gh release download v1.0.0

# Download specific asset
gh release download v1.0.0 --pattern "*.zip"

# Download to directory
gh release download v1.0.0 --dir downloads/
```

---

## Workflow Commands

### gh workflow list

List workflows.

```bash
# List all workflows
gh workflow list

# List with status
gh workflow list --all

# Output as JSON
gh workflow list --json name,state,id
```

### gh workflow view

View workflow details.

```bash
# View workflow by name
gh workflow view "CI"

# View workflow by file
gh workflow view .github/workflows/ci.yml

# View in browser
gh workflow view "CI" --web

# View as JSON
gh workflow view "CI" --json name,state,path
```

### gh workflow run

Trigger a workflow run.

```bash
# Run workflow
gh workflow run "CI"

# Run with inputs
gh workflow run "Deploy" --field environment=production --field version=1.0.0

# Run on specific branch
gh workflow run "CI" --ref feature-branch
```

### gh workflow enable/disable

Enable or disable a workflow.

```bash
# Enable workflow
gh workflow enable "CI"

# Disable workflow
gh workflow disable "CI"
```

---

## Run Commands

### gh run list

List workflow runs.

```bash
# List recent runs
gh run list

# Filter by workflow
gh run list --workflow "CI"

# Filter by status
gh run list --status success
gh run list --status failure
gh run list --status in_progress

# Filter by branch
gh run list --branch main

# Limit results
gh run list --limit 20

# Output as JSON
gh run list --json databaseId,status,conclusion,workflowName
```

### gh run view

View run details.

```bash
# View latest run
gh run view

# View specific run
gh run view 1234567890

# View in browser
gh run view 1234567890 --web

# View logs
gh run view 1234567890 --log

# View failed logs only
gh run view 1234567890 --log-failed

# View as JSON
gh run view 1234567890 --json status,conclusion,jobs
```

### gh run watch

Watch a run until it completes.

```bash
# Watch latest run
gh run watch

# Watch specific run
gh run watch 1234567890

# Exit after specific status
gh run watch 1234567890 --exit-status
```

### gh run rerun

Rerun a workflow run.

```bash
# Rerun entire run
gh run rerun 1234567890

# Rerun failed jobs only
gh run rerun 1234567890 --failed
```

### gh run cancel

Cancel a workflow run.

```bash
# Cancel run
gh run cancel 1234567890
```

### gh run download

Download run artifacts.

```bash
# Download all artifacts
gh run download 1234567890

# Download specific artifact
gh run download 1234567890 --name artifact-name

# Download to directory
gh run download 1234567890 --dir artifacts/
```

---

## Project Commands

### gh project list

List projects.

```bash
# List user projects
gh project list --owner @me

# List organization projects
gh project list --owner org-name

# Limit results
gh project list --limit 20

# Output as JSON
gh project list --owner org-name --json number,title,shortDescription
```

### gh project view

View project details.

```bash
# View project by number
gh project view 1 --owner org-name

# View in browser
gh project view 1 --owner org-name --web

# Output as JSON
gh project view 1 --owner org-name --json title,fields,items
```

### gh project item-add

Add item to project.

```bash
# Add issue to project
gh project item-add 1 --owner org-name --url https://github.com/org/repo/issues/123

# Add PR to project
gh project item-add 1 --owner org-name --url https://github.com/org/repo/pull/456
```

### gh project item-list

List project items.

```bash
# List items
gh project item-list 1 --owner org-name

# Limit results
gh project item-list 1 --owner org-name --limit 50

# Output as JSON
gh project item-list 1 --owner org-name --json title,state,type
```

---

## Alias Commands

### gh alias set

Create command aliases.

```bash
# Create simple alias
gh alias set prs 'pr list'

# Create alias with flags
gh alias set issues-open 'issue list --state open'

# Create alias with shell command
gh alias set clone-mine '!gh repo list --json name --jq ".[].name" | xargs -I {} gh repo clone {}'
```

### gh alias list

List all aliases.

```bash
# List aliases
gh alias list
```

### gh alias delete

Delete an alias.

```bash
# Delete alias
gh alias delete prs
```

---

## Configuration

### Config file location

- macOS/Linux: `~/.config/gh/config.yml`
- Windows: `%AppData%\GitHub CLI\config.yml`

### Common configuration

```yaml
# Example config.yml
git_protocol: ssh
editor: vim
prompt: enabled
pager: less

aliases:
  co: pr checkout
  prs: pr list
  issues-open: issue list --state open

hosts:
  github.com:
    user: username
    oauth_token: gho_XXXX
    git_protocol: ssh
```

---

## Advanced Patterns

### JSON Output and jq Integration

```bash
# Extract specific fields
gh issue list --json number,title --jq '.[].title'

# Filter by condition
gh issue list --json number,title,labels --jq '.[] | select(.labels[].name == "bug")'

# Count items
gh pr list --json number --jq 'length'

# Format output
gh issue list --json number,title --jq '.[] | "#\(.number): \(.title)"'

# Complex queries
gh pr list --json number,reviews --jq '.[] | select(.reviews | length > 0) | .number'
```

### Shell Integration

```bash
# Loop through issues
gh issue list --json number --jq '.[].number' | while read num; do
  gh issue view $num
done

# Bulk operations
gh issue list --label needs-milestone --json number --jq '.[].number' | \
  xargs -I {} gh issue edit {} --milestone "Sprint 24"

# Conditional operations
if gh pr checks --json conclusion --jq '.[] | select(.conclusion=="failure")' | grep -q .; then
  echo "Some checks failed"
fi
```

### Environment Variables

```bash
# Set default repository
export GH_REPO=owner/repo

# Set token
export GH_TOKEN=ghp_XXXX

# Set enterprise hostname
export GH_HOST=github.enterprise.com

# Disable interactive prompts
export GH_PROMPT_DISABLED=1

# Set pager
export GH_PAGER=cat  # Disable paging
```

---

## Best Practices

1. **Use JSON output for scripting**: Always use `--json` flag for programmatic access
2. **Store tokens securely**: Use `gh auth login` instead of environment variables when possible
3. **Use aliases for common operations**: Save time with frequently used command combinations
4. **Handle rate limits**: Check `gh api rate_limit` before bulk operations
5. **Use specific field selection**: Use `--jq` to extract only needed fields
6. **Leverage templates**: Use issue and PR templates for consistency
7. **Automate with GitHub Actions**: Integrate gh CLI into Actions workflows

---

## Resources

- **Official Documentation**: https://cli.github.com/manual/
- **GitHub API**: https://docs.github.com/en/rest
- **GraphQL API**: https://docs.github.com/en/graphql
- **Issue Templates**: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests
