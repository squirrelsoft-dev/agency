# Question 9: Hook Project Detection

## Context
Hooks need to detect project type to run appropriate tools (npm vs pip vs cargo, etc.).

## Question
How should hooks detect project type and which tools to run?

## Detection Methods

### Method A: File Detection
**Approach**: Check for specific files in project root

```bash
if [ -f "package.json" ]; then
  npm run format
elif [ -f "requirements.txt" ]; then
  black .
elif [ -f "Cargo.toml" ]; then
  cargo fmt
fi
```

**Pros**:
- Simple and reliable
- No configuration needed
- Works automatically

**Cons**:
- May miss edge cases
- What about monorepos?
- Multiple languages in one project?

### Method B: User Configuration
**Approach**: User specifies in settings

```markdown
# .claude/agency.local.md

## Project Configuration
- **Type**: node
- **Formatter**: prettier
- **Linter**: eslint
- **Test Command**: npm test
```

**Pros**:
- Explicit and clear
- Handles edge cases
- User control

**Cons**:
- Requires manual setup
- May forget to configure
- Maintenance overhead

### Method C: Smart Detection with Fallback (Recommended)
**Approach**: Try auto-detection, fall back to user config

**Algorithm**:
1. Check for project files (package.json, etc.)
2. If multiple matches, use user preference from settings
3. If no matches, skip hook or ask user
4. Cache detection result for performance

**Pros**:
- Best user experience
- Works out of the box
- Handles edge cases
- Performance optimized

**Cons**:
- More complex implementation
- Need to handle ambiguous cases

## Project Type Matrix

| Project Type | Detection File | Formatter | Linter | Test Command |
|--------------|---------------|-----------|--------|--------------|
| Node.js | package.json | prettier | eslint | npm test |
| Python | requirements.txt | black | pylint | pytest |
| Rust | Cargo.toml | cargo fmt | cargo clippy | cargo test |
| Go | go.mod | gofmt | golint | go test |
| Ruby | Gemfile | rubocop | rubocop | rspec |
| Java | pom.xml | google-java-format | checkstyle | mvn test |

## Monorepo Handling

**Challenge**: Project may have multiple languages/tools

**Solution**:
- Detect tools per directory/file
- Use file-specific tools based on extension
- Allow directory-specific overrides in settings

**Example**:
```
project/
├── frontend/ (Node.js - use prettier)
├── backend/ (Python - use black)
└── mobile/ (React Native - use prettier)
```

## Decision Needed
- Use Method C (Smart Detection with Fallback)?
- Which project types to support in Phase 1?
- How to handle monorepos?
- Where to cache detection results?
- Should hooks fail gracefully if tools not installed?

## Status
**Status**: Open
**Priority**: Medium
**Blocking**: Phase 5 (Component Implementation - Hooks)
