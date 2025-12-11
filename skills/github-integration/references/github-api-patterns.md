# GitHub API Patterns and Best Practices

Comprehensive guide to GitHub's REST and GraphQL APIs, including endpoint catalog, authentication patterns, error handling, and performance optimization strategies.

## API Overview

GitHub provides two primary APIs:

- **REST API**: Traditional RESTful endpoints, simple and straightforward
- **GraphQL API**: Flexible query language, efficient for complex data requirements

---

## Authentication

### Personal Access Tokens (PAT)

```typescript
// Classic PAT
const octokit = new Octokit({
  auth: 'ghp_1234567890abcdefghijklmnop'
});

// Fine-grained PAT (recommended)
const octokit = new Octokit({
  auth: 'github_pat_XXXX'
});
```

### GitHub Apps

```typescript
import { createAppAuth } from '@octokit/auth-app';

const auth = createAppAuth({
  appId: 12345,
  privateKey: process.env.PRIVATE_KEY,
  installationId: 67890
});

const { token } = await auth({ type: 'installation' });

const octokit = new Octokit({
  auth: token
});
```

### OAuth Apps

```typescript
import { Octokit } from '@octokit/rest';

// After OAuth flow, use access token
const octokit = new Octokit({
  auth: userAccessToken
});
```

---

## REST API

### Rate Limits

**Limits**:
- Authenticated: 5,000 requests/hour
- Unauthenticated: 60 requests/hour
- GitHub Actions: 1,000 requests/hour per repository

**Checking rate limits**:

```typescript
const { data: rateLimit } = await octokit.rateLimit.get();

console.log(`Remaining: ${rateLimit.rate.remaining}/${rateLimit.rate.limit}`);
console.log(`Resets at: ${new Date(rateLimit.rate.reset * 1000)}`);

// Check specific resource limits
console.log('Core:', rateLimit.resources.core);
console.log('Search:', rateLimit.resources.search);
console.log('GraphQL:', rateLimit.resources.graphql);
```

**Rate limit handling**:

```typescript
async function withRateLimitRetry<T>(apiCall: () => Promise<T>): Promise<T> {
  try {
    return await apiCall();
  } catch (error: any) {
    if (error.status === 403 && error.response?.headers['x-ratelimit-remaining'] === '0') {
      const resetTime = parseInt(error.response.headers['x-ratelimit-reset'], 10);
      const waitTime = (resetTime * 1000) - Date.now() + 1000; // Add 1s buffer

      console.log(`Rate limit exceeded. Waiting ${waitTime / 1000}s...`);
      await new Promise(resolve => setTimeout(resolve, waitTime));

      return apiCall();
    }
    throw error;
  }
}
```

### Issues API

**List issues**:

```typescript
// List repository issues
const { data: issues } = await octokit.issues.listForRepo({
  owner: 'org-name',
  repo: 'repo-name',
  state: 'open',
  labels: 'bug,high-priority',
  sort: 'created',
  direction: 'desc',
  per_page: 100,
  page: 1
});

// List issues assigned to authenticated user
const { data: myIssues } = await octokit.issues.listForAuthenticatedUser({
  filter: 'assigned',
  state: 'open',
  sort: 'updated',
  direction: 'desc'
});

// List organization issues
const { data: orgIssues } = await octokit.issues.listForOrg({
  org: 'org-name',
  filter: 'all',
  state: 'open'
});
```

**Get issue**:

```typescript
const { data: issue } = await octokit.issues.get({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123
});

// Access issue data
console.log(issue.title);
console.log(issue.state);
console.log(issue.labels.map(l => l.name));
console.log(issue.assignees.map(a => a.login));
```

**Create issue**:

```typescript
const { data: newIssue } = await octokit.issues.create({
  owner: 'org-name',
  repo: 'repo-name',
  title: 'Bug: Login fails',
  body: 'Detailed description of the bug',
  labels: ['bug', 'high-priority'],
  assignees: ['username1', 'username2'],
  milestone: 5
});

console.log(`Created issue #${newIssue.number}`);
console.log(`URL: ${newIssue.html_url}`);
```

**Update issue**:

```typescript
const { data: updated } = await octokit.issues.update({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123,
  title: 'Updated title',
  body: 'Updated body',
  state: 'closed',
  labels: ['bug', 'fixed'],
  assignees: ['username'],
  milestone: 6
});
```

**Add labels**:

```typescript
// Add labels to issue
await octokit.issues.addLabels({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123,
  labels: ['in-progress', 'needs-review']
});

// Remove label
await octokit.issues.removeLabel({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123,
  name: 'wontfix'
});

// Replace all labels
await octokit.issues.setLabels({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123,
  labels: ['bug', 'fixed']
});
```

**Comments**:

```typescript
// List comments
const { data: comments } = await octokit.issues.listComments({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123,
  per_page: 100
});

// Create comment
const { data: comment } = await octokit.issues.createComment({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123,
  body: 'This has been fixed in PR #456'
});

// Update comment
await octokit.issues.updateComment({
  owner: 'org-name',
  repo: 'repo-name',
  comment_id: comment.id,
  body: 'Updated comment text'
});

// Delete comment
await octokit.issues.deleteComment({
  owner: 'org-name',
  repo: 'repo-name',
  comment_id: comment.id
});
```

### Pull Requests API

**List pull requests**:

```typescript
const { data: prs } = await octokit.pulls.list({
  owner: 'org-name',
  repo: 'repo-name',
  state: 'open',
  head: 'org-name:feature-branch',
  base: 'main',
  sort: 'created',
  direction: 'desc',
  per_page: 100
});
```

**Get pull request**:

```typescript
const { data: pr } = await octokit.pulls.get({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456
});

console.log(pr.title);
console.log(pr.state);
console.log(pr.mergeable);
console.log(pr.merged);
```

**Create pull request**:

```typescript
const { data: newPr } = await octokit.pulls.create({
  owner: 'org-name',
  repo: 'repo-name',
  title: 'feat: Add authentication',
  body: 'Implementation details',
  head: 'feature-branch',
  base: 'main',
  draft: false,
  maintainer_can_modify: true
});
```

**Update pull request**:

```typescript
await octokit.pulls.update({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456,
  title: 'Updated title',
  body: 'Updated description',
  state: 'closed',
  base: 'develop'
});
```

**Merge pull request**:

```typescript
const { data: merge } = await octokit.pulls.merge({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456,
  commit_title: 'feat: Add authentication',
  commit_message: 'Closes #123',
  merge_method: 'squash' // or 'merge', 'rebase'
});

if (merge.merged) {
  console.log('PR merged successfully');
}
```

**PR reviews**:

```typescript
// List reviews
const { data: reviews } = await octokit.pulls.listReviews({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456
});

// Create review
await octokit.pulls.createReview({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456,
  body: 'Looks good!',
  event: 'APPROVE' // or 'REQUEST_CHANGES', 'COMMENT'
});

// Submit pending review
await octokit.pulls.submitReview({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456,
  review_id: 789,
  event: 'APPROVE'
});
```

**Request reviewers**:

```typescript
await octokit.pulls.requestReviewers({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456,
  reviewers: ['username1', 'username2'],
  team_reviewers: ['team-slug']
});
```

**PR files**:

```typescript
// List files changed in PR
const { data: files } = await octokit.pulls.listFiles({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456
});

files.forEach(file => {
  console.log(`${file.filename}: +${file.additions} -${file.deletions}`);
});
```

### Repositories API

**Get repository**:

```typescript
const { data: repo } = await octokit.repos.get({
  owner: 'org-name',
  repo: 'repo-name'
});

console.log(repo.full_name);
console.log(repo.description);
console.log(repo.stargazers_count);
console.log(repo.open_issues_count);
```

**List repositories**:

```typescript
// List user repositories
const { data: repos } = await octokit.repos.listForUser({
  username: 'username',
  type: 'all',
  sort: 'updated',
  per_page: 100
});

// List organization repositories
const { data: orgRepos } = await octokit.repos.listForOrg({
  org: 'org-name',
  type: 'all'
});

// List authenticated user's repositories
const { data: myRepos } = await octokit.repos.listForAuthenticatedUser({
  visibility: 'all',
  affiliation: 'owner,collaborator'
});
```

**Create repository**:

```typescript
const { data: newRepo } = await octokit.repos.createForAuthenticatedUser({
  name: 'my-project',
  description: 'Project description',
  private: false,
  auto_init: true,
  gitignore_template: 'Node',
  license_template: 'mit'
});
```

**Repository content**:

```typescript
// Get file content
const { data: file } = await octokit.repos.getContent({
  owner: 'org-name',
  repo: 'repo-name',
  path: 'src/index.ts',
  ref: 'main'
});

if ('content' in file) {
  const content = Buffer.from(file.content, 'base64').toString('utf-8');
  console.log(content);
}

// List directory contents
const { data: contents } = await octokit.repos.getContent({
  owner: 'org-name',
  repo: 'repo-name',
  path: 'src'
});

if (Array.isArray(contents)) {
  contents.forEach(item => {
    console.log(`${item.type}: ${item.path}`);
  });
}
```

**Branches**:

```typescript
// List branches
const { data: branches } = await octokit.repos.listBranches({
  owner: 'org-name',
  repo: 'repo-name'
});

// Get branch
const { data: branch } = await octokit.repos.getBranch({
  owner: 'org-name',
  repo: 'repo-name',
  branch: 'main'
});

// Create branch (requires creating a ref)
await octokit.git.createRef({
  owner: 'org-name',
  repo: 'repo-name',
  ref: 'refs/heads/new-branch',
  sha: branch.commit.sha
});
```

### Labels API

**List labels**:

```typescript
const { data: labels } = await octokit.issues.listLabelsForRepo({
  owner: 'org-name',
  repo: 'repo-name',
  per_page: 100
});
```

**Create label**:

```typescript
await octokit.issues.createLabel({
  owner: 'org-name',
  repo: 'repo-name',
  name: 'high-priority',
  color: 'ff0000',
  description: 'Urgent issue that needs immediate attention'
});
```

**Update label**:

```typescript
await octokit.issues.updateLabel({
  owner: 'org-name',
  repo: 'repo-name',
  name: 'high-priority',
  new_name: 'urgent',
  color: 'ff0000',
  description: 'Updated description'
});
```

### Milestones API

**List milestones**:

```typescript
const { data: milestones } = await octokit.issues.listMilestones({
  owner: 'org-name',
  repo: 'repo-name',
  state: 'open',
  sort: 'due_on',
  direction: 'asc'
});
```

**Create milestone**:

```typescript
const { data: milestone } = await octokit.issues.createMilestone({
  owner: 'org-name',
  repo: 'repo-name',
  title: 'Sprint 24',
  description: 'Q1 2024 Sprint 24',
  due_on: '2024-01-15T00:00:00Z',
  state: 'open'
});
```

**Update milestone**:

```typescript
await octokit.issues.updateMilestone({
  owner: 'org-name',
  repo: 'repo-name',
  milestone_number: 5,
  title: 'Updated Sprint 24',
  state: 'closed'
});
```

---

## GraphQL API

### Why GraphQL?

**Use GraphQL when**:
- Fetching nested data (issue + comments + reactions)
- Reducing API calls (multiple resources in one query)
- Custom field selection (only what you need)
- Complex queries spanning multiple resources

**Use REST when**:
- Simple CRUD operations
- Single resource access
- Mutations (creating/updating data)
- File uploads

### Basic Query Structure

```typescript
import { graphql } from '@octokit/graphql';

const graphqlWithAuth = graphql.defaults({
  headers: {
    authorization: `token ${process.env.GITHUB_TOKEN}`
  }
});

const result = await graphqlWithAuth(`
  query {
    viewer {
      login
      name
      email
    }
  }
`);

console.log(result.viewer.login);
```

### Query Variables

```typescript
const result = await graphqlWithAuth(`
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $number) {
        title
        body
        state
      }
    }
  }
`, {
  owner: 'org-name',
  repo: 'repo-name',
  number: 123
});
```

### Fetching Issues with Nested Data

```typescript
const result = await graphqlWithAuth(`
  query($owner: String!, $repo: String!) {
    repository(owner: $owner, name: $repo) {
      issues(first: 50, states: OPEN) {
        nodes {
          number
          title
          body
          state
          createdAt
          author {
            login
          }
          labels(first: 10) {
            nodes {
              name
              color
            }
          }
          comments(first: 20) {
            nodes {
              author {
                login
              }
              body
              createdAt
            }
          }
          reactions(first: 10) {
            nodes {
              content
              user {
                login
              }
            }
          }
        }
      }
    }
  }
`, {
  owner: 'org-name',
  repo: 'repo-name'
});

const issues = result.repository.issues.nodes;
```

### Pagination with GraphQL

```typescript
async function fetchAllIssues(owner: string, repo: string) {
  const issues: any[] = [];
  let hasNextPage = true;
  let cursor: string | null = null;

  while (hasNextPage) {
    const result: any = await graphqlWithAuth(`
      query($owner: String!, $repo: String!, $cursor: String) {
        repository(owner: $owner, name: $repo) {
          issues(first: 100, after: $cursor, states: OPEN) {
            pageInfo {
              hasNextPage
              endCursor
            }
            nodes {
              number
              title
              state
              labels(first: 10) {
                nodes {
                  name
                }
              }
            }
          }
        }
      }
    `, {
      owner,
      repo,
      cursor
    });

    const issuesPage = result.repository.issues;
    issues.push(...issuesPage.nodes);
    hasNextPage = issuesPage.pageInfo.hasNextPage;
    cursor = issuesPage.pageInfo.endCursor;
  }

  return issues;
}
```

### Complex Multi-Repository Queries

```typescript
const result = await graphqlWithAuth(`
  query($org: String!) {
    organization(login: $org) {
      repositories(first: 10, orderBy: {field: UPDATED_AT, direction: DESC}) {
        nodes {
          name
          description
          stargazerCount
          issues(states: OPEN) {
            totalCount
          }
          pullRequests(states: OPEN) {
            totalCount
          }
        }
      }
    }
  }
`, {
  org: 'org-name'
});
```

### GraphQL Mutations

**Create issue**:

```typescript
const result = await graphqlWithAuth(`
  mutation($repositoryId: ID!, $title: String!, $body: String!) {
    createIssue(input: {
      repositoryId: $repositoryId
      title: $title
      body: $body
    }) {
      issue {
        number
        url
      }
    }
  }
`, {
  repositoryId: 'repository-node-id',
  title: 'Bug: Login fails',
  body: 'Description'
});
```

**Add comment**:

```typescript
await graphqlWithAuth(`
  mutation($subjectId: ID!, $body: String!) {
    addComment(input: {
      subjectId: $subjectId
      body: $body
    }) {
      commentEdge {
        node {
          id
          body
        }
      }
    }
  }
`, {
  subjectId: 'issue-node-id',
  body: 'Comment text'
});
```

---

## Performance Optimization

### Conditional Requests (ETags)

```typescript
let etag: string | undefined;
let cachedData: any;

async function fetchWithETag() {
  const headers: any = {};
  if (etag) {
    headers['If-None-Match'] = etag;
  }

  try {
    const response = await octokit.request('GET /repos/{owner}/{repo}/issues', {
      owner: 'org-name',
      repo: 'repo-name',
      headers
    });

    etag = response.headers.etag;
    cachedData = response.data;
    return response.data;
  } catch (error: any) {
    if (error.status === 304) {
      // Not modified, use cached data
      return cachedData;
    }
    throw error;
  }
}
```

### Batching Requests

```typescript
// ❌ BAD: Multiple sequential requests
for (const num of issueNumbers) {
  const issue = await octokit.issues.get({ owner, repo, issue_number: num });
  console.log(issue.data.title);
}

// ✅ GOOD: Parallel requests
const issues = await Promise.all(
  issueNumbers.map(num =>
    octokit.issues.get({ owner, repo, issue_number: num })
  )
);
issues.forEach(response => console.log(response.data.title));
```

### Caching Strategy

```typescript
class GitHubCache {
  private cache = new Map<string, { data: any; expiry: number }>();
  private ttl = 5 * 60 * 1000; // 5 minutes

  async get<T>(key: string, fetcher: () => Promise<T>): Promise<T> {
    const cached = this.cache.get(key);

    if (cached && Date.now() < cached.expiry) {
      return cached.data as T;
    }

    const data = await fetcher();
    this.cache.set(key, {
      data,
      expiry: Date.now() + this.ttl
    });

    return data;
  }
}

const cache = new GitHubCache();

// Usage
const repo = await cache.get(
  `repo:${owner}/${repo}`,
  () => octokit.repos.get({ owner, repo }).then(r => r.data)
);
```

---

## Error Handling

```typescript
async function safeGitHubRequest<T>(
  request: () => Promise<T>
): Promise<T | null> {
  try {
    return await request();
  } catch (error: any) {
    // Rate limit
    if (error.status === 403 && error.message.includes('rate limit')) {
      const resetTime = new Date(error.response.headers['x-ratelimit-reset'] * 1000);
      throw new Error(`Rate limit exceeded. Resets at ${resetTime}`);
    }

    // Not found
    if (error.status === 404) {
      console.error('Resource not found');
      return null;
    }

    // Validation failed
    if (error.status === 422) {
      console.error('Validation failed:', error.errors);
      return null;
    }

    // Unauthorized
    if (error.status === 401) {
      throw new Error('Authentication required or token expired');
    }

    // Forbidden
    if (error.status === 403) {
      throw new Error('Insufficient permissions');
    }

    throw error;
  }
}
```

---

## Best Practices

1. **Use GraphQL for complex queries**: Reduce API calls by fetching nested data
2. **Implement caching**: Cache repository metadata and rarely-changing data
3. **Handle rate limits**: Check limits before bulk operations
4. **Use conditional requests**: Leverage ETags to avoid unnecessary data transfer
5. **Batch requests**: Use Promise.all() for parallel operations
6. **Handle errors gracefully**: Implement retry logic with exponential backoff
7. **Use fine-grained tokens**: Limit token scope to minimum required permissions
8. **Validate webhooks**: Verify webhook signatures for security
9. **Use pagination**: Don't fetch all data at once, use pagination
10. **Monitor usage**: Track API usage to avoid hitting limits

---

## Resources

- **REST API Documentation**: https://docs.github.com/en/rest
- **GraphQL API Documentation**: https://docs.github.com/en/graphql
- **Octokit.js**: https://github.com/octokit/octokit.js
- **GitHub Apps**: https://docs.github.com/en/apps
- **Webhooks**: https://docs.github.com/en/webhooks
