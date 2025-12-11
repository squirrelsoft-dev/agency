# Jira API Patterns and Best Practices

Comprehensive guide to Jira's REST API including authentication, common operations, error handling, and performance optimization.

## API Overview

Jira provides two REST API versions:
- **API v2**: Older, more stable, wider compatibility
- **API v3**: Newer, recommended for new integrations

Base URLs:
- Cloud: `https://your-domain.atlassian.net/rest/api/3`
- Server/Data Center: `https://jira.your-company.com/rest/api/2`

---

## Authentication

### API Tokens (Cloud - Recommended)

```typescript
import axios from 'axios';

const jiraClient = axios.create({
  baseURL: 'https://your-domain.atlassian.net/rest/api/3',
  auth: {
    username: 'user@example.com',
    password: 'your-api-token' // Generate at https://id.atlassian.com/manage-profile/security/api-tokens
  },
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }
});
```

### OAuth 2.0 (Advanced)

```typescript
import { OAuth2Client } from '@badgateway/oauth2-client';

const client = new OAuth2Client({
  server: 'https://auth.atlassian.com',
  clientId: 'your-client-id',
  clientSecret: 'your-client-secret',
  tokenEndpoint: '/oauth/token',
  authorizationEndpoint: '/authorize'
});

const token = await client.clientCredentials();

const jiraClient = axios.create({
  baseURL: 'https://api.atlassian.com/ex/jira/your-cloud-id/rest/api/3',
  headers: {
    'Authorization': `Bearer ${token.accessToken}`,
    'Accept': 'application/json'
  }
});
```

---

## Issue Operations

### Get Issue

```typescript
// GET /rest/api/3/issue/{issueIdOrKey}
const response = await jiraClient.get('/issue/PROJ-123');
const issue = response.data;

console.log(issue.key);                    // "PROJ-123"
console.log(issue.fields.summary);          // Issue title
console.log(issue.fields.description);      // ADF content
console.log(issue.fields.status.name);      // "In Progress"
console.log(issue.fields.assignee.displayName);
console.log(issue.fields.priority.name);
console.log(issue.fields.labels);           // Array of strings

// Get specific fields only
const limitedResponse = await jiraClient.get('/issue/PROJ-123', {
  params: {
    fields: 'summary,status,assignee'
  }
});
```

### Search Issues (JQL)

```typescript
// POST /rest/api/3/search
const searchResponse = await jiraClient.post('/search', {
  jql: 'project = PROJ AND status = "To Do"',
  startAt: 0,
  maxResults: 50,
  fields: ['summary', 'status', 'assignee', 'created']
});

const issues = searchResponse.data.issues;
const total = searchResponse.data.total;

console.log(`Found ${total} issues, showing ${issues.length}`);
```

### Create Issue

```typescript
// POST /rest/api/3/issue
const newIssue = await jiraClient.post('/issue', {
  fields: {
    project: {
      key: 'PROJ'
    },
    summary: 'Implement authentication',
    description: {
      type: 'doc',
      version: 1,
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'Add OAuth2 authentication flow'
            }
          ]
        }
      ]
    },
    issuetype: {
      name: 'Story'
    },
    priority: {
      name: 'High'
    },
    labels: ['backend', 'security'],
    components: [
      { name: 'API' }
    ]
  }
});

console.log(`Created: ${newIssue.data.key}`);
```

### Update Issue

```typescript
// PUT /rest/api/3/issue/{issueIdOrKey}
await jiraClient.put('/issue/PROJ-123', {
  fields: {
    summary: 'Updated summary',
    description: {
      type: 'doc',
      version: 1,
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'Updated description'
            }
          ]
        }
      ]
    },
    labels: ['bug', 'urgent']
  }
});
```

### Transition Issue

```typescript
// Get available transitions
const transitionsResp = await jiraClient.get('/issue/PROJ-123/transitions');
const transitions = transitionsResp.data.transitions;

console.log('Available transitions:');
transitions.forEach((t: any) => console.log(`${t.id}: ${t.name}`));

// Execute transition
const transitionId = transitions.find((t: any) => t.name === 'In Progress')?.id;

await jiraClient.post('/issue/PROJ-123/transitions', {
  transition: {
    id: transitionId
  },
  fields: {
    resolution: {
      name: 'Fixed'
    }
  }
});
```

### Assign Issue

```typescript
// PUT /rest/api/3/issue/{issueIdOrKey}/assignee
await jiraClient.put('/issue/PROJ-123/assignee', {
  accountId: '5b10a2844c20165700ede21g'  // User's account ID
});

// Get account ID from email
const userSearch = await jiraClient.get('/user/search', {
  params: {
    query: 'john.doe@example.com'
  }
});
const accountId = userSearch.data[0].accountId;
```

---

## Comments

### Add Comment

```typescript
// POST /rest/api/3/issue/{issueIdOrKey}/comment
await jiraClient.post('/issue/PROJ-123/comment', {
  body: {
    type: 'doc',
    version: 1,
    content: [
      {
        type: 'paragraph',
        content: [
          {
            type: 'text',
            text: 'This issue has been reviewed'
          }
        ]
      }
    ]
  }
});
```

### Get Comments

```typescript
// GET /rest/api/3/issue/{issueIdOrKey}/comment
const commentsResp = await jiraClient.get('/issue/PROJ-123/comment');
const comments = commentsResp.data.comments;

comments.forEach((comment: any) => {
  console.log(`${comment.author.displayName}: ${comment.body.content[0].content[0].text}`);
});
```

### Update Comment

```typescript
// PUT /rest/api/3/issue/{issueIdOrKey}/comment/{id}
await jiraClient.put(`/issue/PROJ-123/comment/${commentId}`, {
  body: {
    type: 'doc',
    version: 1,
    content: [
      {
        type: 'paragraph',
        content: [
          {
            type: 'text',
            text: 'Updated comment text'
          }
        ]
      }
    ]
  }
});
```

---

## Attachments

### Add Attachment

```typescript
import FormData from 'form-data';
import fs from 'fs';

// POST /rest/api/3/issue/{issueIdOrKey}/attachments
const form = new FormData();
form.append('file', fs.createReadStream('screenshot.png'));

await jiraClient.post('/issue/PROJ-123/attachments', form, {
  headers: {
    ...form.getHeaders(),
    'X-Atlassian-Token': 'no-check'
  }
});
```

### Get Attachments

```typescript
const issue = await jiraClient.get('/issue/PROJ-123');
const attachments = issue.data.fields.attachment;

attachments.forEach((att: any) => {
  console.log(`${att.filename}: ${att.content}`);
});
```

---

## Issue Links

### Create Issue Link

```typescript
// POST /rest/api/3/issueLink
await jiraClient.post('/issueLink', {
  type: {
    name: 'Blocks'  // or 'Relates', 'Duplicates', etc.
  },
  inwardIssue: {
    key: 'PROJ-123'
  },
  outwardIssue: {
    key: 'PROJ-456'
  },
  comment: {
    body: {
      type: 'doc',
      version: 1,
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'These issues are related'
            }
          ]
        }
      ]
    }
  }
});
```

### Get Issue Links

```typescript
const issue = await jiraClient.get('/issue/PROJ-123');
const issueLinks = issue.data.fields.issuelinks;

issueLinks.forEach((link: any) => {
  if (link.outwardIssue) {
    console.log(`${link.type.outward}: ${link.outwardIssue.key}`);
  } else if (link.inwardIssue) {
    console.log(`${link.type.inward}: ${link.inwardIssue.key}`);
  }
});
```

---

## Projects

### Get Project

```typescript
// GET /rest/api/3/project/{projectIdOrKey}
const project = await jiraClient.get('/project/PROJ');

console.log(project.data.name);
console.log(project.data.lead.displayName);
console.log(project.data.description);
```

### List Projects

```typescript
// GET /rest/api/3/project/search
const projects = await jiraClient.get('/project/search');

projects.data.values.forEach((proj: any) => {
  console.log(`${proj.key}: ${proj.name}`);
});
```

---

## Sprints (Agile APIs)

### Get Sprint

```typescript
// GET /rest/agile/1.0/sprint/{sprintId}
const sprint = await axios.get(`https://your-domain.atlassian.net/rest/agile/1.0/sprint/123`);

console.log(sprint.data.name);
console.log(sprint.data.state);  // 'active', 'closed', 'future'
console.log(sprint.data.startDate);
console.log(sprint.data.endDate);
```

### Get Sprint Issues

```typescript
// GET /rest/agile/1.0/sprint/{sprintId}/issue
const issues = await axios.get(`https://your-domain.atlassian.net/rest/agile/1.0/sprint/123/issue`);

issues.data.issues.forEach((issue: any) => {
  console.log(`${issue.key}: ${issue.fields.summary}`);
});
```

### Move Issues to Sprint

```typescript
// POST /rest/agile/1.0/sprint/{sprintId}/issue
await axios.post(`https://your-domain.atlassian.net/rest/agile/1.0/sprint/123/issue`, {
  issues: ['PROJ-123', 'PROJ-124', 'PROJ-125']
});
```

---

## Boards

### Get Board

```typescript
// GET /rest/agile/1.0/board/{boardId}
const board = await axios.get(`https://your-domain.atlassian.net/rest/agile/1.0/board/1`);

console.log(board.data.name);
console.log(board.data.type);  // 'scrum' or 'kanban'
```

### Get Board Issues

```typescript
// GET /rest/agile/1.0/board/{boardId}/issue
const issues = await axios.get(`https://your-domain.atlassian.net/rest/agile/1.0/board/1/issue`, {
  params: {
    jql: 'status = "To Do"',
    maxResults: 50
  }
});
```

---

## Pagination

### Standard Pagination

```typescript
async function fetchAllIssues(jql: string) {
  const issues = [];
  let startAt = 0;
  const maxResults = 100;
  let total = 0;

  do {
    const response = await jiraClient.post('/search', {
      jql,
      startAt,
      maxResults,
      fields: ['summary', 'status']
    });

    issues.push(...response.data.issues);
    total = response.data.total;
    startAt += maxResults;

  } while (startAt < total);

  return issues;
}

// Usage
const allIssues = await fetchAllIssues('project = PROJ');
```

---

## Error Handling

```typescript
async function safeJiraRequest<T>(request: () => Promise<T>): Promise<T | null> {
  try {
    return await request();
  } catch (error: any) {
    const status = error.response?.status;
    const data = error.response?.data;

    // 400 - Bad Request
    if (status === 400) {
      console.error('Bad Request:', data.errorMessages);
      return null;
    }

    // 401 - Unauthorized
    if (status === 401) {
      throw new Error('Authentication failed. Check credentials.');
    }

    // 403 - Forbidden
    if (status === 403) {
      throw new Error('Insufficient permissions');
    }

    // 404 - Not Found
    if (status === 404) {
      console.error('Resource not found');
      return null;
    }

    // 429 - Rate Limit
    if (status === 429) {
      const retryAfter = error.response.headers['retry-after'];
      throw new Error(`Rate limited. Retry after ${retryAfter} seconds`);
    }

    throw error;
  }
}

// Usage
const issue = await safeJiraRequest(() =>
  jiraClient.get('/issue/PROJ-123')
);
```

---

## Rate Limiting

```typescript
class JiraRateLimiter {
  private queue: Array<() => Promise<any>> = [];
  private processing = false;
  private requestsPerSecond = 10;
  private delay = 1000 / this.requestsPerSecond;

  async add<T>(request: () => Promise<T>): Promise<T> {
    return new Promise((resolve, reject) => {
      this.queue.push(async () => {
        try {
          const result = await request();
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });

      this.process();
    });
  }

  private async process() {
    if (this.processing || this.queue.length === 0) {
      return;
    }

    this.processing = true;

    while (this.queue.length > 0) {
      const request = this.queue.shift()!;
      await request();
      await new Promise(resolve => setTimeout(resolve, this.delay));
    }

    this.processing = false;
  }
}

// Usage
const rateLimiter = new JiraRateLimiter();

const issue = await rateLimiter.add(() =>
  jiraClient.get('/issue/PROJ-123')
);
```

---

## Caching Strategy

```typescript
class JiraCache {
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

  clear() {
    this.cache.clear();
  }
}

// Usage
const cache = new JiraCache();

const project = await cache.get(
  'project:PROJ',
  () => jiraClient.get('/project/PROJ').then(r => r.data)
);
```

---

## Best Practices

1. **Use API tokens**: Never use passwords for authentication
2. **Implement rate limiting**: Respect Jira's 10 requests/second limit
3. **Cache project metadata**: Reduce API calls for rarely-changing data
4. **Use JQL for filtering**: More efficient than client-side filtering
5. **Request only needed fields**: Use `fields` parameter to reduce payload
6. **Handle pagination**: Don't fetch all results at once
7. **Implement retry logic**: Handle transient failures gracefully
8. **Use bulk operations**: When available (e.g., bulk issue creation)
9. **Monitor API usage**: Track requests to avoid hitting limits
10. **Use webhooks**: For real-time updates instead of polling

---

## Resources

- **Jira Cloud REST API**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
- **Jira Agile REST API**: https://developer.atlassian.com/cloud/jira/software/rest/
- **API Tokens**: https://id.atlassian.com/manage-profile/security/api-tokens
- **Atlassian Document Format (ADF)**: https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/
- **Rate Limits**: https://developer.atlassian.com/cloud/jira/platform/rate-limiting/
