# ADF Comment Templates

Pre-built Atlassian Document Format (ADF) templates for common Jira comment scenarios. These templates can be used with the Jira API or adapted for your specific needs.

## Basic Templates

### Simple Text Comment

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "This looks good! Approved for merge."
        }
      ]
    }
  ]
}
```

### Multi-Paragraph Comment

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "I've reviewed the implementation and have a few observations:"
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "The core logic looks solid and the tests are comprehensive."
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Please address the minor comments before merging."
        }
      ]
    }
  ]
}
```

---

## Status Update Templates

### Work Started

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "✅ Started working on this issue.",
          "marks": [{ "type": "strong" }]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Estimated completion: End of week"
        }
      ]
    }
  ]
}
```

### Work Completed

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "✅ Implementation complete",
          "marks": [{ "type": "strong" }]
        }
      ]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "All unit tests passing"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Integration tests added"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Documentation updated"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Ready for review."
        }
      ]
    }
  ]
}
```

### Blocked Status

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "panel",
      "attrs": {
        "panelType": "warning"
      },
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "⚠️ Blocked",
              "marks": [{ "type": "strong" }]
            }
          ]
        },
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "Waiting on API changes from backend team. Cannot proceed until PROJ-456 is resolved."
            }
          ]
        }
      ]
    }
  ]
}
```

---

## Review Templates

### Approval with Minor Comments

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "panel",
      "attrs": {
        "panelType": "success"
      },
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "✅ Approved",
              "marks": [{ "type": "strong" }]
            }
          ]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Code looks good overall. A few minor suggestions:"
        }
      ]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Consider adding error handling in the payment flow"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "The variable name could be more descriptive"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "These can be addressed in a follow-up if needed."
        }
      ]
    }
  ]
}
```

### Request Changes

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "panel",
      "attrs": {
        "panelType": "error"
      },
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "❌ Changes Requested",
              "marks": [{ "type": "strong" }]
            }
          ]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "The following issues need to be addressed:"
        }
      ]
    },
    {
      "type": "orderedList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Security: SQL injection vulnerability in user query"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Missing unit tests for error cases"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "API endpoint returns 500 instead of proper error code"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

---

## Technical Templates

### Code Example

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Here's the recommended implementation:"
        }
      ]
    },
    {
      "type": "codeBlock",
      "attrs": {
        "language": "typescript"
      },
      "content": [
        {
          "type": "text",
          "text": "async function fetchUser(id: string) {\n  try {\n    const response = await api.get(`/users/${id}`);\n    return response.data;\n  } catch (error) {\n    console.error('Failed to fetch user:', error);\n    throw error;\n  }\n}"
        }
      ]
    }
  ]
}
```

### Bug Report

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": {
        "level": 2
      },
      "content": [
        {
          "type": "text",
          "text": "Bug Description"
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Login fails when username contains special characters."
        }
      ]
    },
    {
      "type": "heading",
      "attrs": {
        "level": 2
      },
      "content": [
        {
          "type": "text",
          "text": "Steps to Reproduce"
        }
      ]
    },
    {
      "type": "orderedList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Navigate to login page"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Enter username: user@example.com"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Click login"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": {
        "level": 2
      },
      "content": [
        {
          "type": "text",
          "text": "Expected vs Actual"
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Expected:",
          "marks": [{ "type": "strong" }]
        },
        {
          "type": "text",
          "text": " User should be logged in"
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Actual:",
          "marks": [{ "type": "strong" }]
        },
        {
          "type": "text",
          "text": " Error message: \"Invalid username\""
        }
      ]
    }
  ]
}
```

### Test Results

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": {
        "level": 2
      },
      "content": [
        {
          "type": "text",
          "text": "Test Results"
        }
      ]
    },
    {
      "type": "panel",
      "attrs": {
        "panelType": "success"
      },
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "All tests passing ✅"
            }
          ]
        }
      ]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Unit tests: 156/156 passed"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Integration tests: 42/42 passed"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "E2E tests: 18/18 passed"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Coverage: 94%"
        }
      ]
    }
  ]
}
```

---

## Collaboration Templates

### Question

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Quick question about the implementation:"
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Should the API endpoint return a 404 or 400 when the user ID format is invalid?"
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Context: Currently using 404, but some team members suggested 400 would be more accurate."
        }
      ]
    }
  ]
}
```

### Handoff

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": {
        "level": 2
      },
      "content": [
        {
          "type": "text",
          "text": "Handoff Notes"
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Completed work:",
          "marks": [{ "type": "strong" }]
        }
      ]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Authentication flow implemented"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Unit tests added with 95% coverage"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Remaining work:",
          "marks": [{ "type": "strong" }]
        }
      ]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Integration with OAuth provider (needs API keys)"
                }
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Frontend integration testing"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "Notes:",
          "marks": [{ "type": "strong" }]
        }
      ]
    },
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "The OAuth callback URL must be whitelisted in production. See documentation in docs/oauth-setup.md"
        }
      ]
    }
  ]
}
```

---

## TypeScript Helper Function

```typescript
class JiraCommentBuilder {
  private content: any[] = [];

  paragraph(text: string) {
    this.content.push({
      type: 'paragraph',
      content: [{ type: 'text', text }]
    });
    return this;
  }

  heading(level: 1 | 2 | 3, text: string) {
    this.content.push({
      type: 'heading',
      attrs: { level },
      content: [{ type: 'text', text }]
    });
    return this;
  }

  bulletList(items: string[]) {
    this.content.push({
      type: 'bulletList',
      content: items.map(item => ({
        type: 'listItem',
        content: [{
          type: 'paragraph',
          content: [{ type: 'text', text: item }]
        }]
      }))
    });
    return this;
  }

  codeBlock(code: string, language: string = 'typescript') {
    this.content.push({
      type: 'codeBlock',
      attrs: { language },
      content: [{ type: 'text', text: code }]
    });
    return this;
  }

  panel(type: 'info' | 'note' | 'warning' | 'error' | 'success', text: string) {
    this.content.push({
      type: 'panel',
      attrs: { panelType: type },
      content: [{
        type: 'paragraph',
        content: [{ type: 'text', text }]
      }]
    });
    return this;
  }

  link(text: string, href: string) {
    if (this.content.length === 0) {
      this.paragraph('');
    }
    const lastParagraph = this.content[this.content.length - 1];
    if (lastParagraph.type === 'paragraph') {
      lastParagraph.content.push({
        type: 'text',
        text,
        marks: [{ type: 'link', attrs: { href } }]
      });
    }
    return this;
  }

  build() {
    return {
      version: 1,
      type: 'doc',
      content: this.content
    };
  }
}

// Usage
const comment = new JiraCommentBuilder()
  .heading(2, 'Review Complete')
  .paragraph('The implementation looks good!')
  .bulletList([
    'All tests passing',
    'Code follows style guide',
    'Documentation updated'
  ])
  .panel('success', 'Approved for merge ✅')
  .build();

// Post to Jira
await jiraClient.post('/issue/PROJ-123/comment', {
  body: comment
});
```

---

## Best Practices

1. **Use panels for status**: Makes important information stand out
2. **Structure with headings**: Organize long comments
3. **Format code properly**: Use code blocks with language specification
4. **Use lists for clarity**: Bullet or numbered lists improve readability
5. **Add context**: Explain the "why" behind your comments
6. **Link related issues**: Use Jira issue keys that auto-link
7. **Be specific**: Reference line numbers, function names, etc.
8. **Keep it concise**: Long comments can be split or use attachments
9. **Use formatting sparingly**: Bold/italic for emphasis, not decoration
10. **Validate ADF**: Test templates before using in production

---

## Resources

- **ADF Specification**: https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/
- **ADF Builder Libraries**: https://www.npmjs.com/package/@atlaskit/adf-utils
- **Jira Comment API**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-comments/
