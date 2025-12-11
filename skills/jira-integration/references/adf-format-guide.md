# Atlassian Document Format (ADF) Complete Guide

Comprehensive guide to ADF (Atlassian Document Format), the JSON-based rich text format used for Jira issue descriptions, comments, and Confluence pages.

## Overview

ADF is a structured JSON format that represents rich text content. It's used across Atlassian products for descriptions, comments, and documents.

### Basic Structure

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
          "text": "Hello, world!"
        }
      ]
    }
  ]
}
```

**Key components**:
- `version`: ADF schema version (always 1)
- `type`: Node type (`doc` for root)
- `content`: Array of child nodes

---

## Text Nodes

### Plain Text

```json
{
  "type": "paragraph",
  "content": [
    {
      "type": "text",
      "text": "This is plain text"
    }
  ]
}
```

### Text with Marks (Formatting)

**Bold**:
```json
{
  "type": "text",
  "text": "Bold text",
  "marks": [{ "type": "strong" }]
}
```

**Italic**:
```json
{
  "type": "text",
  "text": "Italic text",
  "marks": [{ "type": "em" }]
}
```

**Underline**:
```json
{
  "type": "text",
  "text": "Underlined text",
  "marks": [{ "type": "underline" }]
}
```

**Strikethrough**:
```json
{
  "type": "text",
  "text": "Strikethrough text",
  "marks": [{ "type": "strike" }]
}
```

**Inline Code**:
```json
{
  "type": "text",
  "text": "code()",
  "marks": [{ "type": "code" }]
}
```

**Multiple Marks**:
```json
{
  "type": "text",
  "text": "Bold and italic",
  "marks": [
    { "type": "strong" },
    { "type": "em" }
  ]
}
```

---

## Links

### Basic Link

```json
{
  "type": "text",
  "text": "Click here",
  "marks": [
    {
      "type": "link",
      "attrs": {
        "href": "https://example.com"
      }
    }
  ]
}
```

### Link with Title

```json
{
  "type": "text",
  "text": "Example Site",
  "marks": [
    {
      "type": "link",
      "attrs": {
        "href": "https://example.com",
        "title": "Visit Example Site"
      }
    }
  ]
}
```

### Link with Formatting

```json
{
  "type": "text",
  "text": "Bold link",
  "marks": [
    { "type": "strong" },
    {
      "type": "link",
      "attrs": {
        "href": "https://example.com"
      }
    }
  ]
}
```

---

## Headings

```json
{
  "type": "heading",
  "attrs": {
    "level": 1  // 1-6 for h1-h6
  },
  "content": [
    {
      "type": "text",
      "text": "Heading Text"
    }
  ]
}
```

**Examples**:
```json
// H1
{ "type": "heading", "attrs": { "level": 1 }, "content": [...] }

// H2
{ "type": "heading", "attrs": { "level": 2 }, "content": [...] }

// H3
{ "type": "heading", "attrs": { "level": 3 }, "content": [...] }
```

---

## Lists

### Bullet List

```json
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
              "text": "First item"
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
              "text": "Second item"
            }
          ]
        }
      ]
    }
  ]
}
```

### Ordered List

```json
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
              "text": "First item"
            }
          ]
        }
      ]
    }
  ]
}
```

### Nested Lists

```json
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
              "text": "Parent item"
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
                      "text": "Nested item"
                    }
                  ]
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

## Code Blocks

```json
{
  "type": "codeBlock",
  "attrs": {
    "language": "typescript"
  },
  "content": [
    {
      "type": "text",
      "text": "function hello() {\n  console.log('Hello');\n}"
    }
  ]
}
```

**Supported languages**:
- `typescript`, `javascript`, `python`, `java`, `go`, `rust`, `c`, `cpp`, `csharp`, `php`, `ruby`, `swift`, `kotlin`, `sql`, `bash`, `shell`, `json`, `xml`, `yaml`, `markdown`, `css`, `html`

---

## Block Quotes

```json
{
  "type": "blockquote",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "This is a quote"
        }
      ]
    }
  ]
}
```

---

## Panels (Info, Note, Warning, Error)

```json
{
  "type": "panel",
  "attrs": {
    "panelType": "info"  // info, note, warning, error, success
  },
  "content": [
    {
      "type": "paragraph",
      "content": [
        {
          "type": "text",
          "text": "This is an info panel"
        }
      ]
    }
  ]
}
```

---

## Tables

```json
{
  "type": "table",
  "content": [
    {
      "type": "tableRow",
      "content": [
        {
          "type": "tableHeader",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Header 1"
                }
              ]
            }
          ]
        },
        {
          "type": "tableHeader",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Header 2"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "tableRow",
      "content": [
        {
          "type": "tableCell",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Cell 1"
                }
              ]
            }
          ]
        },
        {
          "type": "tableCell",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {
                  "type": "text",
                  "text": "Cell 2"
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

## Mentions

### User Mention

```json
{
  "type": "mention",
  "attrs": {
    "id": "5b10a2844c20165700ede21g",  // User's account ID
    "text": "@John Doe",
    "accessLevel": ""
  }
}
```

---

## Emojis

```json
{
  "type": "emoji",
  "attrs": {
    "shortName": ":smile:",
    "id": "1f604",
    "text": "😄"
  }
}
```

**Common emojis**:
- `:smile:` 😄
- `:thumbsup:` 👍
- `:check:` ✅
- `:warning:` ⚠️
- `:x:` ❌

---

## Media (Images, Attachments)

```json
{
  "type": "mediaSingle",
  "content": [
    {
      "type": "media",
      "attrs": {
        "type": "file",
        "id": "attachment-id",
        "collection": "jira-issues",
        "width": 800,
        "height": 600
      }
    }
  ]
}
```

---

## Helper Functions (TypeScript)

### Create Paragraph

```typescript
function createParagraph(text: string) {
  return {
    type: 'paragraph',
    content: [
      {
        type: 'text',
        text
      }
    ]
  };
}
```

### Create Formatted Text

```typescript
function createFormattedText(text: string, marks: string[]) {
  return {
    type: 'text',
    text,
    marks: marks.map(mark => ({ type: mark }))
  };
}

// Usage
const boldItalicText = createFormattedText('Bold and italic', ['strong', 'em']);
```

### Create Link

```typescript
function createLink(text: string, href: string) {
  return {
    type: 'text',
    text,
    marks: [
      {
        type: 'link',
        attrs: { href }
      }
    ]
  };
}
```

### Create Heading

```typescript
function createHeading(level: 1 | 2 | 3 | 4 | 5 | 6, text: string) {
  return {
    type: 'heading',
    attrs: { level },
    content: [
      {
        type: 'text',
        text
      }
    ]
  };
}
```

### Create Bullet List

```typescript
function createBulletList(items: string[]) {
  return {
    type: 'bulletList',
    content: items.map(item => ({
      type: 'listItem',
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: item
            }
          ]
        }
      ]
    }))
  };
}

// Usage
const list = createBulletList(['Item 1', 'Item 2', 'Item 3']);
```

### Create Code Block

```typescript
function createCodeBlock(code: string, language: string = 'typescript') {
  return {
    type: 'codeBlock',
    attrs: { language },
    content: [
      {
        type: 'text',
        text: code
      }
    ]
  };
}
```

### Create ADF Document

```typescript
function createADFDocument(...nodes: any[]) {
  return {
    version: 1,
    type: 'doc',
    content: nodes
  };
}

// Usage
const doc = createADFDocument(
  createHeading(1, 'Title'),
  createParagraph('Introduction'),
  createBulletList(['Point 1', 'Point 2']),
  createCodeBlock('console.log("Hello");', 'javascript')
);
```

---

## Complete ADF Builder Class

```typescript
class ADFBuilder {
  private content: any[] = [];

  paragraph(text: string) {
    this.content.push(createParagraph(text));
    return this;
  }

  heading(level: 1 | 2 | 3 | 4 | 5 | 6, text: string) {
    this.content.push(createHeading(level, text));
    return this;
  }

  bulletList(items: string[]) {
    this.content.push(createBulletList(items));
    return this;
  }

  codeBlock(code: string, language: string = 'typescript') {
    this.content.push(createCodeBlock(code, language));
    return this;
  }

  panel(type: 'info' | 'note' | 'warning' | 'error', text: string) {
    this.content.push({
      type: 'panel',
      attrs: { panelType: type },
      content: [createParagraph(text)]
    });
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
const doc = new ADFBuilder()
  .heading(1, 'Release Notes')
  .paragraph('Version 1.0.0 includes:')
  .bulletList([
    'New authentication system',
    'Performance improvements',
    'Bug fixes'
  ])
  .panel('info', 'Please restart the application after upgrade')
  .build();
```

---

## Markdown to ADF Conversion

```typescript
function markdownToADF(markdown: string) {
  const lines = markdown.split('\n');
  const content: any[] = [];

  for (const line of lines) {
    // Headings
    if (line.startsWith('# ')) {
      content.push(createHeading(1, line.slice(2)));
    } else if (line.startsWith('## ')) {
      content.push(createHeading(2, line.slice(3)));
    } else if (line.startsWith('### ')) {
      content.push(createHeading(3, line.slice(4)));
    }
    // Bullet list
    else if (line.startsWith('- ') || line.startsWith('* ')) {
      // Simplified - full implementation would handle multi-line lists
      content.push(createBulletList([line.slice(2)]));
    }
    // Paragraph
    else if (line.trim()) {
      content.push(createParagraph(line));
    }
  }

  return createADFDocument(...content);
}
```

---

## ADF to Markdown Conversion

```typescript
function adfToMarkdown(adf: any): string {
  if (!adf.content) return '';

  return adf.content.map((node: any) => {
    switch (node.type) {
      case 'paragraph':
        return textNodesToMarkdown(node.content) + '\n';

      case 'heading':
        const level = '#'.repeat(node.attrs.level);
        return `${level} ${textNodesToMarkdown(node.content)}\n`;

      case 'bulletList':
        return node.content.map((item: any) =>
          `- ${textNodesToMarkdown(item.content[0].content)}`
        ).join('\n') + '\n';

      case 'codeBlock':
        const lang = node.attrs.language || '';
        const code = node.content[0].text;
        return `\`\`\`${lang}\n${code}\n\`\`\`\n`;

      default:
        return '';
    }
  }).join('\n');
}

function textNodesToMarkdown(nodes: any[]): string {
  if (!nodes) return '';

  return nodes.map((node: any) => {
    if (node.type !== 'text') return '';

    let text = node.text;

    if (node.marks) {
      node.marks.forEach((mark: any) => {
        switch (mark.type) {
          case 'strong':
            text = `**${text}**`;
            break;
          case 'em':
            text = `*${text}*`;
            break;
          case 'code':
            text = `\`${text}\``;
            break;
          case 'link':
            text = `[${text}](${mark.attrs.href})`;
            break;
        }
      });
    }

    return text;
  }).join('');
}
```

---

## Validation

```typescript
function validateADF(adf: any): boolean {
  // Basic validation
  if (!adf || typeof adf !== 'object') return false;
  if (adf.version !== 1) return false;
  if (adf.type !== 'doc') return false;
  if (!Array.isArray(adf.content)) return false;

  // Validate each node
  for (const node of adf.content) {
    if (!node.type) return false;
    if (node.content && !Array.isArray(node.content)) return false;
  }

  return true;
}
```

---

## Best Practices

1. **Always include version**: Set `version: 1` in root document
2. **Nest properly**: Paragraphs inside list items, text inside paragraphs
3. **Use appropriate marks**: Combine marks for complex formatting
4. **Validate structure**: Check ADF structure before sending to API
5. **Handle special characters**: Escape if needed (though usually handled)
6. **Keep it simple**: Use basic nodes when possible
7. **Test rendering**: Verify ADF renders correctly in Jira
8. **Use builder patterns**: Create helper functions for common structures
9. **Consider markdown**: Convert from markdown for easier authoring
10. **Cache templates**: Reuse common ADF patterns

---

## Resources

- **ADF Specification**: https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/
- **ADF Builder**: https://www.npmjs.com/package/@atlaskit/adf-utils
- **ADF Validator**: https://www.npmjs.com/package/@atlaskit/editor-json-transformer
- **Markdown to ADF**: https://www.npmjs.com/package/@atlaskit/editor-markdown-transformer
