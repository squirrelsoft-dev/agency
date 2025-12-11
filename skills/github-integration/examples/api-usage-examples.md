# GitHub API Usage Examples

Practical TypeScript/JavaScript examples demonstrating common GitHub API patterns using Octokit.

## Setup and Configuration

```typescript
import { Octokit } from '@octokit/rest';
import { graphql } from '@octokit/graphql';

// Initialize REST API client
const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN,
  userAgent: 'my-app v1.0.0',
  baseUrl: 'https://api.github.com',
  log: {
    debug: () => {},
    info: () => {},
    warn: console.warn,
    error: console.error
  },
  request: {
    timeout: 5000
  }
});

// Initialize GraphQL client
const graphqlWithAuth = graphql.defaults({
  headers: {
    authorization: `token ${process.env.GITHUB_TOKEN}`
  }
});
```

---

## Issue Management Examples

### 1. Create Issue with Full Details

```typescript
interface CreateIssueParams {
  owner: string;
  repo: string;
  title: string;
  body: string;
  labels?: string[];
  assignees?: string[];
  milestone?: number;
}

async function createIssue(params: CreateIssueParams) {
  const { data: issue } = await octokit.issues.create({
    owner: params.owner,
    repo: params.repo,
    title: params.title,
    body: params.body,
    labels: params.labels || [],
    assignees: params.assignees || [],
    milestone: params.milestone
  });

  console.log(`Created issue #${issue.number}: ${issue.html_url}`);
  return issue;
}

// Usage
await createIssue({
  owner: 'org-name',
  repo: 'repo-name',
  title: 'Bug: Login fails on mobile',
  body: 'Detailed description of the bug...',
  labels: ['bug', 'mobile', 'high-priority'],
  assignees: ['developer1']
});
```

### 2. Fetch Issues with Pagination

```typescript
interface Issue {
  number: number;
  title: string;
  state: string;
  labels: Array<{ name: string }>;
}

async function fetchAllIssues(
  owner: string,
  repo: string,
  state: 'open' | 'closed' | 'all' = 'open'
): Promise<Issue[]> {
  const issues: Issue[] = [];
  let page = 1;
  const perPage = 100;

  while (true) {
    const { data } = await octokit.issues.listForRepo({
      owner,
      repo,
      state,
      per_page: perPage,
      page
    });

    if (data.length === 0) break;

    issues.push(...data);

    // Check if we've reached the last page
    if (data.length < perPage) break;

    page++;
  }

  return issues;
}

// Usage
const allIssues = await fetchAllIssues('org-name', 'repo-name', 'open');
console.log(`Found ${allIssues.length} open issues`);
```

### 3. Batch Update Issues

```typescript
async function batchUpdateIssues(
  owner: string,
  repo: string,
  issueNumbers: number[],
  updates: {
    labels?: string[];
    assignees?: string[];
    milestone?: number;
    state?: 'open' | 'closed';
  }
) {
  const results = await Promise.allSettled(
    issueNumbers.map(issue_number =>
      octokit.issues.update({
        owner,
        repo,
        issue_number,
        ...updates
      })
    )
  );

  const succeeded = results.filter(r => r.status === 'fulfilled').length;
  const failed = results.filter(r => r.status === 'rejected').length;

  console.log(`Updated ${succeeded} issues, ${failed} failed`);

  return results;
}

// Usage
await batchUpdateIssues(
  'org-name',
  'repo-name',
  [123, 124, 125],
  {
    labels: ['in-progress'],
    milestone: 5
  }
);
```

### 4. Add Comment with Mentions

```typescript
async function addCommentWithMentions(
  owner: string,
  repo: string,
  issueNumber: number,
  message: string,
  mentions: string[]
) {
  const mentionText = mentions.map(user => `@${user}`).join(' ');
  const body = `${mentionText}\n\n${message}`;

  const { data: comment } = await octokit.issues.createComment({
    owner,
    repo,
    issue_number: issueNumber,
    body
  });

  console.log(`Added comment: ${comment.html_url}`);
  return comment;
}

// Usage
await addCommentWithMentions(
  'org-name',
  'repo-name',
  123,
  'This issue needs urgent attention',
  ['team-lead', 'senior-dev']
);
```

---

## Pull Request Examples

### 5. Create PR from Branch

```typescript
interface CreatePRParams {
  owner: string;
  repo: string;
  title: string;
  head: string;
  base: string;
  body?: string;
  draft?: boolean;
  maintainerCanModify?: boolean;
}

async function createPR(params: CreatePRParams) {
  const { data: pr } = await octokit.pulls.create({
    owner: params.owner,
    repo: params.repo,
    title: params.title,
    head: params.head,
    base: params.base,
    body: params.body || '',
    draft: params.draft || false,
    maintainer_can_modify: params.maintainerCanModify ?? true
  });

  console.log(`Created PR #${pr.number}: ${pr.html_url}`);
  return pr;
}

// Usage
await createPR({
  owner: 'org-name',
  repo: 'repo-name',
  title: 'feat: Add authentication',
  head: 'feature-auth',
  base: 'main',
  body: '## Summary\n\nAdds authentication...',
  draft: true
});
```

### 6. Check PR Mergibility

```typescript
interface PRStatus {
  number: number;
  mergeable: boolean;
  mergeableState: string;
  isDraft: boolean;
  reviewDecision: string | null;
  checksPass: boolean;
}

async function checkPRStatus(
  owner: string,
  repo: string,
  pullNumber: number
): Promise<PRStatus> {
  const { data: pr } = await octokit.pulls.get({
    owner,
    repo,
    pull_number: pullNumber
  });

  // Check if all checks passed
  const { data: checks } = await octokit.checks.listForRef({
    owner,
    repo,
    ref: pr.head.sha
  });

  const checksPass = checks.check_runs.every(
    check => check.conclusion === 'success'
  );

  return {
    number: pr.number,
    mergeable: pr.mergeable === true,
    mergeableState: pr.mergeable_state || 'unknown',
    isDraft: pr.draft || false,
    reviewDecision: null, // Would need GraphQL for this
    checksPass
  };
}

// Usage
const status = await checkPRStatus('org-name', 'repo-name', 456);
if (status.mergeable && status.checksPass && !status.isDraft) {
  console.log('PR is ready to merge!');
}
```

### 7. Request Reviews

```typescript
async function requestReviews(
  owner: string,
  repo: string,
  pullNumber: number,
  reviewers: string[],
  teamReviewers: string[] = []
) {
  await octokit.pulls.requestReviewers({
    owner,
    repo,
    pull_number: pullNumber,
    reviewers,
    team_reviewers: teamReviewers
  });

  console.log(`Requested reviews from: ${reviewers.join(', ')}`);
}

// Usage
await requestReviews(
  'org-name',
  'repo-name',
  456,
  ['senior-dev', 'tech-lead'],
  ['platform-team']
);
```

### 8. Auto-merge PR

```typescript
async function autoMergePR(
  owner: string,
  repo: string,
  pullNumber: number,
  mergeMethod: 'merge' | 'squash' | 'rebase' = 'squash'
) {
  try {
    const { data: merge } = await octokit.pulls.merge({
      owner,
      repo,
      pull_number: pullNumber,
      merge_method: mergeMethod
    });

    if (merge.merged) {
      console.log(`✅ PR #${pullNumber} merged successfully`);
      console.log(`Merge SHA: ${merge.sha}`);
    }

    return merge;
  } catch (error: any) {
    if (error.status === 405) {
      console.error('PR cannot be merged (checks not passing or conflicts exist)');
    }
    throw error;
  }
}

// Usage
await autoMergePR('org-name', 'repo-name', 456, 'squash');
```

---

## Repository Operations

### 9. Get Repository Metadata

```typescript
interface RepoMetadata {
  name: string;
  fullName: string;
  description: string;
  stars: number;
  forks: number;
  openIssues: number;
  defaultBranch: string;
  language: string;
  lastPush: string;
}

async function getRepoMetadata(owner: string, repo: string): Promise<RepoMetadata> {
  const { data } = await octokit.repos.get({
    owner,
    repo
  });

  return {
    name: data.name,
    fullName: data.full_name,
    description: data.description || 'No description',
    stars: data.stargazers_count,
    forks: data.forks_count,
    openIssues: data.open_issues_count,
    defaultBranch: data.default_branch,
    language: data.language || 'Unknown',
    lastPush: data.pushed_at || ''
  };
}

// Usage
const metadata = await getRepoMetadata('org-name', 'repo-name');
console.log(`${metadata.fullName}: ${metadata.stars} ⭐`);
```

### 10. Search Code in Repository

```typescript
interface CodeSearchResult {
  path: string;
  matches: number;
  htmlUrl: string;
}

async function searchCode(
  query: string,
  owner: string,
  repo: string
): Promise<CodeSearchResult[]> {
  const searchQuery = `${query} repo:${owner}/${repo}`;

  const { data } = await octokit.search.code({
    q: searchQuery,
    per_page: 100
  });

  return data.items.map(item => ({
    path: item.path,
    matches: item.text_matches?.length || 0,
    htmlUrl: item.html_url
  }));
}

// Usage
const results = await searchCode('TODO', 'org-name', 'repo-name');
console.log(`Found ${results.length} files with TODOs`);
```

### 11. List Repository Contributors

```typescript
interface Contributor {
  login: string;
  contributions: number;
  avatarUrl: string;
}

async function getTopContributors(
  owner: string,
  repo: string,
  limit: number = 10
): Promise<Contributor[]> {
  const { data } = await octokit.repos.listContributors({
    owner,
    repo,
    per_page: limit
  });

  return data.map(contributor => ({
    login: contributor.login || '',
    contributions: contributor.contributions,
    avatarUrl: contributor.avatar_url || ''
  }));
}

// Usage
const contributors = await getTopContributors('org-name', 'repo-name', 5);
contributors.forEach(c => {
  console.log(`${c.login}: ${c.contributions} contributions`);
});
```

---

## GraphQL Examples

### 12. Fetch Issue with Nested Data

```typescript
interface IssueWithComments {
  number: number;
  title: string;
  body: string;
  state: string;
  author: string;
  labels: string[];
  comments: Array<{
    author: string;
    body: string;
    createdAt: string;
  }>;
}

async function fetchIssueWithComments(
  owner: string,
  repo: string,
  number: number
): Promise<IssueWithComments> {
  const result: any = await graphqlWithAuth(`
    query($owner: String!, $repo: String!, $number: Int!) {
      repository(owner: $owner, name: $repo) {
        issue(number: $number) {
          number
          title
          body
          state
          author {
            login
          }
          labels(first: 20) {
            nodes {
              name
            }
          }
          comments(first: 100) {
            nodes {
              author {
                login
              }
              body
              createdAt
            }
          }
        }
      }
    }
  `, {
    owner,
    repo,
    number
  });

  const issue = result.repository.issue;

  return {
    number: issue.number,
    title: issue.title,
    body: issue.body,
    state: issue.state,
    author: issue.author.login,
    labels: issue.labels.nodes.map((l: any) => l.name),
    comments: issue.comments.nodes
  };
}

// Usage
const issue = await fetchIssueWithComments('org-name', 'repo-name', 123);
console.log(`Issue #${issue.number}: ${issue.comments.length} comments`);
```

### 13. Fetch Multiple Repositories

```typescript
interface RepoSummary {
  name: string;
  description: string;
  stars: number;
  openIssues: number;
  openPRs: number;
}

async function fetchOrgRepositories(org: string): Promise<RepoSummary[]> {
  const result: any = await graphqlWithAuth(`
    query($org: String!) {
      organization(login: $org) {
        repositories(first: 100, orderBy: {field: UPDATED_AT, direction: DESC}) {
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
    org
  });

  return result.organization.repositories.nodes.map((repo: any) => ({
    name: repo.name,
    description: repo.description || '',
    stars: repo.stargazerCount,
    openIssues: repo.issues.totalCount,
    openPRs: repo.pullRequests.totalCount
  }));
}

// Usage
const repos = await fetchOrgRepositories('org-name');
repos.forEach(repo => {
  console.log(`${repo.name}: ${repo.openIssues} issues, ${repo.openPRs} PRs`);
});
```

---

## Advanced Patterns

### 14. Rate Limit Handling with Retry

```typescript
async function withRateLimitRetry<T>(
  operation: () => Promise<T>,
  maxRetries: number = 3
): Promise<T> {
  let retries = 0;

  while (true) {
    try {
      // Check rate limit before operation
      const { data: rateLimit } = await octokit.rateLimit.get();

      if (rateLimit.rate.remaining < 10) {
        const resetTime = new Date(rateLimit.rate.reset * 1000);
        const waitTime = resetTime.getTime() - Date.now() + 1000;

        console.log(`Rate limit low, waiting ${waitTime / 1000}s...`);
        await new Promise(resolve => setTimeout(resolve, waitTime));
      }

      return await operation();
    } catch (error: any) {
      if (error.status === 403 && error.message.includes('rate limit')) {
        if (retries >= maxRetries) {
          throw new Error(`Rate limit exceeded after ${maxRetries} retries`);
        }

        const resetTime = new Date(error.response.headers['x-ratelimit-reset'] * 1000);
        const waitTime = resetTime.getTime() - Date.now() + 1000;

        console.log(`Rate limited, waiting ${waitTime / 1000}s... (retry ${retries + 1}/${maxRetries})`);
        await new Promise(resolve => setTimeout(resolve, waitTime));

        retries++;
      } else {
        throw error;
      }
    }
  }
}

// Usage
const issue = await withRateLimitRetry(() =>
  octokit.issues.get({
    owner: 'org-name',
    repo: 'repo-name',
    issue_number: 123
  })
);
```

### 15. Batch Operations with Concurrency Limit

```typescript
async function batchWithConcurrency<T, R>(
  items: T[],
  operation: (item: T) => Promise<R>,
  concurrency: number = 5
): Promise<R[]> {
  const results: R[] = [];
  const executing: Promise<void>[] = [];

  for (const item of items) {
    const promise = operation(item).then(result => {
      results.push(result);
    });

    executing.push(promise);

    if (executing.length >= concurrency) {
      await Promise.race(executing);
      executing.splice(
        executing.findIndex(p => p === promise),
        1
      );
    }
  }

  await Promise.all(executing);
  return results;
}

// Usage: Fetch multiple issues with concurrency limit
const issueNumbers = [123, 124, 125, 126, 127, 128, 129, 130];

const issues = await batchWithConcurrency(
  issueNumbers,
  async (num) => {
    const { data } = await octokit.issues.get({
      owner: 'org-name',
      repo: 'repo-name',
      issue_number: num
    });
    return data;
  },
  5 // Max 5 concurrent requests
);

console.log(`Fetched ${issues.length} issues`);
```

### 16. Cache with TTL

```typescript
class GitHubCache<T> {
  private cache = new Map<string, { data: T; expiry: number }>();
  private ttl: number;

  constructor(ttlMinutes: number = 5) {
    this.ttl = ttlMinutes * 60 * 1000;
  }

  async get(key: string, fetcher: () => Promise<T>): Promise<T> {
    const cached = this.cache.get(key);

    if (cached && Date.now() < cached.expiry) {
      console.log(`Cache hit: ${key}`);
      return cached.data;
    }

    console.log(`Cache miss: ${key}`);
    const data = await fetcher();

    this.cache.set(key, {
      data,
      expiry: Date.now() + this.ttl
    });

    return data;
  }

  clear() {
    this.cache.clear();
  }
}

// Usage
const cache = new GitHubCache<any>(10); // 10 minute TTL

const repo = await cache.get(
  `repo:org-name/repo-name`,
  () => octokit.repos.get({
    owner: 'org-name',
    repo: 'repo-name'
  }).then(r => r.data)
);
```

### 17. Webhook Event Handler

```typescript
import crypto from 'crypto';

interface WebhookEvent {
  event: string;
  payload: any;
}

class GitHubWebhookHandler {
  private secret: string;

  constructor(secret: string) {
    this.secret = secret;
  }

  verifySignature(payload: string, signature: string): boolean {
    const hmac = crypto.createHmac('sha256', this.secret);
    const digest = 'sha256=' + hmac.update(payload).digest('hex');
    return crypto.timingSafeEqual(
      Buffer.from(signature),
      Buffer.from(digest)
    );
  }

  async handleEvent(event: WebhookEvent) {
    switch (event.event) {
      case 'issues':
        return this.handleIssueEvent(event.payload);
      case 'pull_request':
        return this.handlePREvent(event.payload);
      case 'push':
        return this.handlePushEvent(event.payload);
      default:
        console.log(`Unhandled event: ${event.event}`);
    }
  }

  private async handleIssueEvent(payload: any) {
    const action = payload.action;
    const issue = payload.issue;

    if (action === 'opened') {
      console.log(`New issue opened: #${issue.number}`);
      // Auto-label, auto-assign, etc.
    }
  }

  private async handlePREvent(payload: any) {
    const action = payload.action;
    const pr = payload.pull_request;

    if (action === 'opened') {
      console.log(`New PR opened: #${pr.number}`);
      // Request reviews, run checks, etc.
    }
  }

  private async handlePushEvent(payload: any) {
    const ref = payload.ref;
    const commits = payload.commits.length;

    console.log(`Push to ${ref}: ${commits} commits`);
    // Trigger builds, deployments, etc.
  }
}

// Usage
const handler = new GitHubWebhookHandler(process.env.WEBHOOK_SECRET!);

// In your web server
// const isValid = handler.verifySignature(req.body, req.headers['x-hub-signature-256']);
// await handler.handleEvent({ event: req.headers['x-github-event'], payload: req.body });
```

### 18. Error Handling Wrapper

```typescript
class GitHubAPIError extends Error {
  constructor(
    public status: number,
    public message: string,
    public details?: any
  ) {
    super(message);
    this.name = 'GitHubAPIError';
  }
}

async function safeGitHubRequest<T>(
  operation: () => Promise<T>
): Promise<T> {
  try {
    return await operation();
  } catch (error: any) {
    // Rate limit
    if (error.status === 403 && error.message.includes('rate limit')) {
      const resetTime = new Date(error.response.headers['x-ratelimit-reset'] * 1000);
      throw new GitHubAPIError(
        403,
        `Rate limit exceeded. Resets at ${resetTime.toISOString()}`,
        { resetTime }
      );
    }

    // Not found
    if (error.status === 404) {
      throw new GitHubAPIError(404, 'Resource not found');
    }

    // Validation failed
    if (error.status === 422) {
      throw new GitHubAPIError(
        422,
        'Validation failed',
        error.response?.data?.errors
      );
    }

    // Unauthorized
    if (error.status === 401) {
      throw new GitHubAPIError(401, 'Authentication required or token expired');
    }

    // Forbidden (permissions)
    if (error.status === 403) {
      throw new GitHubAPIError(403, 'Insufficient permissions');
    }

    throw error;
  }
}

// Usage
try {
  const issue = await safeGitHubRequest(() =>
    octokit.issues.get({
      owner: 'org-name',
      repo: 'repo-name',
      issue_number: 123
    })
  );
} catch (error) {
  if (error instanceof GitHubAPIError) {
    console.error(`GitHub API Error [${error.status}]: ${error.message}`);
  } else {
    throw error;
  }
}
```

---

## Best Practices

1. **Always handle rate limits**: Check before bulk operations
2. **Use caching**: Reduce API calls for frequently accessed data
3. **Implement retry logic**: Handle transient failures gracefully
4. **Limit concurrency**: Don't overwhelm the API with parallel requests
5. **Use GraphQL for complex queries**: Reduce number of requests
6. **Validate webhook signatures**: Security best practice
7. **Use fine-grained tokens**: Limit scope to minimum required
8. **Log API usage**: Monitor for debugging and optimization
9. **Handle errors specifically**: Different status codes require different handling
10. **Use TypeScript**: Type safety catches errors at compile time
