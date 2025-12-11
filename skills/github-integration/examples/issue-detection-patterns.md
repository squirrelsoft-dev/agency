# GitHub Issue Detection Patterns

Regex patterns and utility functions for detecting, parsing, and extracting GitHub issues and pull requests from various text formats.

## URL Pattern Detection

### Issue URL Patterns

```typescript
// Complete GitHub issue URL
const GITHUB_ISSUE_URL = /https?:\/\/github\.com\/([^\/]+)\/([^\/]+)\/issues\/(\d+)/g;

// Complete GitHub PR URL
const GITHUB_PR_URL = /https?:\/\/github\.com\/([^\/]+)\/([^\/]+)\/pull\/(\d+)/g;

// Combined pattern
const GITHUB_ISSUE_OR_PR_URL = /https?:\/\/github\.com\/([^\/]+)\/([^\/]+)\/(issues|pull)\/(\d+)/g;

// Usage
function extractGitHubURLs(text: string) {
  const matches = Array.from(text.matchAll(GITHUB_ISSUE_OR_PR_URL));

  return matches.map(match => ({
    url: match[0],
    owner: match[1],
    repo: match[2],
    type: match[3] as 'issues' | 'pull',
    number: parseInt(match[4], 10)
  }));
}

// Example
const text = "See https://github.com/org/repo/issues/123 and https://github.com/org/repo/pull/456";
const urls = extractGitHubURLs(text);
// => [
//   { url: "...", owner: "org", repo: "repo", type: "issues", number: 123 },
//   { url: "...", owner: "org", repo: "repo", type: "pull", number: 456 }
// ]
```

### Short Reference Patterns

```typescript
// #123 pattern (issue/PR number reference)
const SHORT_ISSUE_REF = /#(\d+)/g;

// org/repo#123 pattern (cross-repository reference)
const CROSS_REPO_REF = /([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_-]+)#(\d+)/g;

// GH-123 pattern (alternative notation)
const GH_NOTATION = /GH-(\d+)/gi;

// Usage with matchAll
function extractShortReferences(text: string) {
  const matches = Array.from(text.matchAll(SHORT_ISSUE_REF));

  return matches.map(match => ({
    type: 'short',
    number: parseInt(match[1], 10),
    raw: match[0]
  }));
}

// Example
const text = "Fixes #123 and closes #456";
const refs = extractShortReferences(text);
// => [
//   { type: "short", number: 123, raw: "#123" },
//   { type: "short", number: 456, raw: "#456" }
// ]
```

### Cross-Repository References

```typescript
function extractCrossRepoReferences(text: string) {
  const pattern = /([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_-]+)#(\d+)/g;
  const matches = Array.from(text.matchAll(pattern));

  return matches.map(match => ({
    owner: match[1],
    repo: match[2],
    number: parseInt(match[3], 10),
    raw: match[0]
  }));
}

// Example
const text = "Related to facebook/react#12345 and microsoft/typescript#67890";
const refs = extractCrossRepoReferences(text);
// => [
//   { owner: "facebook", repo: "react", number: 12345, raw: "facebook/react#12345" },
//   { owner: "microsoft", repo: "typescript", number: 67890, raw: "microsoft/typescript#67890" }
// ]
```

---

## Keyword Detection

### Closing Keywords

```typescript
// GitHub automatically closes issues when PR is merged if certain keywords are used
const CLOSING_KEYWORDS = [
  'close', 'closes', 'closed',
  'fix', 'fixes', 'fixed',
  'resolve', 'resolves', 'resolved'
];

const CLOSING_PATTERN = new RegExp(
  `\\b(${CLOSING_KEYWORDS.join('|')})\\s+#(\\d+)`,
  'gi'
);

function extractClosingReferences(text: string) {
  const matches = Array.from(text.matchAll(CLOSING_PATTERN));

  return matches.map(match => ({
    keyword: match[1].toLowerCase(),
    number: parseInt(match[2], 10)
  }));
}

// Example
const text = "Fixes #123 and closes #456, resolves #789";
const closing = extractClosingReferences(text);
// => [
//   { keyword: "fixes", number: 123 },
//   { keyword: "closes", number: 456 },
//   { keyword: "resolves", number: 789 }
// ]
```

### Related/Reference Keywords

```typescript
const REFERENCE_KEYWORDS = [
  'related to', 'relates to',
  'see', 'see also',
  'part of', 'partial',
  'duplicate of', 'dupe of',
  'blocked by', 'blocks',
  'depends on', 'requires'
];

const REFERENCE_PATTERN = new RegExp(
  `\\b(${REFERENCE_KEYWORDS.map(k => k.replace(/\s+/g, '\\s+')).join('|')})\\s+#(\\d+)`,
  'gi'
);

function extractRelatedReferences(text: string) {
  const matches = Array.from(text.matchAll(REFERENCE_PATTERN));

  return matches.map(match => ({
    relationship: match[1].toLowerCase().trim(),
    number: parseInt(match[2], 10)
  }));
}

// Example
const text = "Related to #123, blocked by #456, see also #789";
const related = extractRelatedReferences(text);
```

---

## Comprehensive Detection Function

```typescript
interface GitHubReference {
  type: 'url' | 'short' | 'cross-repo' | 'closing' | 'related';
  owner?: string;
  repo?: string;
  number: number;
  keyword?: string;
  relationship?: string;
  url?: string;
  raw: string;
  position: number;
}

function detectAllGitHubReferences(text: string): GitHubReference[] {
  const references: GitHubReference[] = [];

  // 1. Detect full URLs
  const urlPattern = /https?:\/\/github\.com\/([^\/]+)\/([^\/]+)\/(issues|pull)\/(\d+)/g;
  const urlMatches = Array.from(text.matchAll(urlPattern));

  for (const match of urlMatches) {
    references.push({
      type: 'url',
      owner: match[1],
      repo: match[2],
      number: parseInt(match[4], 10),
      url: match[0],
      raw: match[0],
      position: match.index || 0
    });
  }

  // 2. Detect closing keywords with #number
  const closingPattern = /\b(close|closes|closed|fix|fixes|fixed|resolve|resolves|resolved)\s+#(\d+)/gi;
  const closingMatches = Array.from(text.matchAll(closingPattern));

  for (const match of closingMatches) {
    references.push({
      type: 'closing',
      keyword: match[1].toLowerCase(),
      number: parseInt(match[2], 10),
      raw: match[0],
      position: match.index || 0
    });
  }

  // 3. Detect related keywords with #number
  const relatedPattern = /\b(related to|relates to|see also|part of|blocked by|blocks|depends on)\s+#(\d+)/gi;
  const relatedMatches = Array.from(text.matchAll(relatedPattern));

  for (const match of relatedMatches) {
    references.push({
      type: 'related',
      relationship: match[1].toLowerCase(),
      number: parseInt(match[2], 10),
      raw: match[0],
      position: match.index || 0
    });
  }

  // 4. Detect cross-repo references
  const crossRepoPattern = /([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_-]+)#(\d+)/g;
  const crossRepoMatches = Array.from(text.matchAll(crossRepoPattern));

  for (const match of crossRepoMatches) {
    references.push({
      type: 'cross-repo',
      owner: match[1],
      repo: match[2],
      number: parseInt(match[3], 10),
      raw: match[0],
      position: match.index || 0
    });
  }

  // 5. Detect simple #number references
  const shortPattern = /#(\d+)/g;
  const shortMatches = Array.from(text.matchAll(shortPattern));

  for (const match of shortMatches) {
    const position = match.index || 0;

    // Check if already captured
    const alreadyCaptured = references.some(
      ref => ref.position === position ||
             (ref.position < position && ref.position + ref.raw.length > position)
    );

    if (!alreadyCaptured) {
      references.push({
        type: 'short',
        number: parseInt(match[1], 10),
        raw: match[0],
        position
      });
    }
  }

  // Sort by position
  return references.sort((a, b) => a.position - b.position);
}

// Example usage
const commitMessage = `
feat: Add authentication

Implements authentication using OAuth2.
Fixes #123 and closes #456.
Related to #789.
See also microsoft/typescript#54321.
https://github.com/org/repo/issues/999
`;

const refs = detectAllGitHubReferences(commitMessage);
// Returns all references sorted by position in text
```

---

## Auto-linking Functions

### Convert References to Markdown Links

```typescript
function autoLinkGitHubReferences(
  text: string,
  defaultOwner: string,
  defaultRepo: string
): string {
  let result = text;
  const references = detectAllGitHubReferences(text);

  // Process in reverse order to maintain string positions
  for (let i = references.length - 1; i >= 0; i--) {
    const ref = references[i];
    let link: string;

    if (ref.type === 'url') {
      // Already a URL, convert to markdown link
      link = `[${ref.raw}](${ref.url})`;
    } else if (ref.type === 'cross-repo') {
      link = `[${ref.raw}](https://github.com/${ref.owner}/${ref.repo}/issues/${ref.number})`;
    } else {
      // Use default owner/repo for short references
      link = `[${ref.raw}](https://github.com/${defaultOwner}/${defaultRepo}/issues/${ref.number})`;
    }

    result = result.substring(0, ref.position) +
             link +
             result.substring(ref.position + ref.raw.length);
  }

  return result;
}

// Example
const text = "Fixes #123 and see org/repo#456";
const linked = autoLinkGitHubReferences(text, 'my-org', 'my-repo');
// => "Fixes [#123](https://github.com/my-org/my-repo/issues/123) and see [org/repo#456](https://github.com/org/repo/issues/456)"
```

### Convert References to HTML Links

```typescript
function autoLinkGitHubReferencesHTML(
  text: string,
  defaultOwner: string,
  defaultRepo: string
): string {
  let result = text;
  const references = detectAllGitHubReferences(text);

  // Process in reverse order
  for (let i = references.length - 1; i >= 0; i--) {
    const ref = references[i];
    let url: string;

    if (ref.type === 'url') {
      url = ref.url!;
    } else if (ref.type === 'cross-repo') {
      url = `https://github.com/${ref.owner}/${ref.repo}/issues/${ref.number}`;
    } else {
      url = `https://github.com/${defaultOwner}/${defaultRepo}/issues/${ref.number}`;
    }

    const link = `<a href="${url}" target="_blank" rel="noopener">${ref.raw}</a>`;

    result = result.substring(0, ref.position) +
             link +
             result.substring(ref.position + ref.raw.length);
  }

  return result;
}
```

---

## Validation Functions

### Validate Issue Number

```typescript
function isValidIssueNumber(num: number): boolean {
  return Number.isInteger(num) && num > 0 && num < Number.MAX_SAFE_INTEGER;
}
```

### Validate Repository Name

```typescript
function isValidRepoName(name: string): boolean {
  // GitHub repo names: alphanumeric, hyphen, underscore
  // Max 100 characters
  const pattern = /^[a-zA-Z0-9_-]{1,100}$/;
  return pattern.test(name);
}

function isValidRepoFullName(fullName: string): boolean {
  const parts = fullName.split('/');
  if (parts.length !== 2) return false;

  const [owner, repo] = parts;
  return isValidRepoName(owner) && isValidRepoName(repo);
}
```

### Validate GitHub URL

```typescript
function isValidGitHubURL(url: string): boolean {
  try {
    const parsed = new URL(url);

    if (parsed.hostname !== 'github.com') {
      return false;
    }

    const pattern = /^\/([^\/]+)\/([^\/]+)\/(issues|pull)\/(\d+)$/;
    return pattern.test(parsed.pathname);
  } catch {
    return false;
  }
}
```

---

## Utility Functions

### Extract Issue Numbers

```typescript
function extractIssueNumbers(text: string): number[] {
  const references = detectAllGitHubReferences(text);
  const numbers = references.map(ref => ref.number);

  // Remove duplicates and sort
  return Array.from(new Set(numbers)).sort((a, b) => a - b);
}

// Example
const text = "Fixes #123, closes #456, and #123 again";
const numbers = extractIssueNumbers(text);
// => [123, 456]
```

### Group References by Type

```typescript
function groupReferencesByType(text: string) {
  const references = detectAllGitHubReferences(text);

  return {
    closing: references.filter(r => r.type === 'closing'),
    related: references.filter(r => r.type === 'related'),
    crossRepo: references.filter(r => r.type === 'cross-repo'),
    urls: references.filter(r => r.type === 'url'),
    short: references.filter(r => r.type === 'short')
  };
}
```

### Parse Commit Message

```typescript
interface CommitMetadata {
  type: string;
  scope?: string;
  subject: string;
  body: string;
  closes: number[];
  relates: number[];
  crossRepo: Array<{ owner: string; repo: string; number: number }>;
}

function parseCommitMessage(message: string): CommitMetadata {
  // Parse conventional commit format
  const firstLine = message.split('\n')[0];
  const conventionalCommit = /^(\w+)(?:\(([^)]+)\))?: (.+)$/;
  const match = firstLine.match(conventionalCommit);

  const type = match?.[1] || 'unknown';
  const scope = match?.[2];
  const subject = match?.[3] || firstLine;
  const body = message.split('\n').slice(1).join('\n').trim();

  // Extract references
  const refs = detectAllGitHubReferences(message);

  return {
    type,
    scope,
    subject,
    body,
    closes: refs.filter(r => r.type === 'closing').map(r => r.number),
    relates: refs.filter(r => r.type === 'related').map(r => r.number),
    crossRepo: refs
      .filter(r => r.type === 'cross-repo')
      .map(r => ({
        owner: r.owner!,
        repo: r.repo!,
        number: r.number
      }))
  };
}

// Example
const commit = `
feat(auth): Add OAuth2 support

Implements OAuth2 authentication flow.
Fixes #123
Related to #456
See also facebook/react#789
`;

const metadata = parseCommitMessage(commit);
// => {
//   type: "feat",
//   scope: "auth",
//   subject: "Add OAuth2 support",
//   closes: [123],
//   relates: [456],
//   crossRepo: [{ owner: "facebook", repo: "react", number: 789 }]
// }
```

---

## Best Practices

1. **Always validate extracted numbers**: Check they're positive integers
2. **Handle duplicates**: Use Set to remove duplicate issue numbers
3. **Preserve original text**: When auto-linking, process in reverse order
4. **Case-insensitive keywords**: Use `gi` flags for keyword patterns
5. **Escape special characters**: When building regex from user input
6. **Consider context**: Not all #number patterns are GitHub references
7. **Support cross-repo refs**: Don't assume same repository
8. **Handle URLs with query params**: May have ?... or #... at end
9. **Respect GitHub limits**: Issue numbers are 32-bit integers
10. **Test edge cases**: Empty strings, malformed URLs, etc.
