---
description: Provider-agnostic deployment workflow with pre-flight checks and verification
argument-hint: environment (staging/production) or platform (vercel/netlify/aws/docker)
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion]
---

# Deploy Application: $ARGUMENTS

Automated deployment workflow with pre-flight checks, environment validation, and post-deploy verification.

## Your Mission

Deploy to: **$ARGUMENTS**

Execute safe, verified deployment:
- Environment detection and validation
- Pre-flight checks (tests, build, security)
- Platform-specific deployment
- Health checks and smoke tests
- Rollback capability
- Deployment report

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and workflow strategies you MUST follow.

### 2. Deployment Safety Principles

**NEVER**:
- Deploy without running tests
- Skip build verification
- Deploy with known security vulnerabilities
- Deploy to production without staging verification
- Ignore rollback failures

**ALWAYS**:
- Run all quality gates before deployment
- Verify environment configuration
- Create deployment backup/snapshot
- Monitor deployment progress
- Verify application health after deployment
- Have rollback plan ready

### 3. Use TodoWrite Throughout

<!-- Component: prompts/progress/todo-initialization.md -->

Track deployment progress with TodoWrite for transparency and rollback reference.

**Initialize deployment todo list**:

```javascript
[
  {
    "content": "Validate deployment environment",
    "status": "in_progress",
    "activeForm": "Validating deployment environment"
  },
  {
    "content": "Run pre-flight checks (tests, build, security)",
    "status": "pending",
    "activeForm": "Running pre-flight checks"
  },
  {
    "content": "Create deployment snapshot/backup",
    "status": "pending",
    "activeForm": "Creating deployment snapshot/backup"
  },
  {
    "content": "Execute deployment",
    "status": "pending",
    "activeForm": "Executing deployment"
  },
  {
    "content": "Run post-deployment verification",
    "status": "pending",
    "activeForm": "Running post-deployment verification"
  },
  {
    "content": "Generate deployment report",
    "status": "pending",
    "activeForm": "Generating deployment report"
  }
]
```

---

## Phase 0: Project Context Detection (1-2 min)

<!-- Component: prompts/context/framework-detection.md -->

Quickly gather project context to determine deployment strategy.

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

### Detect Deployment Platform

```bash
# Check for deployment platform configuration
if [ -f "vercel.json" ] || [ -d ".vercel" ]; then
  PLATFORM="Vercel"
  DETECTED="Yes"
fi

if [ -f "netlify.toml" ] || [ -d ".netlify" ]; then
  PLATFORM="Netlify"
  DETECTED="Yes"
fi

if [ -f "Dockerfile" ]; then
  PLATFORM="Docker"
  DETECTED="Yes"

  # Check for Kubernetes
  if [ -d "k8s" ] || [ -f "kubernetes.yaml" ]; then
    PLATFORM="Kubernetes"
  fi
fi

# AWS detection
if [ -f "serverless.yml" ]; then
  PLATFORM="AWS Serverless (Serverless Framework)"
  DETECTED="Yes"
elif [ -d ".aws-sam" ] || [ -f "template.yaml" ]; then
  PLATFORM="AWS SAM"
  DETECTED="Yes"
elif [ -f "amplify.yml" ]; then
  PLATFORM="AWS Amplify"
  DETECTED="Yes"
fi

# Heroku
if [ -f "Procfile" ] && [ -f "app.json" ]; then
  PLATFORM="Heroku"
  DETECTED="Yes"
fi

echo "Detected platform: $PLATFORM"
echo "Framework: $FRAMEWORK"
```

**Use this context to**:
- Select appropriate deployment commands
- Validate environment configuration
- Choose deployment strategy (build, containerize, serverless)
- Set up health checks

---

## Phase 1: Environment & Target Detection (2-3 min)

Mark todo #1 as in_progress.

### Parse Deployment Argument

Analyze `$ARGUMENTS` to determine deployment target:

**Environment-Based** if:
- `$ARGUMENTS` = "staging" or "stage" or "preview"
- `$ARGUMENTS` = "production" or "prod" or "live"
- `$ARGUMENTS` = "development" or "dev"

**Platform-Based** if:
- `$ARGUMENTS` = "vercel" or "netlify" or "aws" or "heroku" etc.
- Override auto-detected platform

**Auto-Detect** if:
- `$ARGUMENTS` = "auto" or empty
- Use detected platform and infer environment from branch

### Determine Environment

```bash
# If not explicitly specified, infer from git branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

case "$CURRENT_BRANCH" in
  main|master)
    ENVIRONMENT="production"
    ;;
  staging|stage)
    ENVIRONMENT="staging"
    ;;
  develop|dev)
    ENVIRONMENT="development"
    ;;
  *)
    ENVIRONMENT="preview"
    ;;
esac

echo "Deployment environment: $ENVIRONMENT"
```

### Get User Confirmation

<!-- Component: prompts/error-handling/ask-user-retry.md -->

Use AskUserQuestion to confirm deployment:

```
Question: "Deploy to $ENVIRONMENT using $PLATFORM?"
Options:
  - "Yes, proceed with deployment (Recommended)"
  - "Change environment to staging"
  - "Change environment to production"
  - "Change deployment platform"
  - "Cancel deployment"
```

If deploying to production, add extra confirmation:

```
Question: "⚠️ PRODUCTION DEPLOYMENT - Are you sure?"
Options:
  - "Yes, deploy to production"
  - "No, cancel deployment"
```

Mark todo #1 as completed.

---

## Phase 2: Pre-Flight Checks (10-30 min)

<!-- Component: prompts/quality-gates/quality-gate-sequence.md -->

Mark todo #2 as in_progress.

### Create Deployment Directory

```bash
# Create deployment tracking directory
mkdir -p .agency/deployments
DEPLOYMENT_ID="deploy-$(date +%Y%m%d-%H%M%S)"
DEPLOYMENT_DIR=".agency/deployments/$DEPLOYMENT_ID"
mkdir -p "$DEPLOYMENT_DIR"

echo "Deployment ID: $DEPLOYMENT_ID"
echo "Tracking directory: $DEPLOYMENT_DIR"
```

### Git Status Check

<!-- Component: prompts/git/status-validation.md -->

```bash
echo "Checking git status..."

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
  echo "✗ WARNING: Uncommitted changes detected"
  git status --short > "$DEPLOYMENT_DIR/uncommitted-changes.txt"

  # Ask user what to do
  Use AskUserQuestion:
    Question: "Uncommitted changes detected. How to proceed?"
    Options:
      - "Commit changes before deploying"
      - "Stash changes and deploy"
      - "Deploy anyway (not recommended)"
      - "Cancel deployment"
fi

# Check current commit
DEPLOY_COMMIT=$(git rev-parse HEAD)
DEPLOY_COMMIT_MSG=$(git log -1 --pretty=%B)

echo "Deploying commit: $DEPLOY_COMMIT"
echo "$DEPLOY_COMMIT" > "$DEPLOYMENT_DIR/commit-hash.txt"
echo "$DEPLOY_COMMIT_MSG" > "$DEPLOYMENT_DIR/commit-message.txt"
```

### Execute Quality Gate Sequence

Run all quality gates in order. **Do NOT skip any gate.**

<!-- Component: prompts/quality-gates/build-verification.md -->

#### Gate 1: Build (CRITICAL)

```bash
echo "Running build verification..."

# Detect build command
if [ -f "package.json" ]; then
  if grep -q '"build":' package.json; then
    BUILD_COMMAND="npm run build"
  fi
elif [ -f "Cargo.toml" ]; then
  BUILD_COMMAND="cargo build --release"
elif [ -f "Makefile" ]; then
  BUILD_COMMAND="make build"
fi

if [ -n "$BUILD_COMMAND" ]; then
  echo "Running: $BUILD_COMMAND"

  # Set production environment
  NODE_ENV=production $BUILD_COMMAND > "$DEPLOYMENT_DIR/build-output.txt" 2>&1

  if [ $? -eq 0 ]; then
    echo "✓ Build succeeded"

    # Capture build size
    if [ -d ".next" ]; then
      du -sh .next > "$DEPLOYMENT_DIR/build-size.txt"
    elif [ -d "dist" ]; then
      du -sh dist > "$DEPLOYMENT_DIR/build-size.txt"
    elif [ -d "build" ]; then
      du -sh build > "$DEPLOYMENT_DIR/build-size.txt"
    fi
  else
    echo "✗ Build failed"
    tail -50 "$DEPLOYMENT_DIR/build-output.txt"

    echo "❌ DEPLOYMENT BLOCKED: Build failed"
    # Trigger rollback
    exit 1
  fi
else
  echo "⚠️ No build command found"
fi
```

<!-- Component: prompts/quality-gates/type-checking.md -->

#### Gate 2: Type Checking (if TypeScript)

```bash
if [ -f "tsconfig.json" ]; then
  echo "Running TypeScript type checking..."

  npx tsc --noEmit > "$DEPLOYMENT_DIR/type-check.txt" 2>&1

  if [ $? -eq 0 ]; then
    echo "✓ Type checking passed"
  else
    echo "⚠️ Type errors detected"
    tail -20 "$DEPLOYMENT_DIR/type-check.txt"

    Use AskUserQuestion:
      Question: "Type errors detected. How to proceed?"
      Options:
        - "Cancel and fix type errors (Recommended)"
        - "Deploy anyway (may cause runtime errors)"
  fi
fi
```

<!-- Component: prompts/quality-gates/linting.md -->

#### Gate 3: Linting

```bash
if [ -f "package.json" ] && grep -q '"lint":' package.json; then
  echo "Running linter..."

  npm run lint > "$DEPLOYMENT_DIR/lint-output.txt" 2>&1 || true

  ERROR_COUNT=$(grep -c "error" "$DEPLOYMENT_DIR/lint-output.txt" || echo "0")

  if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⚠️ $ERROR_COUNT linting errors"
    # Warnings are OK, errors might be concerning
  else
    echo "✓ Linting passed"
  fi
fi
```

<!-- Component: prompts/quality-gates/test-execution.md -->

#### Gate 4: Tests

```bash
echo "Running tests..."

# Detect test command
if [ -f "package.json" ]; then
  if grep -q '"test":' package.json; then
    TEST_COMMAND="npm test"
  fi
elif [ -f "pytest.ini" ] || grep -q "pytest" requirements.txt 2>/dev/null; then
  TEST_COMMAND="pytest"
elif [ -f "Cargo.toml" ]; then
  TEST_COMMAND="cargo test"
fi

if [ -n "$TEST_COMMAND" ]; then
  echo "Running: $TEST_COMMAND"

  if $TEST_COMMAND > "$DEPLOYMENT_DIR/test-results.txt" 2>&1; then
    echo "✓ Tests passed"
  else
    echo "✗ Tests failed"
    cat "$DEPLOYMENT_DIR/test-results.txt"

    Use AskUserQuestion:
      Question: "Tests failed. How to proceed?"
      Options:
        - "Cancel deployment (Recommended)"
        - "Fix tests and retry"
        - "Deploy anyway (DANGEROUS)"
  fi
else
  echo "⚠️ No test command found - skipping tests"
fi
```

<!-- Component: prompts/quality-gates/security-scan-quick.md -->

#### Gate 5: Security Scan (Quick)

```bash
echo "Running security scan..."

# Quick dependency audit
if [ -f "package.json" ]; then
  npm audit --production --audit-level=high > "$DEPLOYMENT_DIR/security-scan.txt" 2>&1 || true

  CRITICAL_VULNS=$(grep -c "severity: critical" "$DEPLOYMENT_DIR/security-scan.txt" || echo "0")
  HIGH_VULNS=$(grep -c "severity: high" "$DEPLOYMENT_DIR/security-scan.txt" || echo "0")

  if [ "$CRITICAL_VULNS" -gt 0 ] || [ "$HIGH_VULNS" -gt 0 ]; then
    echo "⚠️ WARNING: $CRITICAL_VULNS critical, $HIGH_VULNS high vulnerabilities"

    Use AskUserQuestion:
      Question: "Security vulnerabilities detected. How to proceed?"
      Options:
        - "Cancel and fix vulnerabilities (Recommended)"
        - "Deploy anyway (create follow-up issue)"
  else
    echo "✓ No critical/high vulnerabilities"
  fi
fi

# Check for secrets in code (quick check)
if command -v gitleaks &> /dev/null; then
  gitleaks detect --no-git > "$DEPLOYMENT_DIR/secrets-scan.txt" 2>&1 || true

  if grep -q "leaks found" "$DEPLOYMENT_DIR/secrets-scan.txt"; then
    echo "✗ SECRETS DETECTED IN CODE"
    echo "❌ DEPLOYMENT BLOCKED: Remove secrets before deploying"
    exit 1
  fi
fi
```

Mark todo #2 as completed.

---

## Phase 3: Create Deployment Snapshot (2-5 min)

<!-- Component: prompts/git/tag-creation.md -->

Mark todo #3 as in_progress.

### Git Tag for Deployment

```bash
# Create deployment tag
TAG_NAME="deploy-$ENVIRONMENT-$(date +%Y%m%d-%H%M%S)"

git tag -a "$TAG_NAME" -m "Deployment to $ENVIRONMENT at $(date)"

echo "Created deployment tag: $TAG_NAME"
echo "$TAG_NAME" > "$DEPLOYMENT_DIR/deployment-tag.txt"

# Push tag to remote
git push origin "$TAG_NAME"
```

### Save Deployment Manifest

<!-- Component: prompts/reporting/artifact-listing.md -->

```bash
# Create deployment manifest
cat > "$DEPLOYMENT_DIR/manifest.json" <<EOF
{
  "deployment_id": "$DEPLOYMENT_ID",
  "environment": "$ENVIRONMENT",
  "platform": "$PLATFORM",
  "framework": "$FRAMEWORK",
  "commit": "$DEPLOY_COMMIT",
  "commit_message": "$DEPLOY_COMMIT_MSG",
  "tag": "$TAG_NAME",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "deployed_by": "$(git config user.name)",
  "pre_flight_checks": {
    "tests": "passed",
    "build": "passed",
    "security": "passed",
    "types": "passed"
  }
}
EOF

echo "Deployment manifest saved: $DEPLOYMENT_DIR/manifest.json"
```

Mark todo #3 as completed.

---

## Phase 4: Execute Deployment (5-30 min)

Mark todo #4 as in_progress.

### Platform-Specific Deployment

#### Vercel Deployment

```bash
if [ "$PLATFORM" = "Vercel" ]; then
  echo "Deploying to Vercel..."

  # Check if Vercel CLI is installed
  if ! command -v vercel &> /dev/null; then
    echo "Installing Vercel CLI..."
    npm install -g vercel
  fi

  # Deploy based on environment
  if [ "$ENVIRONMENT" = "production" ]; then
    vercel --prod --yes > "$DEPLOYMENT_DIR/vercel-deploy.log" 2>&1
  else
    vercel --yes > "$DEPLOYMENT_DIR/vercel-deploy.log" 2>&1
  fi

  # Extract deployment URL
  DEPLOY_URL=$(grep -o "https://[^ ]*\.vercel\.app" "$DEPLOYMENT_DIR/vercel-deploy.log" | head -1)
  echo "Deployment URL: $DEPLOY_URL"
  echo "$DEPLOY_URL" > "$DEPLOYMENT_DIR/deployment-url.txt"
fi
```

#### Netlify Deployment

```bash
if [ "$PLATFORM" = "Netlify" ]; then
  echo "Deploying to Netlify..."

  # Check if Netlify CLI is installed
  if ! command -v netlify &> /dev/null; then
    echo "Installing Netlify CLI..."
    npm install -g netlify-cli
  fi

  # Deploy based on environment
  if [ "$ENVIRONMENT" = "production" ]; then
    netlify deploy --prod --dir=dist > "$DEPLOYMENT_DIR/netlify-deploy.log" 2>&1
  else
    netlify deploy --dir=dist > "$DEPLOYMENT_DIR/netlify-deploy.log" 2>&1
  fi

  # Extract deployment URL
  DEPLOY_URL=$(grep -o "https://[^ ]*\.netlify\.app" "$DEPLOYMENT_DIR/netlify-deploy.log" | head -1)
  echo "Deployment URL: $DEPLOY_URL"
  echo "$DEPLOY_URL" > "$DEPLOYMENT_DIR/deployment-url.txt"
fi
```

#### Docker Deployment

```bash
if [ "$PLATFORM" = "Docker" ]; then
  echo "Building and deploying Docker container..."

  # Build Docker image
  IMAGE_TAG="$ENVIRONMENT-$(date +%Y%m%d-%H%M%S)"

  docker build -t "app:$IMAGE_TAG" . > "$DEPLOYMENT_DIR/docker-build.log" 2>&1

  if [ $? -eq 0 ]; then
    echo "✓ Docker image built: app:$IMAGE_TAG"

    # Tag as latest for this environment
    docker tag "app:$IMAGE_TAG" "app:$ENVIRONMENT-latest"

    echo "ℹ️ Docker image ready: app:$IMAGE_TAG"
  else
    echo "✗ Docker build failed"
    cat "$DEPLOYMENT_DIR/docker-build.log"
    exit 1
  fi
fi
```

Mark todo #4 as completed.

---

## Phase 5: Post-Deployment Verification (5-15 min)

Mark todo #5 as in_progress.

### Wait for Deployment to Complete

```bash
# Give deployment time to complete
echo "Waiting for deployment to complete..."
sleep 10
```

### Health Check

```bash
if [ -n "$DEPLOY_URL" ]; then
  echo "Running health check on $DEPLOY_URL..."

  # Check if site is reachable
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL" || echo "000")

  if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo "✓ Health check passed (HTTP $HTTP_STATUS)"
  else
    echo "✗ Health check failed (HTTP $HTTP_STATUS)"

    Use AskUserQuestion:
      Question: "Health check failed. How to proceed?"
      Options:
        - "Wait and retry health check"
        - "Rollback deployment"
        - "Investigate manually"
  fi

  echo "$HTTP_STATUS" > "$DEPLOYMENT_DIR/health-check-status.txt"
fi
```

### Smoke Tests

```bash
echo "Running smoke tests..."

# Basic smoke tests
if [ -n "$DEPLOY_URL" ]; then
  # Test homepage loads
  curl -s "$DEPLOY_URL" > "$DEPLOYMENT_DIR/homepage.html"

  if grep -q "<html" "$DEPLOYMENT_DIR/homepage.html"; then
    echo "✓ Homepage renders HTML"
  else
    echo "⚠️ Homepage may not be rendering correctly"
  fi

  # Test API endpoint (if known)
  if curl -s "$DEPLOY_URL/api/health" > /dev/null 2>&1; then
    echo "✓ API health endpoint accessible"
  else
    echo "ℹ️ API health endpoint not found (may not exist)"
  fi
fi
```

Mark todo #5 as completed.

---

## Phase 6: Deployment Report (3-5 min)

<!-- Component: prompts/reporting/summary-template.md -->
<!-- Component: prompts/reporting/artifact-listing.md -->

Mark todo #6 as in_progress.

### Generate Comprehensive Deployment Report

```markdown
# Deployment Report

**Deployment ID**: $DEPLOYMENT_ID
**Environment**: $ENVIRONMENT
**Platform**: $PLATFORM
**Date**: $(date)
**Status**: ✅ SUCCESS / ❌ FAILED

---

## Deployment Summary

**Deployed By**: $(git config user.name) ($(git config user.email))
**Commit**: $DEPLOY_COMMIT
**Tag**: $TAG_NAME
**Branch**: $(git rev-parse --abbrev-ref HEAD)

**Deployment URL**: $DEPLOY_URL

---

## Pre-Flight Checks

| Check | Status | Notes |
|-------|--------|-------|
| Git Status | ✓ | No uncommitted changes |
| Tests | ✓ | All tests passed |
| Build | ✓ | Build completed successfully |
| Security Scan | ✓ | No critical vulnerabilities |
| Type Checking | ✓ | No type errors |
| Linting | ✓ | Passed with warnings |

---

## Deployment Details

**Platform**: $PLATFORM
**Framework**: $FRAMEWORK
**Environment**: $ENVIRONMENT

**Build Output**:
[Build size and stats from build-size.txt]

**Deployment Duration**: [Time taken]

---

## Post-Deployment Verification

### Health Checks

| Check | Status | Details |
|-------|--------|---------|
| HTTP Status | ✓ 200 | Site is accessible |
| API Health | ✓ | API responding |
| Response Time | ✓ | [X.XX]s |

### Smoke Tests

- ✓ Homepage loads correctly
- ✓ Static assets loading
- ✓ API endpoints responding

---

## Rollback Information

**Rollback Command**:
```bash
# Rollback to previous deployment
[platform-specific rollback command]
```

**Rollback Procedure**:
See `prompts/quality-gates/rollback-on-failure.md` for detailed rollback instructions.

---

## Deployment Artifacts

<!-- Component: prompts/reporting/artifact-listing.md -->

All deployment artifacts saved to `.agency/deployments/$DEPLOYMENT_ID/`:

- `manifest.json` - Deployment manifest
- `commit-hash.txt` - Deployed commit
- `deployment-tag.txt` - Git tag
- `test-results.txt` - Test results
- `build-output.txt` - Build logs
- `security-scan.txt` - Security scan results
- `deployment-url.txt` - Deployment URL
- `health-check-status.txt` - Health check results

---

## Next Steps

### Monitoring

1. **Monitor Application**: Watch logs and metrics for 15-30 minutes
2. **Check Error Tracking**: Review Sentry/Bugsnag for new errors
3. **Monitor Performance**: Check response times and resource usage

### Communication

1. **Notify Team**: Deployment to $ENVIRONMENT complete
2. **Update Status Page**: If applicable
3. **Document Changes**: Update changelog/release notes

---

**Deployment Status**: ✅ SUCCESS

**Deployed At**: $(date -u +%Y-%m-%dT%H:%M:%SZ)

**Deployment URL**: $DEPLOY_URL

---

**Generated**: $(date)
**Environment**: $ENVIRONMENT
```

Save to `$DEPLOYMENT_DIR/deployment-report.md`

### Update Deployment History

```bash
# Update deployment history file
HISTORY_FILE=".agency/deployments/history.md"

if [ ! -f "$HISTORY_FILE" ]; then
  cat > "$HISTORY_FILE" <<EOF
# Deployment History

| Date | Environment | Platform | Commit | Tag | URL | Status |
|------|-------------|----------|--------|-----|-----|--------|
EOF
fi

echo "| $(date +%Y-%m-%d\ %H:%M) | $ENVIRONMENT | $PLATFORM | ${DEPLOY_COMMIT:0:7} | $TAG_NAME | $DEPLOY_URL | ✅ |" >> "$HISTORY_FILE"
```

Mark todo #6 as completed.

---

## Error Handling

<!-- Component: prompts/quality-gates/rollback-on-failure.md -->

### If Pre-Flight Checks Fail

**Tests Fail**:
- Do NOT proceed with deployment
- Fix failing tests
- Re-run deployment after fixes

**Build Fails**:
- Do NOT proceed with deployment
- Review build errors
- Fix and retry

**Security Vulnerabilities**:
- For CRITICAL: Block deployment
- For HIGH: Warn and get user approval
- For MEDIUM/LOW: Proceed with warning

### If Deployment Fails

**Platform Error**:
- Review deployment logs
- Check authentication/permissions
- Retry deployment
- Contact platform support if needed

**Timeout**:
- Check platform status page
- Wait and retry
- Consider manual deployment

### If Health Check Fails

**Immediate Action**:
- Do NOT promote to production
- Investigate logs
- Rollback if critical

**Options**:
```
Use AskUserQuestion:
  Question: "Deployment health check failed. How to proceed?"
  Options:
    - "Rollback immediately (Recommended)"
    - "Investigate and debug"
    - "Wait and retry health check"
    - "Proceed anyway (DANGEROUS)"
```

### If Rollback Needed

See `prompts/quality-gates/rollback-on-failure.md` for comprehensive rollback procedures.

**Platform-specific rollback examples**:
```bash
case "$PLATFORM" in
  "Vercel")
    vercel rollback
    ;;
  "Netlify")
    netlify deploy --prod --dir=.netlify/previous
    ;;
  "Heroku")
    heroku releases:rollback
    ;;
  *)
    echo "Manual rollback required for $PLATFORM"
    ;;
esac
```

---

## Important Notes

### Deployment Best Practices

1. **Always Deploy to Staging First**: Test in staging before production
2. **Monitor After Deployment**: Watch for errors for 15-30 minutes
3. **Have Rollback Ready**: Know how to rollback before deploying
4. **Communicate**: Notify team of deployments
5. **Deploy During Low Traffic**: Minimize impact of issues

### Deployment Checklist

Before deploying:
- [ ] All tests passing
- [ ] Build succeeds
- [ ] No security vulnerabilities
- [ ] Code reviewed
- [ ] Database migrations ready (if needed)
- [ ] Environment variables configured
- [ ] Rollback plan prepared
- [ ] Team notified

After deploying:
- [ ] Health check passed
- [ ] Smoke tests passed
- [ ] Monitor logs for errors
- [ ] Verify integrations working
- [ ] Update documentation

---

## Skills to Reference

Activate and reference these skills as needed:

**Required**:
- `agency-workflow-patterns` - Orchestration patterns (ACTIVATE IMMEDIATELY)

**Platform-Specific** (if available):
- `vercel-deployment` - Vercel-specific best practices
- `aws-deployment` - AWS deployment patterns
- `docker-deployment` - Container deployment
- `kubernetes-deployment` - K8s deployment

**DevOps**:
- `ci-cd-best-practices` - CI/CD patterns
- `deployment-strategies` - Blue-green, canary, rolling
- `monitoring-observability` - Post-deployment monitoring

---

## Related Commands

- `/agency:work [issue]` - Implement features to deploy
- `/agency:test [component]` - Generate tests before deployment
- `/agency:security [scope]` - Security audit before deployment
- `/agency:review [pr]` - Review changes before deployment

---

**Remember**:

- **Test before deploying**: Never deploy untested code
- **Monitor after deploying**: Catch issues early
- **Have rollback ready**: Be prepared for failures
- **Communicate**: Keep team informed
- **Automate**: Reduce human error with automation

Deployment is not the end—it's the beginning of monitoring and maintenance.

---

**End of /agency:deploy command**
