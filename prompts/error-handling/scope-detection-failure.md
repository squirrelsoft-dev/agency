# Error Handling: Scope Detection Failure

Handle situations where project scope, technology stack, or configuration cannot be reliably detected.

## When to Use

**Triggers**:
- Cannot determine project framework (no package.json, unclear structure)
- Multiple conflicting frameworks detected
- Missing critical configuration files
- Ambiguous project type (monorepo with mixed technologies)
- User request is too vague to map to a specialist

**Commands Using This**: All 14 commands

---

## Detection Patterns

### Pattern 1: Missing Framework Indicators

```bash
# Check for standard indicators
ls package.json 2>/dev/null || echo "NO_PACKAGE_JSON"
ls composer.json 2>/dev/null || echo "NO_COMPOSER_JSON"
ls requirements.txt pyproject.toml 2>/dev/null || echo "NO_PYTHON_CONFIG"
```

**If all missing**: Scope detection failure

### Pattern 2: Conflicting Frameworks

```bash
# Multiple package managers found
ls package.json && ls composer.json && ls Cargo.toml
```

**If multiple found**: Ambiguous project type

### Pattern 3: Empty or Invalid Configuration

```bash
# Check if package.json exists but is empty/invalid
if [ -f package.json ]; then
  cat package.json | jq . 2>/dev/null || echo "INVALID_JSON"
fi
```

**If invalid**: Configuration error

### Pattern 4: Vague User Request

**Examples**:
- "Fix the bug" (no context)
- "Make it better" (no specifics)
- "Update everything" (too broad)
- "The thing isn't working" (unclear)

---

## Error Messages

### User-Friendly Messages

**For Missing Framework**:
```
❌ Unable to detect project framework or technology stack.

I checked for common project files but couldn't find:
- package.json (Node.js/JavaScript)
- composer.json (PHP)
- requirements.txt or pyproject.toml (Python)
- Cargo.toml (Rust)
- pom.xml or build.gradle (Java)

Please specify:
1. What framework/language is this project using?
2. Where is the main project directory?
```

**For Conflicting Frameworks**:
```
⚠️ Multiple frameworks detected in this directory.

Found:
- Node.js (package.json)
- PHP (composer.json)
- Python (requirements.txt)

This appears to be a monorepo or mixed-technology project.

Please specify:
1. Which technology should I focus on?
2. Should I work in a specific subdirectory?
```

**For Vague Request**:
```
⚠️ I need more context to proceed effectively.

Your request: "[USER_REQUEST]"

To help you better, please provide:
1. What specific feature/file/component needs work?
2. What is the expected behavior or outcome?
3. Are there any error messages or issues to address?
```

---

## Recovery Strategies

### Strategy 1: Ask User for Clarification (Primary)

Use `AskUserQuestion` to gather missing information:

```markdown
**Question**: What framework or technology stack is this project using?

**Options**:
A) Next.js / React
B) Laravel / PHP
C) Django / FastAPI (Python)
D) Other (please specify)

**Context**: I couldn't automatically detect the project type. This information will help me select the right specialist and tools.
```

### Strategy 2: Manual Directory Discovery

```bash
# Search for framework-specific patterns
find . -maxdepth 3 -type f -name "next.config.js" 2>/dev/null
find . -maxdepth 3 -type f -name "artisan" 2>/dev/null
find . -maxdepth 3 -type f -name "manage.py" 2>/dev/null
```

**Then report findings** and ask user to confirm.

### Strategy 3: Scan Common Patterns

```bash
# Check for common framework patterns in code
grep -r "from django" . 2>/dev/null | head -5
grep -r "import React" . 2>/dev/null | head -5
grep -r "use App\\" . 2>/dev/null | head -5
```

**Present evidence** and ask user to verify.

### Strategy 4: Use Safe Defaults

**If user doesn't respond or can't specify**:
- Default to `senior-developer` specialist (most general)
- Work in current directory
- Use generic tools (no framework-specific assumptions)
- Document limitations in summary

---

## Interactive Decision Flow

### Step 1: Detect the Issue

```markdown
🔍 **Scope Detection Issue Detected**

I'm having trouble determining the project scope. Let me investigate...

[Run detection commands]

**Finding**: [Describe what's missing or ambiguous]
```

### Step 2: Use AskUserQuestion

```markdown
I need your help to proceed correctly.
```

**Question Template**:
```markdown
**What is the primary technology stack for this project?**

Please select one:
A) JavaScript/TypeScript (React, Next.js, Node.js)
B) PHP (Laravel, Symfony)
C) Python (Django, FastAPI, Flask)
D) Other: [Please specify]

This helps me:
- Select the right specialist
- Use the correct build/test tools
- Apply appropriate quality gates
```

### Step 3: Validate User Response

```bash
# After user selects, verify with specific checks
case "$USER_CHOICE" in
  "A")
    # Verify Node.js project
    if [ ! -f package.json ]; then
      echo "⚠️ Warning: package.json not found. Should I create one?"
    fi
    ;;
  "B")
    # Verify PHP project
    if [ ! -f composer.json ]; then
      echo "⚠️ Warning: composer.json not found. Should I create one?"
    fi
    ;;
esac
```

### Step 4: Proceed with Confirmation

```markdown
✅ **Scope Confirmed**

- **Technology**: [User's selection]
- **Specialist**: [Selected specialist]
- **Working Directory**: [Path]

Proceeding with [COMMAND] workflow...
```

---

## Exit Codes and Cleanup

### Exit Code Standards

```bash
# Exit code for scope detection failure
EXIT_CODE_SCOPE_FAILURE=10

# Exit code for user cancellation during scope clarification
EXIT_CODE_USER_CANCELLED_SCOPE=11

# Exit code for unresolvable scope ambiguity
EXIT_CODE_SCOPE_AMBIGUOUS=12
```

### Cleanup Procedures

**Before exiting**:

1. **Log the attempt**:
```bash
echo "$(date): Scope detection failed - [REASON]" >> .agency/logs/errors.log
```

2. **Save partial state** (if any work was done):
```bash
# Save what we detected
cat > .agency/tmp/scope-detection-attempt.json <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "command": "$COMMAND",
  "detected": {
    "package_managers": [LIST],
    "frameworks": [LIST],
    "confidence": "low"
  },
  "reason": "[FAILURE_REASON]",
  "user_request": "[ORIGINAL_REQUEST]"
}
EOF
```

3. **Clean up temp files**:
```bash
# Remove any incomplete detection artifacts
rm -f .agency/tmp/framework-check-*.tmp
```

4. **Exit gracefully**:
```bash
echo ""
echo "Unable to proceed without scope clarification."
echo "Please provide more details and try again."
echo ""
exit $EXIT_CODE_SCOPE_FAILURE
```

---

## Prevention Best Practices

### For Command Authors

**Always check scope before proceeding**:

```markdown
## Phase 1: Scope Detection

1. Check for package.json, composer.json, etc.
2. If not found, use `scope-detection-failure.md` workflow
3. Only proceed after scope is confirmed
4. Document detected scope in TodoWrite
```

### For Users

**Provide context in requests**:

Good examples:
- "Fix the authentication bug in the Laravel API"
- "Add a new React component to the Next.js dashboard"
- "Update the Python FastAPI endpoint for user profiles"

Bad examples:
- "Fix the bug"
- "Make it work"
- "Update everything"

---

## Common Scenarios

### Scenario 1: Brand New Project (No Files)

**Detection**: Current directory is empty or minimal

**Response**:
```markdown
This appears to be a new project with no existing code.

Would you like me to:
A) Initialize a new [FRAMEWORK] project
B) Navigate to an existing project directory
C) Provide more information about what you're building

Please select an option or describe what you'd like to create.
```

### Scenario 2: Monorepo with Multiple Technologies

**Detection**: Multiple package managers in subdirectories

**Response**:
```markdown
This is a monorepo with multiple technologies:

Detected:
- `/frontend` - Next.js/React (package.json)
- `/backend` - Laravel/PHP (composer.json)
- `/api` - FastAPI/Python (pyproject.toml)

Which component should I work on?
A) Frontend (Next.js)
B) Backend (Laravel)
C) API (FastAPI)
D) All components (I'll coordinate)

Please select one.
```

### Scenario 3: Legacy/Custom Framework

**Detection**: No standard framework indicators

**Response**:
```markdown
I don't recognize the framework or structure of this project.

Can you help me understand:
1. Is this a custom framework or legacy codebase?
2. What build tools do you use? (npm, make, custom scripts?)
3. How do you typically test this code?
4. Are there any special tools or commands I should know?

This will help me provide better assistance without breaking anything.
```

---

## Integration with Other Components

### Used Alongside

**Always pair with**:
- `specialist-selection/keyword-analysis.md` - For specialist selection after clarification
- `ask-user-retry.md` - For retry/abort patterns
- `user-cancellation.md` - If user cancels clarification

**Often used with**:
- `context/framework-detection.md` - The primary detection that triggers this
- `progress/todo-initialization.md` - Document scope once confirmed

---

## Testing Scope Detection Failure

### Test Case 1: Empty Directory

```bash
# Create empty test directory
mkdir /tmp/test-empty-project
cd /tmp/test-empty-project

# Run command
/agency:work "Build a login form"

# Expected: Scope detection failure, asks for framework
```

### Test Case 2: Multiple Frameworks

```bash
# Create conflicting files
touch package.json composer.json requirements.txt

# Run command
/agency:implement "Add user authentication"

# Expected: Asks which framework to focus on
```

### Test Case 3: Invalid Configuration

```bash
# Create invalid package.json
echo "{ invalid json" > package.json

# Run command
/agency:test "Run all tests"

# Expected: Detects invalid config, asks to fix or specify framework
```

---

## Success Metrics

**Scope detection is successful when**:
- User provides clarification within 1-2 questions
- Correct specialist is selected based on user input
- No incorrect assumptions about framework/tools
- User feels guided, not frustrated
- Workflow continues smoothly after clarification

**Failure indicators**:
- User doesn't respond to clarification questions
- Multiple rounds of back-and-forth without resolution
- Incorrect specialist selected due to ambiguity
- Command proceeds with wrong assumptions

---

## Related Components

- `context/framework-detection.md` - Primary detection logic
- `error-handling/ask-user-retry.md` - For retry patterns
- `error-handling/user-cancellation.md` - If user gives up
- `specialist-selection/keyword-analysis.md` - For specialist selection
- `specialist-selection/user-approval.md` - For confirming selection
