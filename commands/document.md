---
description: Generate comprehensive documentation for APIs, architecture, components, or features
argument-hint: topic (api/architecture/component/feature/code/auto)
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion]
---

# Generate Documentation: $ARGUMENTS

Generate comprehensive, accurate documentation with examples and validation.

## Your Mission

Generate documentation for: **$ARGUMENTS**

Follow the documentation lifecycle: detect scope → generate content → review quality → validate examples → publish.

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and workflow strategies you MUST follow.

---

## Phase 0: Project Context Detection (1-2 min)

Quickly gather project context to determine documentation approach and templates.

### Detect Framework/Language

```bash
# Detect JavaScript/TypeScript frameworks
if [ -f "next.config.js" ] || [ -f "next.config.ts" ]; then
  FRAMEWORK="Next.js"
  # Read package.json to get version
  Read package.json

  # Check for App Router vs Pages Router
  if [ -d "app" ]; then
    ROUTER="App Router"
  else
    ROUTER="Pages Router"
  fi
fi

if [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
  FRAMEWORK="React + Vite"
fi

# Check for Python frameworks
if [ -f "manage.py" ]; then
  FRAMEWORK="Django"
fi

if [ -f "app.py" ] || [ -f "main.py" ]; then
  if grep -q "fastapi" requirements.txt 2>/dev/null; then
    FRAMEWORK="FastAPI"
  elif grep -q "flask" requirements.txt 2>/dev/null; then
    FRAMEWORK="Flask"
  fi
fi

# Check for other frameworks
if [ -f "composer.json" ]; then
  if grep -q "laravel" composer.json; then
    FRAMEWORK="Laravel"
  fi
fi
```

### Detect Documentation System

```bash
# Check for existing documentation setup
if [ -d "docs" ]; then
  DOC_DIR="docs"

  # Check for documentation generators
  if [ -f "mkdocs.yml" ]; then
    DOC_SYSTEM="MkDocs"
  elif [ -f "docusaurus.config.js" ]; then
    DOC_SYSTEM="Docusaurus"
  elif [ -f ".vitepress/config.js" ] || [ -f ".vitepress/config.ts" ]; then
    DOC_SYSTEM="VitePress"
  elif [ -f "sphinx-build" ] || [ -f "conf.py" ]; then
    DOC_SYSTEM="Sphinx"
  else
    DOC_SYSTEM="Markdown (no generator)"
  fi
else
  DOC_DIR="docs" # Will create
  DOC_SYSTEM="Markdown (no generator)"
fi

# Check for API documentation tools
if grep -q "swagger" package.json 2>/dev/null || grep -q "openapi" package.json 2>/dev/null; then
  API_DOC_SYSTEM="OpenAPI/Swagger"
fi

if [ -d ".storybook" ]; then
  COMPONENT_DOC_SYSTEM="Storybook"
fi
```

### Detect Project Type

```bash
# Determine if this is a library, application, or API
if [ -f "package.json" ]; then
  if grep -q '"main":' package.json || grep -q '"exports":' package.json; then
    PROJECT_TYPE="Library/Package"
  else
    PROJECT_TYPE="Application"
  fi
fi

# Check for API patterns
if [ -d "api" ] || [ -d "routes" ] || [ -d "endpoints" ]; then
  HAS_API="Yes"
fi

# Check for component library
if [ -d "components" ] && [ -d ".storybook" ]; then
  PROJECT_TYPE="Component Library"
fi
```

**Use this context to**:
- Select appropriate documentation templates
- Choose correct documentation format (Markdown, OpenAPI, JSDoc, etc.)
- Determine documentation structure
- Select specialist agents for generation

---

## Phase 1: Documentation Scope Detection (2-3 min)

### Parse Topic Argument

Analyze `$ARGUMENTS` to determine documentation type:

**API Documentation** if:
- `$ARGUMENTS` = "api" or "endpoints" or "rest" or "graphql"
- Related keywords: "routes", "openapi", "swagger"

**Architecture Documentation** if:
- `$ARGUMENTS` = "architecture" or "adr" or "design" or "decisions"
- Related keywords: "system-design", "technical-decisions"

**Component Documentation** if:
- `$ARGUMENTS` = "component" or "components" or "ui"
- Specific component name (e.g., "Button", "Modal")
- Related keywords: "props", "storybook"

**Feature Documentation** if:
- `$ARGUMENTS` = "feature" or specific feature name
- Related keywords: "user-guide", "how-to", "tutorial"

**Code Documentation** if:
- `$ARGUMENTS` = "code" or "jsdoc" or "typedoc" or "inline"
- Related keywords: "docstrings", "comments", "annotations"

**Auto-Detect** if:
- `$ARGUMENTS` = "auto" or empty
- Analyze project and determine most needed docs

### Analyze Scope

#### For API Documentation

```bash
# Find API routes/endpoints
if [ -d "app/api" ]; then
  # Next.js App Router API routes
  find app/api -name "route.ts" -o -name "route.js" > .agency/documentation/api-routes.txt
elif [ -d "pages/api" ]; then
  # Next.js Pages Router API routes
  find pages/api -name "*.ts" -o -name "*.js" > .agency/documentation/api-routes.txt
elif [ -d "routes" ]; then
  # Express/Flask routes
  find routes -name "*.ts" -o -name "*.js" -o -name "*.py" > .agency/documentation/api-routes.txt
fi

# Count endpoints
ENDPOINT_COUNT=$(wc -l < .agency/documentation/api-routes.txt)
echo "Found $ENDPOINT_COUNT API endpoint files"
```

#### For Architecture Documentation

```bash
# Check for existing ADRs
if [ -d "docs/adr" ] || [ -d "docs/architecture" ]; then
  echo "Existing architecture docs found"
  ls -1 docs/adr/ 2>/dev/null || ls -1 docs/architecture/ 2>/dev/null
fi

# Identify key architectural decisions to document
# - Database choice
# - Authentication strategy
# - State management
# - API design
# - Deployment architecture
```

#### For Component Documentation

```bash
# Find components
if [ -d "components" ]; then
  find components -name "*.tsx" -o -name "*.jsx" > .agency/documentation/components.txt
  COMPONENT_COUNT=$(wc -l < .agency/documentation/components.txt)
  echo "Found $COMPONENT_COUNT component files"
fi

# Check if specific component requested
if [[ "$ARGUMENTS" =~ ^[A-Z][a-zA-Z]+ ]]; then
  # Looks like a component name (starts with capital letter)
  COMPONENT_NAME="$ARGUMENTS"
  echo "Documenting specific component: $COMPONENT_NAME"
fi
```

#### For Feature Documentation

```bash
# Identify features to document
# Check for feature directories
if [ -d "features" ]; then
  ls -1 features/ > .agency/documentation/features.txt
fi

# Or check for feature flags/config
if [ -f "features.config.js" ] || [ -f "feature-flags.json" ]; then
  echo "Found feature configuration"
fi
```

#### For Code Documentation

```bash
# Find files missing documentation
# For TypeScript/JavaScript
if [ -f "tsconfig.json" ]; then
  # Find exported functions/classes without JSDoc
  grep -r "export " --include="*.ts" --include="*.tsx" src/ | wc -l
fi

# For Python
if [ -f "requirements.txt" ]; then
  # Find functions without docstrings
  grep -r "^def " --include="*.py" . | wc -l
fi
```

### Create Todo List for Documentation

Use TodoWrite to create tracking for documentation phases:

```
1. Detect documentation scope
2. Generate documentation content
3. Review documentation quality
4. Validate code examples
5. Publish documentation
```

### Get User Confirmation

If scope is auto-detected or ambiguous, use AskUserQuestion to confirm:

```
Question: "What type of documentation should I generate?"
Options:
  - "API Documentation (endpoints, request/response, examples)"
  - "Architecture Documentation (ADR, system design, decisions)"
  - "Component Documentation (props, usage, examples, Storybook)"
  - "Feature Documentation (user guide, how-to, configuration)"
  - "Code Documentation (JSDoc/TypeDoc inline comments)"
```

If specific scope detected, confirm:

```
Question: "Generate [TYPE] documentation for [SCOPE]?"
Options:
  - "Yes, proceed"
  - "Change scope or type"
```

Mark todo #1 as completed.

---

## Phase 2: Documentation Generation (1-4 hours)

Mark todo #2 as in_progress.

### Create Documentation Directory Structure

```bash
# Create base documentation directory if doesn't exist
mkdir -p $DOC_DIR

# Create subdirectories based on documentation type
case "$DOC_TYPE" in
  "api")
    mkdir -p $DOC_DIR/api
    mkdir -p $DOC_DIR/api/endpoints
    mkdir -p $DOC_DIR/api/examples
    ;;
  "architecture")
    mkdir -p $DOC_DIR/architecture
    mkdir -p $DOC_DIR/architecture/decisions
    mkdir -p $DOC_DIR/architecture/diagrams
    ;;
  "component")
    mkdir -p $DOC_DIR/components
    mkdir -p $DOC_DIR/components/examples
    ;;
  "feature")
    mkdir -p $DOC_DIR/features
    mkdir -p $DOC_DIR/guides
    ;;
  "code")
    # Code documentation is inline
    ;;
esac
```

### Select Documentation Specialist

Based on documentation type, spawn the appropriate specialist:

| Documentation Type | Specialist Agent |
|--------------------|------------------|
| **API** | Backend Architect or senior-developer |
| **Architecture** | Backend Architect or ArchitectUX |
| **Component** | Frontend Developer or UI Designer |
| **Feature** | Content Creator or Senior Developer |
| **Code** | Senior Developer |

### Generate Documentation Content

#### API Documentation Generation

Spawn specialist agent:

```
Task: Generate API documentation

Agent: Backend Architect

Context:
- Framework: [detected framework]
- API endpoints: [count] endpoints in [directories]
- Documentation format: [OpenAPI/Markdown]

Instructions:
1. Analyze all API endpoints in the codebase
2. For each endpoint, document:
   - **Method & Path**: GET /api/users/:id
   - **Description**: What this endpoint does
   - **Authentication**: Required auth (API key, JWT, OAuth)
   - **Request Parameters**:
     - Path parameters
     - Query parameters
     - Request body (with schema)
   - **Response**:
     - Success response (200, 201, etc.) with schema
     - Error responses (400, 401, 404, 500) with examples
   - **Rate Limiting**: If applicable
   - **Examples**:
     - cURL example
     - JavaScript/TypeScript fetch example
     - Python requests example
3. Group endpoints by resource (users, posts, auth, etc.)
4. Generate in [OpenAPI 3.0 / Markdown] format
5. Include authentication overview
6. Include error code reference

Use this template structure:

# API Documentation

## Overview
[Brief description of the API]

## Base URL
```
[production/staging URLs]
```

## Authentication
[How to authenticate requests]

## Endpoints

### Users

#### GET /api/users
[Full endpoint documentation]

#### POST /api/users
[Full endpoint documentation]

[... more endpoints ...]

## Error Codes
[Standard error responses]

## Rate Limiting
[Rate limit details]

Save documentation to $DOC_DIR/api/README.md and individual endpoints to $DOC_DIR/api/endpoints/
```

**Wait for specialist to complete API documentation.**

#### Architecture Documentation Generation (ADR)

Spawn specialist agent:

```
Task: Generate Architecture Decision Record (ADR)

Agent: Backend Architect

Context:
- Project: [framework and type]
- Decision to document: [database choice / auth strategy / deployment / etc.]

Instructions:
1. Create an ADR following this template:

# ADR-[NUMBER]: [Title of Decision]

**Date**: [YYYY-MM-DD]
**Status**: [Proposed / Accepted / Deprecated / Superseded]
**Deciders**: [List of people involved]

## Context

[Describe the context and problem statement]
- What forces are at play? (technical, political, social, project)
- What is driving the need for this decision?

## Decision

[Describe the decision that was made]
- Clear, concise statement of the decision
- What option was chosen?

## Rationale

[Why was this decision made?]
- What are the benefits?
- How does it address the context?
- What trade-offs were accepted?

## Consequences

### Positive Consequences
- [Benefit 1]
- [Benefit 2]

### Negative Consequences
- [Drawback 1]
- [Drawback 2]

### Neutral Consequences
- [Implication 1]

## Alternatives Considered

### Alternative 1: [Name]
- **Pros**: [List]
- **Cons**: [List]
- **Why rejected**: [Reason]

### Alternative 2: [Name]
- **Pros**: [List]
- **Cons**: [List]
- **Why rejected**: [Reason]

## Implementation Notes

[How this decision should be implemented]
- [Guideline 1]
- [Guideline 2]

## Related Decisions

- [ADR-XXX]: [Related decision]

## References

- [Link 1]
- [Link 2]

2. For common architectural decisions, document:
   - Database choice (PostgreSQL, MongoDB, etc.)
   - Authentication strategy (JWT, OAuth, sessions)
   - State management (Redux, Context, Zustand)
   - API design (REST, GraphQL, tRPC)
   - Deployment architecture (containers, serverless, traditional)

3. Save to $DOC_DIR/architecture/decisions/ADR-[NUMBER]-[slug].md

4. Update $DOC_DIR/architecture/README.md with index of all ADRs
```

**Wait for specialist to complete ADR.**

#### Component Documentation Generation

Spawn specialist agent:

```
Task: Generate component documentation

Agent: Frontend Developer

Context:
- Framework: [React/Vue/Angular]
- Component: [specific component or all components]
- Documentation system: [Storybook / Markdown]

Instructions:
1. For each component, document:

# [ComponentName]

## Overview
[Brief description of what the component does]

## Usage

```tsx
import { [ComponentName] } from '@/components/[ComponentName]';

export function Example() {
  return (
    <[ComponentName]
      prop1="value"
      prop2={true}
    />
  );
}
```

## Props

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `prop1` | `string` | `undefined` | Yes | [Description] |
| `prop2` | `boolean` | `false` | No | [Description] |

## Variants

### Default
[Screenshot or code example]

### [VariantName]
[Screenshot or code example]

## States

- **Default**: [Description]
- **Hover**: [Description]
- **Active**: [Description]
- **Disabled**: [Description]
- **Loading**: [Description]
- **Error**: [Description]

## Accessibility

- **ARIA roles**: [List]
- **Keyboard navigation**: [Tab, Enter, Space, etc.]
- **Screen reader**: [How announced]
- **Focus management**: [How focus is handled]

## Examples

### Basic Example
```tsx
[Code]
```

### Advanced Example
```tsx
[Code with more props]
```

### With Form Integration
```tsx
[Real-world usage example]
```

## Design Tokens

[If using design system]
- **Colors**: [Tokens used]
- **Spacing**: [Tokens used]
- **Typography**: [Tokens used]

## Testing

[How to test this component]
```tsx
import { render, screen } from '@testing-library/react';
import { [ComponentName] } from './[ComponentName]';

test('renders correctly', () => {
  render(<[ComponentName] />);
  expect(screen.getByRole('[role]')).toBeInTheDocument();
});
```

## Related Components

- [[RelatedComponent1]] - [How related]
- [[RelatedComponent2]] - [How related]

2. Extract actual props from TypeScript interfaces/types
3. Capture all variants from the component code
4. Include real, working code examples
5. Save to $DOC_DIR/components/[ComponentName].md

6. If Storybook exists, also create/update stories:
```tsx
import type { Meta, StoryObj } from '@storybook/react';
import { [ComponentName] } from './[ComponentName]';

const meta: Meta<typeof [ComponentName]> = {
  title: 'Components/[ComponentName]',
  component: [ComponentName],
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof [ComponentName]>;

export const Default: Story = {
  args: {
    // Default props
  },
};

export const [Variant]: Story = {
  args: {
    // Variant props
  },
};
```
```

**Wait for specialist to complete component documentation.**

#### Feature Documentation Generation

Spawn specialist agent:

```
Task: Generate feature documentation

Agent: Content Creator or Senior Developer

Context:
- Feature: [feature name]
- Users: [developers / end-users / admins]
- Framework: [detected framework]

Instructions:
1. Create comprehensive feature documentation:

# [Feature Name]

## Overview

[Brief description of the feature - 2-3 sentences]

**Key Benefits**:
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

## User Guide

### Getting Started

[Step-by-step guide for new users]

1. [Step 1]
2. [Step 2]
3. [Step 3]

### Basic Usage

[Common use cases with examples]

#### Use Case 1: [Name]

[Description and example]

```
[Code or steps]
```

#### Use Case 2: [Name]

[Description and example]

### Advanced Usage

[Advanced features and techniques]

## Configuration

### Environment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `VAR_NAME` | `string` | `""` | [Description] |

### Configuration File

```json
{
  "feature": {
    "option1": "value",
    "option2": true
  }
}
```

## API Reference

[If feature exposes an API]

### Functions

#### `functionName(params)`

[Description]

**Parameters**:
- `param1` (`type`): [Description]

**Returns**: `type` - [Description]

**Example**:
```typescript
const result = functionName({ param1: 'value' });
```

## Implementation Details

[For developers who need to understand internals]

### Architecture

[How the feature is structured]

### Data Flow

[How data flows through the feature]

```
[Diagram or description]
```

### Database Schema

[If relevant]

```sql
CREATE TABLE feature_data (
  id SERIAL PRIMARY KEY,
  ...
);
```

## Testing

### Unit Tests

```typescript
describe('[Feature]', () => {
  test('[test case]', () => {
    // Test code
  });
});
```

### Integration Tests

[How to test the feature end-to-end]

### Manual Testing

[Test scenarios for QA]

1. **Scenario 1**: [Description]
   - Expected: [Result]

## Troubleshooting

### Common Issues

#### Issue: [Problem description]

**Symptoms**:
- [Symptom 1]
- [Symptom 2]

**Cause**: [Root cause]

**Solution**:
1. [Step 1]
2. [Step 2]

#### Issue: [Another problem]

[Same structure]

### FAQ

**Q: [Question]?**
A: [Answer]

**Q: [Question]?**
A: [Answer]

## Performance Considerations

[Performance implications and optimization tips]

## Security Considerations

[Security best practices and warnings]

## Examples

### Example 1: [Name]

[Full, realistic example]

```typescript
// Complete working code
```

### Example 2: [Name]

[Another example]

## Related Features

- [[RelatedFeature1]] - [How related]
- [[RelatedFeature2]] - [How related]

## Changelog

### v1.1.0
- [Change 1]
- [Change 2]

### v1.0.0
- Initial release

2. Tailor depth to audience (end-users vs developers)
3. Include screenshots for UI features
4. Verify all code examples work
5. Save to $DOC_DIR/features/[feature-name].md
```

**Wait for specialist to complete feature documentation.**

#### Code Documentation Generation

Spawn specialist agent:

```
Task: Generate inline code documentation

Agent: Senior Developer

Context:
- Language: [TypeScript/JavaScript/Python]
- Documentation style: [JSDoc/TypeDoc/Docstrings]
- Files to document: [specific files or all]

Instructions:
1. For TypeScript/JavaScript, add JSDoc comments:

```typescript
/**
 * [Brief description of function]
 *
 * [Longer description if needed - what it does, why it exists]
 *
 * @param param1 - [Description of param1]
 * @param param2 - [Description of param2]
 * @returns [Description of return value]
 *
 * @throws {ErrorType} [When this error is thrown]
 *
 * @example
 * ```typescript
 * const result = functionName('value', true);
 * // result === [expected]
 * ```
 *
 * @see {@link RelatedFunction} for related functionality
 */
export function functionName(param1: string, param2: boolean): ReturnType {
  // Implementation
}
```

2. For classes:

```typescript
/**
 * [Description of class]
 *
 * [Purpose and usage context]
 *
 * @example
 * ```typescript
 * const instance = new ClassName({ option: 'value' });
 * instance.method();
 * ```
 */
export class ClassName {
  /**
   * [Property description]
   */
  private propertyName: string;

  /**
   * Creates an instance of ClassName
   *
   * @param options - [Description of options]
   */
  constructor(options: Options) {
    // Implementation
  }

  /**
   * [Method description]
   *
   * @param param - [Description]
   * @returns [Description]
   */
  public methodName(param: string): ReturnType {
    // Implementation
  }
}
```

3. For Python, add docstrings:

```python
def function_name(param1: str, param2: bool) -> ReturnType:
    """
    [Brief description of function]

    [Longer description if needed]

    Args:
        param1: [Description of param1]
        param2: [Description of param2]

    Returns:
        [Description of return value]

    Raises:
        ValueError: [When this error is raised]

    Example:
        >>> result = function_name('value', True)
        >>> print(result)
        [expected output]
    """
    # Implementation
    pass
```

4. Focus on:
   - Exported/public functions and classes (highest priority)
   - Complex logic that needs explanation
   - Non-obvious behavior or side effects
   - Parameters and return values
   - Usage examples for public APIs

5. Use Edit tool to add documentation inline
6. Generate API documentation from docstrings:
   - For TypeScript: Run `npx typedoc`
   - For Python: Run `pdoc`

7. Save generated API docs to $DOC_DIR/api/
```

**Wait for specialist to complete code documentation.**

Mark todo #2 as completed.

---

## Phase 3: Documentation Review (5-10 min)

Mark todo #3 as in_progress.

### Select Review Specialist

Spawn an appropriate reviewer based on documentation type:

| Documentation Type | Reviewer |
|--------------------|----------|
| **API** | Backend Architect or reality-checker |
| **Architecture** | Backend Architect or ArchitectUX |
| **Component** | Frontend Developer or UI Designer |
| **Feature** | Content Creator or reality-checker |
| **Code** | Senior Developer |

### Spawn Documentation Reviewer

```
Task: Review documentation quality

Agent: [selected reviewer]

Context:
- Documentation type: [TYPE]
- Generated documentation: [paths to files]

Instructions:
Review the documentation for:

1. **Accuracy**:
   - Information is correct and up-to-date
   - Code examples match actual code
   - API schemas match implementation
   - No outdated information

2. **Completeness**:
   - All required sections present
   - No missing information
   - Edge cases covered
   - Error scenarios documented

3. **Clarity**:
   - Language is clear and concise
   - Technical jargon explained
   - Examples are helpful
   - Flow is logical

4. **Code Examples**:
   - Examples are realistic
   - Examples compile/run without errors
   - Examples demonstrate key features
   - Examples follow best practices

5. **Consistency**:
   - Formatting is consistent
   - Terminology is consistent
   - Style matches existing docs
   - Naming conventions followed

6. **Links & References**:
   - All internal links work
   - External links are valid
   - Cross-references are correct
   - Related docs linked

Provide feedback on:
- Errors to fix (critical)
- Improvements to make (recommended)
- Additional examples needed
- Missing sections

Please review and provide specific, actionable feedback.
```

**Wait for reviewer to complete.**

### Incorporate Review Feedback

Based on reviewer feedback:

1. **Fix critical errors** immediately using Edit tool
2. **Add missing sections** that were identified
3. **Improve unclear explanations**
4. **Add requested examples**
5. **Fix broken links**

If substantial changes needed, re-delegate to original specialist:

```
Task: Update documentation based on review feedback

Agent: [original specialist]

Context:
- Documentation: [paths]
- Review feedback: [summarize feedback]

Instructions:
Update the documentation to address these issues:
1. [Issue 1]
2. [Issue 2]
3. [Issue 3]

Ensure all feedback is addressed completely.
```

Mark todo #3 as completed.

---

## Phase 4: Validation & Publishing (5-10 min)

Mark todo #4 as in_progress.

### Validate Code Examples

For each code example in the documentation, verify it works:

#### For TypeScript/JavaScript Examples

```bash
# Create temporary test file
cat > .agency/documentation/example-test.ts <<'EOF'
[code example from docs]
EOF

# Type check
npx tsc --noEmit .agency/documentation/example-test.ts

if [ $? -eq 0 ]; then
  echo "✅ Example type checks"
else
  echo "❌ Example has type errors - fix in documentation"
fi

# Clean up
rm .agency/documentation/example-test.ts
```

#### For Python Examples

```bash
# Create temporary test file
cat > .agency/documentation/example_test.py <<'EOF'
[code example from docs]
EOF

# Syntax check
python3 -m py_compile .agency/documentation/example_test.py

if [ $? -eq 0 ]; then
  echo "✅ Example syntax valid"
else
  echo "❌ Example has syntax errors - fix in documentation"
fi

# Clean up
rm .agency/documentation/example_test.py
```

#### For cURL Examples (API docs)

```bash
# Start development server if needed
# npm run dev &
# SERVER_PID=$!

# Test cURL examples
curl -X GET http://localhost:3000/api/endpoint

# Check response code
if [ $? -eq 0 ]; then
  echo "✅ API endpoint accessible"
else
  echo "⚠️ API endpoint returned error - verify docs are accurate"
fi

# Kill server
# kill $SERVER_PID
```

**Fix any examples that don't work.**

### Validate Links

```bash
# Find all markdown links
grep -r "\[.*\](.*)" $DOC_DIR/ --include="*.md" > .agency/documentation/links.txt

# Check internal links (files exist)
# [Manual verification or use a tool like markdown-link-check]

# Check external links
# npm install -g markdown-link-check
# markdown-link-check $DOC_DIR/**/*.md
```

**Fix broken links.**

### Spell Check (Optional but Recommended)

```bash
# Install aspell if available
# aspell check $DOC_DIR/README.md

# Or use VS Code spell checker extension
# Or manual review
```

### Generate Documentation Index

Create or update main documentation index:

```markdown
# Documentation

Welcome to the [Project Name] documentation.

## Quick Start

- [Getting Started](./guides/getting-started.md)
- [Installation](./guides/installation.md)

## API Documentation

- [API Overview](./api/README.md)
- [Authentication](./api/authentication.md)
- [Endpoints](./api/endpoints/)

## Architecture

- [Architecture Overview](./architecture/README.md)
- [Decision Records](./architecture/decisions/)

## Components

- [Component Library](./components/README.md)
- [Button](./components/Button.md)
- [Modal](./components/Modal.md)

## Features

- [Feature 1](./features/feature-1.md)
- [Feature 2](./features/feature-2.md)

## Guides

- [Deployment](./guides/deployment.md)
- [Testing](./guides/testing.md)
- [Contributing](./guides/contributing.md)

## Troubleshooting

- [Common Issues](./troubleshooting.md)
- [FAQ](./faq.md)

---

Last updated: [DATE]
```

Save to `$DOC_DIR/README.md`

### Publish Documentation

```bash
# Add documentation to git
git add $DOC_DIR/

# Show what will be committed
git status

# Commit documentation
git commit -m "docs($ARGUMENTS): generate comprehensive [TYPE] documentation

Generated documentation includes:
- [Section 1]
- [Section 2]
- [Section 3]

[Any notable details]"
```

### Generate Documentation Report

Create comprehensive report:

```markdown
# Documentation Generation Report

**Date**: [current date]
**Documentation Type**: [API/Architecture/Component/Feature/Code]
**Scope**: [what was documented]
**Duration**: [time spent]

---

## Documentation Generated

### Files Created/Updated

1. `$DOC_DIR/[path]` - [Description]
2. `$DOC_DIR/[path]` - [Description]
3. `$DOC_DIR/[path]` - [Description]

**Total**: [N] documentation files, [X]KB of documentation

### Sections Included

- [Section 1]: [Brief description]
- [Section 2]: [Brief description]
- [Section 3]: [Brief description]

---

## Documentation Quality

### Completeness: [High/Medium/Low]

- ✅ All required sections present
- ✅ Examples included
- ✅ Troubleshooting guide included
- ⚠️ [Any gaps]

### Accuracy: [Verified/Needs Review]

- ✅ Code examples validated
- ✅ Links checked
- ✅ API schemas verified
- ⚠️ [Any concerns]

### Code Examples: [N] examples

- ✅ All examples type-checked
- ✅ Realistic use cases
- ✅ Follow best practices

---

## Review Feedback Addressed

1. **[Feedback 1]**: [How addressed]
2. **[Feedback 2]**: [How addressed]

---

## Next Steps

### Recommended Follow-up Documentation

1. **[Topic 1]**: [Why needed]
2. **[Topic 2]**: [Why needed]

### Maintenance

- **Update frequency**: [Recommended frequency]
- **Ownership**: [Who should maintain]
- **Review triggers**: [When to review - releases, major changes]

---

## Artifacts

All documentation artifacts in:
- `$DOC_DIR/` - Generated documentation
- `.agency/documentation/` - Generation logs and validation reports

---

## Related Documentation

- [Link to related docs]

---

**Status**: ✅ Documentation Complete and Published

**Commit**: [commit hash]

---

**Generated**: [timestamp]
**Documentation Topic**: $ARGUMENTS
```

Save to `.agency/documentation/doc-[topic]-report-[date].md`

Mark todo #4 as completed.

---

## Error Handling

### If Scope Detection Fails

**Ambiguous Topic**:
- Ask user to clarify with AskUserQuestion
- Provide options based on project analysis
- Allow manual scope specification

**No Relevant Code Found**:
- Verify search paths are correct
- Ask user to specify exact location
- Suggest alternative documentation types

### If Generation Fails

**Specialist Agent Error**:
- Review error from specialist
- Either fix prerequisites or re-delegate with clarification
- If repeated failures, offer to do manual generation with user guidance

**Missing Information**:
- Identify what information is needed
- Use Grep/Read to find it in codebase
- Ask user if not found in code

### If Validation Fails

**Code Examples Don't Work**:
- Fix the examples in documentation
- Or clarify they're pseudocode (not recommended)
- Ensure examples match actual code

**Broken Links**:
- Fix relative links
- Update moved files
- Remove links to non-existent pages

**Formatting Issues**:
- Fix markdown syntax errors
- Ensure consistent formatting
- Validate with markdown linter if available

### If User Requests Changes

**Different Scope**:
- Adjust scope and regenerate affected sections
- Keep valid documentation already generated

**Different Format**:
- Convert to requested format (Markdown → OpenAPI, etc.)
- Or regenerate from scratch if substantial

**Additional Sections**:
- Add requested sections
- Delegate to specialist if complex

---

## Important Notes

### Documentation Principles

1. **Accuracy First**: Wrong documentation is worse than no documentation
2. **Examples Are King**: Show, don't just tell
3. **Keep It Current**: Document what *is*, not what *was* or *will be*
4. **Think of the Reader**: Write for your audience (beginners vs experts)
5. **Test Everything**: If there's code in the docs, it should work

### Documentation Best Practices

**For API Docs**:
- Include authentication details
- Show both success and error responses
- Provide working cURL examples
- Document rate limits and quotas
- Explain error codes

**For Architecture Docs**:
- Explain the "why", not just the "what"
- Document alternatives considered
- Include consequences (good and bad)
- Keep ADRs concise (1-2 pages)
- Update status when decisions change

**For Component Docs**:
- Show all variants visually
- Document accessibility
- Include TypeScript types/interfaces
- Real-world usage examples
- Link to Storybook if available

**For Feature Docs**:
- Start with quick start guide
- Progressive disclosure (basic → advanced)
- Include troubleshooting section
- Real screenshots for UI features
- Version information

**For Code Docs**:
- Focus on "why" in comments, code shows "how"
- Document non-obvious behavior
- Include examples for complex functions
- Keep comments in sync with code
- Generate API docs from inline comments

### Documentation Maintenance

Documentation is a living thing:

- **Update with code changes**: Documentation PR should accompany code PR
- **Review regularly**: Quarterly review recommended
- **User feedback**: Update based on support questions
- **Version appropriately**: Major versions may need separate docs
- **Archive old docs**: Keep old versions accessible but clearly marked

### Documentation Tools

**Generators**:
- **TypeDoc**: Auto-generate from TypeScript
- **pdoc**: Auto-generate from Python docstrings
- **Swagger/OpenAPI**: API documentation standard
- **Storybook**: Component documentation and playground

**Static Site Generators**:
- **Docusaurus**: Modern documentation websites
- **VitePress**: Fast, Vue-powered
- **MkDocs**: Python-based, simple and clean
- **Sphinx**: Comprehensive Python documentation

**Quality Tools**:
- **markdown-link-check**: Validate all links
- **alex**: Check for insensitive language
- **markdownlint**: Enforce consistent formatting
- **vale**: Prose linter (style guide enforcement)

---

## Skills to Reference

Activate and reference these skills as needed:

**Required**:
- `agency-workflow-patterns` - Orchestration patterns (ACTIVATE IMMEDIATELY)

**Technology-Specific** (activate based on project):
- `nextjs-16-expert` - Next.js documentation patterns
- `typescript-5-expert` - TypeScript documentation best practices
- `react-documentation` - Component documentation standards
- `api-documentation-standards` - REST/GraphQL API docs

**Documentation Skills**:
- `technical-writing` - Writing clear, concise documentation
- `markdown-mastery` - Advanced markdown techniques
- `adr-writing` - Architecture Decision Records (if available)

---

## Related Commands

- `/agency:work [issue]` - Implement feature (may need documentation)
- `/agency:review [pr]` - Review PR (check for documentation updates)
- `/agency:refactor [scope]` - Refactor code (update documentation accordingly)

---

**Remember**:

- **Documentation is code**: Treat it with the same care
- **Examples should work**: Test every code example
- **Write for humans**: Clear, concise, helpful
- **Keep it current**: Outdated docs are worse than no docs
- **Show and tell**: Examples + explanations = best documentation

Good documentation multiplies the value of good code.

---

**End of /agency:document command**
