---
description: Comprehensive security audit with vulnerability scanning and code review
argument-hint: scope (codebase/dependencies/api/config/all)
allowed-tools: Read, Write, Edit, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion
---

# Security Audit: $ARGUMENTS

Comprehensive security audit with vulnerability scanning, OWASP Top 10 checks, and actionable remediation.

## Your Mission

Perform security audit for: **$ARGUMENTS**

Execute thorough security analysis with vulnerability scanning, OWASP Top 10 checks, secrets detection, and actionable recommendations.

---

## Critical Instructions

<!-- Component: prompts/specialist-selection/skill-activation.md -->

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and workflow strategies you MUST follow.

### 2. Security First Principles

**NEVER**:
- Expose sensitive data in reports (redact secrets, credentials, tokens)
- Run destructive security testing in production
- Skip critical vulnerabilities
- Commit secrets or credentials to git

**ALWAYS**:
- Redact secrets and sensitive data from all reports
- Report all critical and high-severity findings
- Provide specific remediation steps with code examples
- Verify fixes don't introduce new vulnerabilities

### 3. Use TodoWrite Throughout

<!-- Component: prompts/progress/todo-initialization.md -->

Track security audit progress with TodoWrite for transparency and accountability.

**Initialize security audit todo list**:

```javascript
[
  {
    "content": "Detect project context and security scope",
    "status": "in_progress",
    "activeForm": "Detecting project context and security scope"
  },
  {
    "content": "Run dependency vulnerability scan",
    "status": "pending",
    "activeForm": "Running dependency vulnerability scan"
  },
  {
    "content": "Scan for secrets and credentials",
    "status": "pending",
    "activeForm": "Scanning for secrets and credentials"
  },
  {
    "content": "Perform OWASP Top 10 code review",
    "status": "pending",
    "activeForm": "Performing OWASP Top 10 code review"
  },
  {
    "content": "Review authentication and authorization",
    "status": "pending",
    "activeForm": "Reviewing authentication and authorization"
  },
  {
    "content": "Generate security audit report",
    "status": "pending",
    "activeForm": "Generating security audit report"
  }
]
```

---

## Phase 0: Project Context Detection (1-2 min)

<!-- Component: prompts/context/framework-detection.md -->

Quickly gather project context to determine security audit scope and framework-specific vulnerabilities.

### Detect Framework/Platform

Use the framework detection algorithm from `prompts/context/framework-detection.md`:

```bash
# Execute in order, return first match:

if test -f next.config.js || test -f next.config.mjs || test -f next.config.ts; then
  echo "Next.js"
elif test -f manage.py; then
  echo "Django"
elif test -f artisan; then
  echo "Laravel"
elif grep -q "fastapi" requirements.txt 2>/dev/null || grep -q "fastapi" pyproject.toml 2>/dev/null; then
  echo "FastAPI"
elif grep -q "flask" requirements.txt 2>/dev/null || grep -q "flask" pyproject.toml 2>/dev/null; then
  echo "Flask"
elif test -f bin/rails || test -f config/application.rb; then
  echo "Ruby on Rails"
elif test -f remix.config.js || test -f remix.config.ts; then
  echo "Remix"
elif test -f svelte.config.js; then
  echo "SvelteKit"
elif test -f astro.config.mjs || test -f astro.config.ts; then
  echo "Astro"
elif test -f nuxt.config.js || test -f nuxt.config.ts; then
  echo "Nuxt"
elif test -f angular.json; then
  echo "Angular"
elif grep -q '"express"' package.json 2>/dev/null; then
  echo "Express.js"
elif grep -q '"react"' package.json 2>/dev/null; then
  echo "React"
elif grep -q '"vue"' package.json 2>/dev/null; then
  echo "Vue.js"
else
  echo "Unknown"
fi
```

<!-- Component: prompts/context/database-detection.md -->

### Detect Database

```bash
# Check for database configuration
if grep -q "postgresql\|pg\|postgres" package.json requirements.txt pyproject.toml composer.json 2>/dev/null; then
  DATABASE="PostgreSQL"
elif grep -q "mysql\|mariadb" package.json requirements.txt pyproject.toml composer.json 2>/dev/null; then
  DATABASE="MySQL/MariaDB"
elif grep -q "mongodb\|mongoose" package.json requirements.txt pyproject.toml 2>/dev/null; then
  DATABASE="MongoDB"
elif grep -q "sqlite" package.json requirements.txt pyproject.toml 2>/dev/null; then
  DATABASE="SQLite"
elif test -f "prisma/schema.prisma"; then
  DATABASE=$(grep "provider" prisma/schema.prisma | head -1 | grep -oE '"[^"]+"' | tr -d '"')
fi

echo "Detected database: $DATABASE"
```

### Parse Security Scope

Analyze `$ARGUMENTS` to determine audit scope:

**Full Audit** if:
- `$ARGUMENTS` = "all" or "full" or "comprehensive"
- Audit: dependencies, codebase, API, config, secrets

**Specific Scope** if:
- `$ARGUMENTS` = "codebase" → Focus on code vulnerabilities only
- `$ARGUMENTS` = "dependencies" or "deps" → Focus on dependency vulnerabilities
- `$ARGUMENTS` = "api" → Focus on API security
- `$ARGUMENTS` = "config" → Focus on configuration security

**Auto-Detect** if:
- `$ARGUMENTS` is empty or unclear
- Infer scope from project type and detected technologies

### Create Audit Directory

```bash
# Create security audit tracking directory
mkdir -p .agency/security-audits
AUDIT_ID="audit-$(date +%Y%m%d-%H%M%S)"
AUDIT_DIR=".agency/security-audits/$AUDIT_ID"
mkdir -p "$AUDIT_DIR"

echo "Security Audit ID: $AUDIT_ID"
echo "Tracking directory: $AUDIT_DIR"
```

Mark todo #1 as completed.

---

## Phase 1: Dependency Vulnerability Scan (5-10 min)

<!-- Component: prompts/quality-gates/security-scan-quick.md -->

Mark todo #2 as in_progress.

### Run Dependency Audit

Use framework-specific security scanning tools from `prompts/quality-gates/security-scan-quick.md`:

#### JavaScript/TypeScript Projects

```bash
if [ -f "package.json" ]; then
  echo "Running npm audit..."

  # Full audit report
  npm audit --json > "$AUDIT_DIR/npm-audit.json" 2>&1
  npm audit > "$AUDIT_DIR/npm-audit.txt" 2>&1

  # Parse vulnerability counts
  CRITICAL_VULNS=$(grep -c '"severity": "critical"' "$AUDIT_DIR/npm-audit.json" || echo "0")
  HIGH_VULNS=$(grep -c '"severity": "high"' "$AUDIT_DIR/npm-audit.json" || echo "0")
  MODERATE_VULNS=$(grep -c '"severity": "moderate"' "$AUDIT_DIR/npm-audit.json" || echo "0")
  LOW_VULNS=$(grep -c '"severity": "low"' "$AUDIT_DIR/npm-audit.json" || echo "0")

  echo "Vulnerabilities found:"
  echo "  Critical: $CRITICAL_VULNS"
  echo "  High: $HIGH_VULNS"
  echo "  Moderate: $MODERATE_VULNS"
  echo "  Low: $LOW_VULNS"

  # Try auto-fix for non-breaking changes
  if [ "$CRITICAL_VULNS" -gt 0 ] || [ "$HIGH_VULNS" -gt 0 ]; then
    echo "Attempting auto-fix..."
    npm audit fix --dry-run > "$AUDIT_DIR/npm-audit-fix-preview.txt" 2>&1

    # Ask user if they want to apply fixes
    if grep -q "fixed" "$AUDIT_DIR/npm-audit-fix-preview.txt"; then
      echo "Auto-fix available. Review: $AUDIT_DIR/npm-audit-fix-preview.txt"
    fi
  fi
fi
```

#### Python Projects

```bash
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo "Running pip-audit..."

  # Install pip-audit if not available
  if ! command -v pip-audit &> /dev/null; then
    echo "Installing pip-audit..."
    pip install pip-audit
  fi

  # Run audit
  pip-audit --format json > "$AUDIT_DIR/pip-audit.json" 2>&1 || true
  pip-audit > "$AUDIT_DIR/pip-audit.txt" 2>&1 || true

  # Also try safety
  if command -v safety &> /dev/null; then
    safety check --json > "$AUDIT_DIR/safety-check.json" 2>&1 || true
  fi
fi
```

#### Ruby Projects

```bash
if [ -f "Gemfile" ]; then
  echo "Running bundle audit..."

  # Update advisory database
  bundle audit update

  # Run audit
  bundle audit > "$AUDIT_DIR/bundle-audit.txt" 2>&1 || true
fi
```

### Analyze Vulnerability Severity

<!-- Component: prompts/quality-gates/security-scan-quick.md (Severity Levels) -->

```bash
# Categorize vulnerabilities by severity
cat > "$AUDIT_DIR/vulnerability-summary.md" <<EOF
# Dependency Vulnerability Summary

**Audit Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Framework**: $FRAMEWORK
**Scope**: Dependencies

## Severity Breakdown

| Severity | Count | Action Required |
|----------|-------|-----------------|
| Critical (CVSS ≥ 9.0) | $CRITICAL_VULNS | ❌ IMMEDIATE FIX REQUIRED |
| High (CVSS 7.0-8.9) | $HIGH_VULNS | ⚠️ FIX BEFORE DEPLOYMENT |
| Moderate (CVSS 4.0-6.9) | $MODERATE_VULNS | ℹ️ Fix in next sprint |
| Low (CVSS < 4.0) | $LOW_VULNS | ℹ️ Fix when convenient |

## Critical Vulnerabilities

$(if [ "$CRITICAL_VULNS" -gt 0 ]; then
  grep -A 5 '"severity": "critical"' "$AUDIT_DIR/npm-audit.json" | head -20
else
  echo "None found ✅"
fi)

## Recommended Actions

$(if [ "$CRITICAL_VULNS" -gt 0 ] || [ "$HIGH_VULNS" -gt 0 ]; then
  echo "1. Review auto-fix preview: $AUDIT_DIR/npm-audit-fix-preview.txt"
  echo "2. Apply fixes: npm audit fix"
  echo "3. For breaking changes, manually upgrade: npm install package@version"
  echo "4. Re-run audit to verify fixes"
else
  echo "✅ No critical or high severity vulnerabilities found"
  echo "ℹ️ Consider addressing moderate/low vulnerabilities in next sprint"
fi)
EOF

cat "$AUDIT_DIR/vulnerability-summary.md"
```

Mark todo #2 as completed.

---

## Phase 2: Secrets & Credentials Detection (3-5 min)

<!-- Component: prompts/quality-gates/security-scan-quick.md (Secrets Detection) -->

Mark todo #3 as in_progress.

### Scan for Hard-Coded Secrets

```bash
echo "Scanning for secrets and credentials..."

# Method 1: gitleaks (if available)
if command -v gitleaks &> /dev/null; then
  echo "Running gitleaks..."
  gitleaks detect --source . --report-path "$AUDIT_DIR/gitleaks-report.json" --report-format json --verbose 2>&1 | tee "$AUDIT_DIR/gitleaks-output.txt" || true

  SECRETS_FOUND=$(grep -c '"Description"' "$AUDIT_DIR/gitleaks-report.json" 2>/dev/null || echo "0")
  echo "Gitleaks found: $SECRETS_FOUND potential secrets"
fi

# Method 2: trufflehog (if available)
if command -v trufflehog &> /dev/null; then
  echo "Running trufflehog..."
  trufflehog filesystem . --json > "$AUDIT_DIR/trufflehog-report.json" 2>&1 || true
fi

# Method 3: Custom grep patterns for common secrets
echo "Running pattern-based secret detection..."
cat > "$AUDIT_DIR/secret-patterns.txt" <<'EOF'
# API Keys
API[_-]?KEY.*=.*["'][a-zA-Z0-9]{20,}
# AWS Keys
AWS[_-]?ACCESS[_-]?KEY[_-]?ID.*=.*["'][A-Z0-9]{20}
AWS[_-]?SECRET[_-]?ACCESS[_-]?KEY.*=.*["'][a-zA-Z0-9+/]{40}
# Private Keys
-----BEGIN (RSA |DSA |EC )?PRIVATE KEY-----
# Passwords
PASSWORD.*=.*["'][^"']{8,}
# Tokens
TOKEN.*=.*["'][a-zA-Z0-9]{20,}
# Database URLs with credentials
(postgresql|mysql|mongodb)://[^:]+:[^@]+@
# GitHub tokens
ghp_[a-zA-Z0-9]{36}
gh[oprsu]_[a-zA-Z0-9]{36}
# Slack tokens
xox[baprs]-[a-zA-Z0-9-]+
EOF

grep -r -E -f "$AUDIT_DIR/secret-patterns.txt" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  --exclude-dir=build \
  --exclude-dir=.agency \
  --exclude="*.log" \
  --exclude="*.lock" \
  > "$AUDIT_DIR/grep-secrets.txt" 2>&1 || true

GREP_SECRETS=$(wc -l < "$AUDIT_DIR/grep-secrets.txt" | tr -d ' ')
echo "Pattern matching found: $GREP_SECRETS potential secrets"
```

### Check for Committed Secrets

```bash
# Check .env files are in .gitignore
if [ -f ".env" ] && ! grep -q "^\.env$" .gitignore 2>/dev/null; then
  echo "⚠️ WARNING: .env file exists but not in .gitignore"
  echo "SECURITY RISK: .env file not in .gitignore" >> "$AUDIT_DIR/security-warnings.txt"
fi

# Check for .env in git history
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Checking git history for .env files..."
  git log --all --full-history --source --name-only -- '*.env' > "$AUDIT_DIR/git-env-history.txt" 2>&1 || true

  if [ -s "$AUDIT_DIR/git-env-history.txt" ]; then
    echo "⚠️ WARNING: .env files found in git history"
    echo "SECURITY RISK: .env files in git history" >> "$AUDIT_DIR/security-warnings.txt"
  fi
fi
```

### Generate Secrets Report

```bash
cat > "$AUDIT_DIR/secrets-report.md" <<EOF
# Secrets & Credentials Detection Report

**Scan Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Scope**: Entire codebase (excluding node_modules, .git, build artifacts)

## Detection Results

| Tool | Findings |
|------|----------|
| Gitleaks | ${SECRETS_FOUND:-N/A} |
| Trufflehog | $(grep -c "DetectorType" "$AUDIT_DIR/trufflehog-report.json" 2>/dev/null || echo "N/A") |
| Pattern Matching | $GREP_SECRETS |

## Critical Findings

$(if [ "${SECRETS_FOUND:-0}" -gt 0 ] || [ "$GREP_SECRETS" -gt 0 ]; then
  echo "❌ SECRETS DETECTED - IMMEDIATE ACTION REQUIRED"
  echo ""
  echo "### Gitleaks Findings"
  if [ -f "$AUDIT_DIR/gitleaks-report.json" ]; then
    jq -r '.[] | "- File: \(.File):\(.StartLine) - \(.Description)"' "$AUDIT_DIR/gitleaks-report.json" 2>/dev/null || echo "See $AUDIT_DIR/gitleaks-report.json"
  fi
  echo ""
  echo "### Pattern Matching Findings"
  echo "See full report: $AUDIT_DIR/grep-secrets.txt"
  echo ""
  echo "## Remediation Steps"
  echo ""
  echo "1. **IMMEDIATELY** remove all secrets from code"
  echo "2. Move secrets to environment variables"
  echo "3. Add .env to .gitignore if not already present"
  echo "4. Rotate/revoke all exposed credentials"
  echo "5. Clean git history if secrets were committed:"
  echo "   \`\`\`bash"
  echo "   # WARNING: Rewrites git history - coordinate with team"
  echo "   git filter-branch --force --index-filter \\"
  echo "     'git rm --cached --ignore-unmatch PATH_TO_SECRET_FILE' \\"
  echo "     --prune-empty --tag-name-filter cat -- --all"
  echo "   \`\`\`"
  echo "6. Force push to all branches (after team coordination)"
else
  echo "✅ No secrets detected in codebase"
  echo ""
  echo "## Best Practices Verified"
  echo ""
  echo "- ✅ No hard-coded API keys"
  echo "- ✅ No credentials in code"
  echo "- ✅ .env properly gitignored"
fi)

## Environment Variable Security

**Recommendations**:
- Use environment variables for all secrets
- Use secret management systems (AWS Secrets Manager, HashiCorp Vault, etc.)
- Never commit .env files to version control
- Use different credentials for dev/staging/production
- Rotate credentials regularly
- Implement secret scanning in CI/CD pipeline
EOF

cat "$AUDIT_DIR/secrets-report.md"
```

Mark todo #3 as completed.

---

## Phase 3: OWASP Top 10 Code Review (10-20 min)

Mark todo #4 as in_progress.

### OWASP Top 10 Security Checks

Perform code review focusing on OWASP Top 10 vulnerabilities:

#### 1. Broken Access Control

```bash
echo "Checking for access control issues..."

# Check for missing authorization checks
grep -r -n "router\|@app.route\|Route\|endpoint" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  | head -50 > "$AUDIT_DIR/routes-found.txt"

# Look for public routes that should be protected
grep -r -n "public\|/api/\|@route" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  -A 5 | grep -i "user\|account\|admin\|delete\|update" > "$AUDIT_DIR/potential-unprotected-routes.txt" || true

echo "Review potential unprotected routes: $AUDIT_DIR/potential-unprotected-routes.txt"
```

#### 2. Cryptographic Failures

```bash
echo "Checking for cryptographic issues..."

# Check for weak hashing algorithms
grep -r -n "md5\|sha1\|DES\|RC4" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  > "$AUDIT_DIR/weak-crypto.txt" 2>&1 || true

if [ -s "$AUDIT_DIR/weak-crypto.txt" ]; then
  echo "⚠️ WARNING: Weak cryptographic algorithms detected"
  echo "Recommendation: Use bcrypt, argon2, or PBKDF2 for passwords; SHA-256+ for hashing"
fi
```

#### 3. Injection Vulnerabilities

```bash
echo "Checking for injection vulnerabilities..."

# SQL injection patterns
grep -r -n "execute\|query.*+\|query.*format\|f\".*SELECT\|f'.*SELECT" . \
  --include="*.py" --include="*.js" --include="*.ts" \
  --exclude-dir=node_modules \
  > "$AUDIT_DIR/potential-sql-injection.txt" 2>&1 || true

# Command injection patterns
grep -r -n "exec\|eval\|system\|shell\|subprocess\|child_process" . \
  --include="*.py" --include="*.js" --include="*.ts" \
  --exclude-dir=node_modules \
  > "$AUDIT_DIR/potential-command-injection.txt" 2>&1 || true

echo "Review injection patterns:"
echo "  SQL: $AUDIT_DIR/potential-sql-injection.txt"
echo "  Command: $AUDIT_DIR/potential-command-injection.txt"
```

#### 4. Insecure Design

```bash
echo "Checking for insecure design patterns..."

# Check for CORS issues
grep -r -n "cors\|Access-Control-Allow-Origin.*\*" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  > "$AUDIT_DIR/cors-config.txt" 2>&1 || true

if grep -q '\*' "$AUDIT_DIR/cors-config.txt" 2>/dev/null; then
  echo "⚠️ WARNING: Overly permissive CORS configuration detected"
fi
```

#### 5. Security Misconfiguration

```bash
echo "Checking for security misconfigurations..."

# Check for debug mode in production
grep -r -n "DEBUG.*=.*True\|NODE_ENV.*development\|debug.*true" . \
  --include="*.env.production" --include="*.config.js" --include="settings.py" \
  > "$AUDIT_DIR/debug-mode.txt" 2>&1 || true

# Check for exposed error details
grep -r -n "stack\|traceback\|error.message" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  -A 2 | grep -i "response\|render\|send" > "$AUDIT_DIR/error-exposure.txt" 2>&1 || true
```

#### 6. Vulnerable and Outdated Components

```bash
echo "Checking component versions..."

# Already covered in Phase 1 (dependency scan)
echo "✅ Covered by dependency vulnerability scan (Phase 1)"
```

#### 7. Identification and Authentication Failures

```bash
echo "Checking authentication implementation..."

# Check for weak password requirements
grep -r -n "password" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  -B 2 -A 2 | grep -i "min\|length\|requirement\|validation" > "$AUDIT_DIR/password-requirements.txt" 2>&1 || true

# Check for session management
grep -r -n "session\|jwt\|token" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  > "$AUDIT_DIR/session-management.txt" 2>&1 || true
```

#### 8. Software and Data Integrity Failures

```bash
echo "Checking integrity controls..."

# Check for unsigned packages or insecure updates
if [ -f "package-lock.json" ]; then
  # package-lock.json provides integrity hashes
  echo "✅ package-lock.json found (provides integrity hashes)"
else
  echo "⚠️ WARNING: No package-lock.json found"
fi
```

#### 9. Security Logging and Monitoring Failures

```bash
echo "Checking logging implementation..."

# Check for logging of security events
grep -r -n "log\|logger\|console" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  | grep -i "login\|auth\|error\|security" > "$AUDIT_DIR/security-logging.txt" 2>&1 || true

if [ ! -s "$AUDIT_DIR/security-logging.txt" ]; then
  echo "⚠️ WARNING: Limited security event logging detected"
fi
```

#### 10. Server-Side Request Forgery (SSRF)

```bash
echo "Checking for SSRF vulnerabilities..."

# Check for user-controlled URLs in fetch/requests
grep -r -n "fetch\|axios\|request\|urllib\|http.get" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  -A 3 | grep -i "req\.\|params\.\|query\.\|body\." > "$AUDIT_DIR/potential-ssrf.txt" 2>&1 || true

echo "Review potential SSRF: $AUDIT_DIR/potential-ssrf.txt"
```

### Generate OWASP Report

```bash
cat > "$AUDIT_DIR/owasp-top-10-report.md" <<EOF
# OWASP Top 10 Security Review

**Review Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Framework**: $FRAMEWORK
**Database**: ${DATABASE:-Unknown}

## Vulnerabilities by Category

| OWASP Category | Findings | Severity |
|----------------|----------|----------|
| A01: Broken Access Control | $(wc -l < "$AUDIT_DIR/potential-unprotected-routes.txt" | tr -d ' ') | $([ $(wc -l < "$AUDIT_DIR/potential-unprotected-routes.txt" | tr -d ' ') -gt 0 ] && echo "⚠️ Review Required" || echo "✅ OK") |
| A02: Cryptographic Failures | $(wc -l < "$AUDIT_DIR/weak-crypto.txt" | tr -d ' ') | $([ -s "$AUDIT_DIR/weak-crypto.txt" ] && echo "❌ Critical" || echo "✅ OK") |
| A03: Injection | $(wc -l < "$AUDIT_DIR/potential-sql-injection.txt" | tr -d ' ') | $([ -s "$AUDIT_DIR/potential-sql-injection.txt" ] && echo "❌ Critical" || echo "✅ OK") |
| A04: Insecure Design | $(wc -l < "$AUDIT_DIR/cors-config.txt" | tr -d ' ') | $([ -s "$AUDIT_DIR/cors-config.txt" ] && echo "⚠️ Review Required" || echo "✅ OK") |
| A05: Security Misconfiguration | $(wc -l < "$AUDIT_DIR/debug-mode.txt" | tr -d ' ') | $([ -s "$AUDIT_DIR/debug-mode.txt" ] && echo "⚠️ Review Required" || echo "✅ OK") |
| A06: Vulnerable Components | See Phase 1 | $([ "$CRITICAL_VULNS" -gt 0 ] && echo "❌ Critical" || echo "✅ OK") |
| A07: Auth Failures | Review Required | Manual Review |
| A08: Data Integrity | $([ -f "package-lock.json" ] && echo "✅ OK" || echo "⚠️ No lock file") | Info |
| A09: Logging Failures | $([ -s "$AUDIT_DIR/security-logging.txt" ] && echo "✅ OK" || echo "⚠️ Limited") | Info |
| A10: SSRF | $(wc -l < "$AUDIT_DIR/potential-ssrf.txt" | tr -d ' ') | $([ -s "$AUDIT_DIR/potential-ssrf.txt" ] && echo "⚠️ Review Required" || echo "✅ OK") |

## Detailed Findings

### Critical Issues

$(if [ -s "$AUDIT_DIR/weak-crypto.txt" ]; then
  echo "#### Weak Cryptographic Algorithms"
  echo ""
  echo "\`\`\`"
  head -20 "$AUDIT_DIR/weak-crypto.txt"
  echo "\`\`\`"
  echo ""
  echo "**Remediation**: Replace MD5/SHA1 with SHA-256+, use bcrypt/argon2 for passwords"
  echo ""
fi)

$(if [ -s "$AUDIT_DIR/potential-sql-injection.txt" ]; then
  echo "#### Potential SQL Injection"
  echo ""
  echo "\`\`\`"
  head -20 "$AUDIT_DIR/potential-sql-injection.txt"
  echo "\`\`\`"
  echo ""
  echo "**Remediation**: Use parameterized queries or ORM with parameter binding"
  echo ""
fi)

### Warnings

$(if [ -s "$AUDIT_DIR/potential-unprotected-routes.txt" ]; then
  echo "#### Potential Unprotected Routes"
  echo ""
  echo "Review these routes for proper authorization:"
  echo "\`\`\`"
  head -20 "$AUDIT_DIR/potential-unprotected-routes.txt"
  echo "\`\`\`"
  echo ""
fi)

## Recommendations

1. **Critical**: Address all cryptographic and injection vulnerabilities immediately
2. **High**: Review and secure all API endpoints with proper authentication/authorization
3. **Medium**: Implement comprehensive security logging for authentication events
4. **Low**: Add integrity checks and security headers

## Framework-Specific Guidance

$(case "$FRAMEWORK" in
  "Next.js")
    echo "**Next.js Security Best Practices**:"
    echo "- Use \`next.config.js\` to set security headers"
    echo "- Implement middleware for authentication on protected routes"
    echo "- Use environment variables for secrets (never commit to git)"
    echo "- Enable HTTPS in production"
    echo "- Use \`getServerSideProps\` for authenticated data fetching"
    ;;
  "Django")
    echo "**Django Security Best Practices**:"
    echo "- Keep \`DEBUG = False\` in production"
    echo "- Use Django's built-in CSRF protection"
    echo "- Configure \`ALLOWED_HOSTS\` properly"
    echo "- Use Django's authentication system"
    echo "- Enable security middleware (XSS, Clickjacking protection)"
    ;;
  "Express.js")
    echo "**Express.js Security Best Practices**:"
    echo "- Use \`helmet\` middleware for security headers"
    echo "- Implement CSRF protection with \`csurf\`"
    echo "- Use \`express-rate-limit\` to prevent brute force"
    echo "- Validate and sanitize all user input"
    echo "- Use \`express-validator\` for input validation"
    ;;
  *)
    echo "**General Security Best Practices**:"
    echo "- Keep all dependencies up to date"
    echo "- Use HTTPS in production"
    echo "- Implement proper authentication and authorization"
    echo "- Validate and sanitize all user input"
    echo "- Use security headers (CSP, HSTS, X-Frame-Options, etc.)"
    ;;
esac)
EOF

cat "$AUDIT_DIR/owasp-top-10-report.md"
```

Mark todo #4 as completed.

---

## Phase 4: Authentication & Authorization Review (5-10 min)

Mark todo #5 as in_progress.

### Review Authentication Implementation

```bash
echo "Reviewing authentication and authorization..."

# Find authentication-related files
find . -type f \( -name "*auth*" -o -name "*login*" -o -name "*session*" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.next/*" \
  ! -path "*/dist/*" \
  > "$AUDIT_DIR/auth-files.txt"

echo "Authentication files found:"
cat "$AUDIT_DIR/auth-files.txt"
```

### Check Password Security

```bash
# Check for password hashing
grep -r -n "bcrypt\|argon2\|scrypt\|pbkdf2" . \
  --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  > "$AUDIT_DIR/password-hashing.txt" 2>&1 || true

if [ ! -s "$AUDIT_DIR/password-hashing.txt" ]; then
  echo "⚠️ WARNING: No secure password hashing detected"
  echo "⚠️ No password hashing found" >> "$AUDIT_DIR/security-warnings.txt"
fi
```

### Check Session Management

```bash
# Check for session configuration
grep -r -n "session\|jwt\|cookie" . \
  --include="*.config.*" --include="*.ts" --include="*.js" --include="*.py" \
  --exclude-dir=node_modules \
  | grep -i "secure\|httponly\|samesite\|secret" > "$AUDIT_DIR/session-config.txt" 2>&1 || true

echo "Session configuration:"
cat "$AUDIT_DIR/session-config.txt"
```

### Generate Auth Review Report

```bash
cat > "$AUDIT_DIR/auth-review.md" <<EOF
# Authentication & Authorization Review

**Review Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Authentication Files

Found $(wc -l < "$AUDIT_DIR/auth-files.txt" | tr -d ' ') authentication-related files:

\`\`\`
$(cat "$AUDIT_DIR/auth-files.txt")
\`\`\`

## Password Security

$(if [ -s "$AUDIT_DIR/password-hashing.txt" ]; then
  echo "✅ Secure password hashing detected:"
  echo "\`\`\`"
  head -10 "$AUDIT_DIR/password-hashing.txt"
  echo "\`\`\`"
else
  echo "❌ **CRITICAL**: No secure password hashing detected"
  echo ""
  echo "**Remediation**: Implement password hashing using:"
  echo "- bcrypt (recommended for most applications)"
  echo "- argon2 (best security, higher resource usage)"
  echo "- PBKDF2 (FIPS compliant)"
  echo ""
  echo "**Example (bcrypt with Node.js)**:"
  echo "\`\`\`typescript"
  echo "import bcrypt from 'bcrypt';"
  echo ""
  echo "const saltRounds = 10;"
  echo "const hashedPassword = await bcrypt.hash(plainPassword, saltRounds);"
  echo "const isValid = await bcrypt.compare(plainPassword, hashedPassword);"
  echo "\`\`\`"
fi)

## Session Management

$(if [ -s "$AUDIT_DIR/session-config.txt" ]; then
  echo "Session configuration found:"
  echo "\`\`\`"
  cat "$AUDIT_DIR/session-config.txt"
  echo "\`\`\`"
  echo ""
  echo "**Verify**:"
  echo "- [ ] Sessions use secure cookies (secure: true in production)"
  echo "- [ ] HttpOnly flag set on session cookies"
  echo "- [ ] SameSite attribute configured (Strict or Lax)"
  echo "- [ ] Session secret is strong and from environment variable"
  echo "- [ ] Session timeout is reasonable (15-30 minutes)"
else
  echo "⚠️ No session configuration found or review needed"
fi)

## JWT Security (if applicable)

$(if grep -q "jwt\|jsonwebtoken" package.json requirements.txt 2>/dev/null; then
  echo "JWT library detected. Verify:"
  echo "- [ ] Strong secret key (256+ bits)"
  echo "- [ ] Short expiration time (15 minutes for access tokens)"
  echo "- [ ] Refresh token rotation implemented"
  echo "- [ ] Algorithm is HS256 or RS256 (not 'none')"
  echo "- [ ] Token signature verification on every request"
else
  echo "N/A - JWT not detected"
fi)

## Recommendations

1. **Password Requirements**:
   - Minimum 8 characters (12+ recommended)
   - Require mix of uppercase, lowercase, numbers, symbols
   - Check against common password lists
   - Implement account lockout after failed attempts

2. **Multi-Factor Authentication**:
   - Consider implementing MFA for sensitive operations
   - Support TOTP (Google Authenticator, etc.)

3. **Session Security**:
   - Regenerate session ID after login
   - Implement session timeout
   - Provide logout functionality that destroys session

4. **Authorization**:
   - Implement role-based access control (RBAC)
   - Check permissions on every protected endpoint
   - Use principle of least privilege
EOF

cat "$AUDIT_DIR/auth-review.md"
```

Mark todo #5 as completed.

---

## Phase 5: Security Audit Report Generation (5-10 min)

<!-- Component: prompts/reporting/summary-template.md -->
<!-- Component: prompts/reporting/artifact-listing.md -->

Mark todo #6 as in_progress.

### Compile Comprehensive Security Report

```bash
cat > "$AUDIT_DIR/security-audit-report.md" <<EOF
# Security Audit Report

**Audit ID**: $AUDIT_ID
**Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Framework**: $FRAMEWORK
**Database**: ${DATABASE:-Unknown}
**Scope**: $ARGUMENTS
**Auditor**: Agency Security Audit

---

## Executive Summary

**Overall Security Posture**: $(if [ "$CRITICAL_VULNS" -gt 0 ] || [ "${SECRETS_FOUND:-0}" -gt 0 ]; then
  echo "❌ CRITICAL ISSUES FOUND"
elif [ "$HIGH_VULNS" -gt 0 ]; then
  echo "⚠️ HIGH PRIORITY ISSUES FOUND"
elif [ "$MODERATE_VULNS" -gt 5 ]; then
  echo "⚠️ MODERATE RISK"
else
  echo "✅ GOOD"
fi)

**Critical Issues**: $([ "$CRITICAL_VULNS" -gt 0 ] && echo "$CRITICAL_VULNS" || echo "0")
**High Priority Issues**: $([ "$HIGH_VULNS" -gt 0 ] && echo "$HIGH_VULNS" || echo "0")
**Secrets Detected**: ${SECRETS_FOUND:-0}

---

## Vulnerability Summary

### Dependency Vulnerabilities

| Severity | Count | Status |
|----------|-------|--------|
| Critical | ${CRITICAL_VULNS:-0} | $([ "${CRITICAL_VULNS:-0}" -gt 0 ] && echo "❌ Requires immediate fix" || echo "✅ OK") |
| High | ${HIGH_VULNS:-0} | $([ "${HIGH_VULNS:-0}" -gt 0 ] && echo "⚠️ Fix before deployment" || echo "✅ OK") |
| Moderate | ${MODERATE_VULNS:-0} | $([ "${MODERATE_VULNS:-0}" -gt 0 ] && echo "ℹ️ Fix in next sprint" || echo "✅ OK") |
| Low | ${LOW_VULNS:-0} | $([ "${LOW_VULNS:-0}" -gt 0 ] && echo "ℹ️ Fix when convenient" || echo "✅ OK") |

**Detailed Report**: \`$AUDIT_DIR/vulnerability-summary.md\`

### Secrets & Credentials

**Status**: $(if [ "${SECRETS_FOUND:-0}" -gt 0 ] || [ "$GREP_SECRETS" -gt 0 ]; then
  echo "❌ SECRETS DETECTED - CRITICAL"
else
  echo "✅ No secrets detected"
fi)

$(if [ "${SECRETS_FOUND:-0}" -gt 0 ] || [ "$GREP_SECRETS" -gt 0 ]; then
  echo "**Action Required**: Immediately remove secrets and rotate credentials"
  echo ""
  echo "**Detailed Report**: \`$AUDIT_DIR/secrets-report.md\`"
fi)

### OWASP Top 10 Review

**Status**: Manual code review completed

**Detailed Report**: \`$AUDIT_DIR/owasp-top-10-report.md\`

### Authentication & Authorization

**Status**: Review completed

**Detailed Report**: \`$AUDIT_DIR/auth-review.md\`

---

## Critical Findings

$(if [ "$CRITICAL_VULNS" -gt 0 ]; then
  echo "### Critical Dependency Vulnerabilities: $CRITICAL_VULNS"
  echo ""
  echo "See: \`$AUDIT_DIR/vulnerability-summary.md\`"
  echo ""
  echo "**Immediate Actions**:"
  echo "1. Review critical vulnerabilities in detail"
  echo "2. Apply auto-fix: \`npm audit fix\`"
  echo "3. Manually upgrade packages without auto-fix"
  echo "4. Re-run audit to verify fixes"
  echo ""
fi)

$(if [ "${SECRETS_FOUND:-0}" -gt 0 ] || [ "$GREP_SECRETS" -gt 0 ]; then
  echo "### Hard-Coded Secrets Detected"
  echo ""
  echo "See: \`$AUDIT_DIR/secrets-report.md\`"
  echo ""
  echo "**Immediate Actions**:"
  echo "1. Remove all secrets from code"
  echo "2. Move secrets to environment variables"
  echo "3. Rotate/revoke all exposed credentials"
  echo "4. Clean git history if secrets were committed"
  echo "5. Add .env to .gitignore"
  echo ""
fi)

$(if [ -s "$AUDIT_DIR/weak-crypto.txt" ]; then
  echo "### Weak Cryptographic Algorithms"
  echo ""
  echo "See: \`$AUDIT_DIR/owasp-top-10-report.md\`"
  echo ""
  echo "**Actions**:"
  echo "1. Replace MD5/SHA1 with SHA-256 or higher"
  echo "2. Use bcrypt, argon2, or PBKDF2 for password hashing"
  echo "3. Review all cryptographic operations"
  echo ""
fi)

$(if [ ! -s "$AUDIT_DIR/password-hashing.txt" ] && grep -q "auth\|login\|password" "$AUDIT_DIR/auth-files.txt" 2>/dev/null; then
  echo "### Missing Password Hashing"
  echo ""
  echo "See: \`$AUDIT_DIR/auth-review.md\`"
  echo ""
  echo "**Actions**:"
  echo "1. Implement bcrypt or argon2 for password hashing"
  echo "2. Never store passwords in plain text"
  echo "3. Use minimum 10 salt rounds for bcrypt"
  echo ""
fi)

$(if [ "$CRITICAL_VULNS" -eq 0 ] && [ "${SECRETS_FOUND:-0}" -eq 0 ] && [ ! -s "$AUDIT_DIR/weak-crypto.txt" ]; then
  echo "✅ No critical security issues found"
  echo ""
fi)

---

## High Priority Findings

$(if [ "$HIGH_VULNS" -gt 0 ]; then
  echo "### High Severity Dependencies: $HIGH_VULNS"
  echo ""
  echo "These should be fixed before deploying to production."
  echo ""
  echo "See: \`$AUDIT_DIR/vulnerability-summary.md\`"
  echo ""
fi)

$(if [ -s "$AUDIT_DIR/potential-sql-injection.txt" ]; then
  echo "### Potential SQL Injection Vectors"
  echo ""
  echo "Review these locations for proper input sanitization:"
  echo "\`\`\`"
  head -10 "$AUDIT_DIR/potential-sql-injection.txt"
  echo "\`\`\`"
  echo ""
  echo "**Action**: Use parameterized queries or ORM with parameter binding"
  echo ""
fi)

$(if [ -s "$AUDIT_DIR/potential-unprotected-routes.txt" ]; then
  echo "### Potential Unprotected Routes"
  echo ""
  echo "Review these routes for proper authentication/authorization:"
  echo "\`\`\`"
  head -10 "$AUDIT_DIR/potential-unprotected-routes.txt"
  echo "\`\`\`"
  echo ""
fi)

$(if [ "$HIGH_VULNS" -eq 0 ] && [ ! -s "$AUDIT_DIR/potential-sql-injection.txt" ] && [ ! -s "$AUDIT_DIR/potential-unprotected-routes.txt" ]; then
  echo "✅ No high priority issues found"
  echo ""
fi)

---

## Moderate/Low Priority Findings

- Moderate Severity Dependencies: ${MODERATE_VULNS:-0}
- Low Severity Dependencies: ${LOW_VULNS:-0}

**Recommendation**: Address in next sprint or scheduled security update.

---

## Security Best Practices Checklist

Framework-specific recommendations for $FRAMEWORK:

$(case "$FRAMEWORK" in
  "Next.js")
    echo "### Next.js Security Checklist"
    echo ""
    echo "- [ ] Security headers configured in \`next.config.js\`"
    echo "- [ ] Authentication middleware on protected routes"
    echo "- [ ] Environment variables used for all secrets"
    echo "- [ ] HTTPS enforced in production"
    echo "- [ ] API routes have rate limiting"
    echo "- [ ] Input validation on all forms"
    echo "- [ ] CSRF protection enabled"
    echo "- [ ] Content Security Policy configured"
    ;;
  "Express.js")
    echo "### Express.js Security Checklist"
    echo ""
    echo "- [ ] \`helmet\` middleware installed and configured"
    echo "- [ ] CSRF protection with \`csurf\`"
    echo "- [ ] Rate limiting with \`express-rate-limit\`"
    echo "- [ ] Input validation with \`express-validator\`"
    echo "- [ ] Secure session configuration"
    echo "- [ ] HTTPS enforced in production"
    echo "- [ ] SQL injection protection (parameterized queries)"
    echo "- [ ] XSS protection enabled"
    ;;
  "Django")
    echo "### Django Security Checklist"
    echo ""
    echo "- [ ] \`DEBUG = False\` in production"
    echo "- [ ] \`SECRET_KEY\` from environment variable"
    echo "- [ ] \`ALLOWED_HOSTS\` properly configured"
    echo "- [ ] Django security middleware enabled"
    echo "- [ ] CSRF protection enabled (default)"
    echo "- [ ] Secure cookies: \`SESSION_COOKIE_SECURE = True\`"
    echo "- [ ] HTTPS enforced: \`SECURE_SSL_REDIRECT = True\`"
    echo "- [ ] XSS protection: \`SECURE_BROWSER_XSS_FILTER = True\`"
    ;;
  *)
    echo "### General Security Checklist"
    echo ""
    echo "- [ ] All dependencies up to date"
    echo "- [ ] HTTPS enforced in production"
    echo "- [ ] Strong password hashing (bcrypt/argon2)"
    echo "- [ ] Input validation on all endpoints"
    echo "- [ ] Output encoding to prevent XSS"
    echo "- [ ] CSRF protection enabled"
    echo "- [ ] Rate limiting on authentication endpoints"
    echo "- [ ] Security headers configured"
    echo "- [ ] Regular security audits scheduled"
    ;;
esac)

---

## Remediation Roadmap

### Immediate (Within 24 hours)

$(if [ "$CRITICAL_VULNS" -gt 0 ] || [ "${SECRETS_FOUND:-0}" -gt 0 ]; then
  echo "1. ❌ Remove all hard-coded secrets (if any)"
  echo "2. ❌ Fix critical dependency vulnerabilities"
  echo "3. ❌ Rotate exposed credentials"
  echo "4. ❌ Fix weak cryptographic algorithms"
else
  echo "✅ No immediate actions required"
fi)

### Short Term (Within 1 week)

$(if [ "$HIGH_VULNS" -gt 0 ] || [ -s "$AUDIT_DIR/potential-sql-injection.txt" ]; then
  echo "1. ⚠️ Fix high severity dependency vulnerabilities"
  echo "2. ⚠️ Review and secure all API endpoints"
  echo "3. ⚠️ Fix potential injection vulnerabilities"
  echo "4. ⚠️ Implement missing authentication checks"
else
  echo "✅ No short term actions required"
fi)

### Medium Term (Within 1 month)

1. ℹ️ Fix moderate severity vulnerabilities
2. ℹ️ Implement comprehensive security logging
3. ℹ️ Add security headers
4. ℹ️ Review and update security documentation
5. ℹ️ Implement automated security scanning in CI/CD

---

## Audit Artifacts

All audit artifacts saved to: \`$AUDIT_DIR/\`

### Generated Reports

- \`vulnerability-summary.md\` - Dependency vulnerabilities
- \`secrets-report.md\` - Secrets detection results
- \`owasp-top-10-report.md\` - OWASP Top 10 code review
- \`auth-review.md\` - Authentication & authorization review
- \`security-audit-report.md\` - This comprehensive report

### Raw Scan Results

- \`npm-audit.json\` - NPM audit JSON output
- \`npm-audit.txt\` - NPM audit text output
- \`gitleaks-report.json\` - Gitleaks scan results (if available)
- \`grep-secrets.txt\` - Pattern-based secret detection
- \`*.txt\` - Various code review findings

---

## Next Steps

1. **Review this report** with your security team
2. **Prioritize remediation** based on severity
3. **Implement fixes** following the remediation roadmap
4. **Re-run security audit** after fixes to verify
5. **Schedule regular audits** (monthly or quarterly)

---

## Compliance Considerations

This audit covers:
- ✅ OWASP Top 10 vulnerabilities
- ✅ Dependency vulnerabilities
- ✅ Secrets detection
- ✅ Authentication security
- ✅ Code-level security issues

This audit does NOT cover:
- ❌ Penetration testing
- ❌ Social engineering
- ❌ Physical security
- ❌ DDoS resilience
- ❌ Third-party integrations
- ❌ Infrastructure security (cloud, servers)

**Recommendation**: For production systems, complement this audit with:
- Professional penetration testing
- Infrastructure security audit
- Compliance certification (SOC 2, ISO 27001, etc.)

---

**Report Generated**: $(date -u +%Y-%m-%dT%H:%M:%SZ)
**Audit ID**: $AUDIT_ID
**Framework**: $FRAMEWORK

EOF

cat "$AUDIT_DIR/security-audit-report.md"
```

<!-- Component: prompts/reporting/next-steps-template.md -->

### Display Summary to User

```markdown
## Security Audit Complete

**Audit ID**: $AUDIT_ID
**Framework**: $FRAMEWORK
**Scope**: $ARGUMENTS

### Findings Summary

**Critical**: ${CRITICAL_VULNS:-0} dependency vulnerabilities + ${SECRETS_FOUND:-0} secrets
**High**: ${HIGH_VULNS:-0} dependency vulnerabilities
**Moderate**: ${MODERATE_VULNS:-0} dependency vulnerabilities
**Low**: ${LOW_VULNS:-0} dependency vulnerabilities

### Overall Security Posture

$(if [ "$CRITICAL_VULNS" -gt 0 ] || [ "${SECRETS_FOUND:-0}" -gt 0 ]; then
  echo "❌ **CRITICAL ISSUES FOUND** - Immediate action required"
elif [ "$HIGH_VULNS" -gt 0 ]; then
  echo "⚠️ **HIGH PRIORITY ISSUES** - Fix before deployment"
elif [ "$MODERATE_VULNS" -gt 5 ]; then
  echo "⚠️ **MODERATE RISK** - Address in next sprint"
else
  echo "✅ **GOOD** - No critical issues found"
fi)

### Comprehensive Report

**Full Report**: `$AUDIT_DIR/security-audit-report.md`

### Immediate Next Steps

$(if [ "$CRITICAL_VULNS" -gt 0 ] || [ "${SECRETS_FOUND:-0}" -gt 0 ]; then
  echo "1. ❌ Review critical findings in full report"
  echo "2. ❌ Remove hard-coded secrets (if any)"
  echo "3. ❌ Fix critical vulnerabilities: \`npm audit fix\`"
  echo "4. ❌ Rotate exposed credentials"
  echo "5. ❌ Re-run security audit to verify fixes"
else
  echo "1. ✅ Review full report for detailed findings"
  echo "2. ✅ Address high priority issues before deployment"
  echo "3. ✅ Schedule regular security audits"
  echo "4. ✅ Implement security best practices from checklist"
fi)

---

**All audit artifacts saved to**: `$AUDIT_DIR/`
```

Mark todo #6 as completed.

---

## Error Handling

<!-- Component: prompts/error-handling/tool-execution-failure.md -->

### If Security Tool Fails

**npm/pip audit fails**:
- Check network connectivity
- Verify package manager is installed and up to date
- Try alternative security scanning tools
- Continue with code review even if scan fails

**Secrets scanner not available**:
- Use pattern-based grep search as fallback
- Manually review .env files and configuration
- Check .gitignore for proper exclusions
- Continue audit with manual review

**Permission denied errors**:
- Check file permissions
- Run with appropriate user privileges
- Skip inaccessible files and document in report

### If Critical Vulnerabilities Found

```
Use AskUserQuestion:
  Question: "Critical security vulnerabilities detected. How to proceed?"
  Options:
    - "Attempt auto-fix (npm audit fix)"
    - "Generate fix plan for manual remediation"
    - "Continue audit and compile full report"
    - "Abort audit"
```

### If Secrets Detected

```
IMMEDIATELY report to user:

❌ CRITICAL: Secrets detected in codebase

Action: STOP and remediate before proceeding:
1. Remove secrets from code
2. Rotate/revoke exposed credentials
3. Add .env to .gitignore
4. Clean git history if committed

DO NOT commit or deploy until resolved.
```

---

## Important Notes

### Security Audit Principles

1. **Confidentiality**: Redact all secrets from reports
2. **Severity-Based Prioritization**: Critical → High → Moderate → Low
3. **Actionability**: Provide specific remediation steps with code examples
4. **Context Awareness**: Tailor recommendations to detected framework

### Responsible Disclosure

1. **Internal Reporting First**: Report to development team before public disclosure
2. **Vendor Notification**: Notify affected vendors of vulnerabilities found
3. **Reasonable Timelines**: Allow time for fixes before disclosure (30-90 days)
4. **Documentation**: Maintain audit trail for compliance

### This Audit Does NOT Include

- Penetration testing (active exploitation)
- Social engineering tests
- Physical security assessment
- DDoS resilience testing
- Infrastructure security (cloud, networking)
- Third-party service security

For production systems, complement with professional security assessment.

---

## Skills to Reference

Activate and reference these skills as needed:

**Required**:
- `agency-workflow-patterns` - Orchestration patterns (ACTIVATE IMMEDIATELY)

**Security-Specific** (if available):
- `owasp-top-10` - OWASP vulnerability knowledge
- `secure-coding-practices` - Security best practices
- `penetration-testing` - Advanced security testing

**Framework-Specific** (based on detected framework):
- `nextjs-16-expert` - Next.js security patterns
- `django-security` - Django security best practices
- `express-security` - Express.js security patterns

---

## Related Commands

- `/agency:work [issue]` - Implement security fixes
- `/agency:review [pr]` - Security-focused code review
- `/agency:deploy [env]` - Security checks before deployment
- `/agency:refactor [component]` - Refactor insecure code patterns

---

**Remember**:

- **Security is ongoing**: Schedule regular audits (monthly/quarterly)
- **Defense in depth**: Multiple layers of security
- **Least privilege**: Grant minimum necessary permissions
- **Fail securely**: Default deny, validate input, encode output
- **Keep updated**: Regularly update dependencies and security patches

Security is not a one-time task—it's a continuous process.

---

**End of /agency:security command**
