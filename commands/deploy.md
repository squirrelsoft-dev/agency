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

Track deployment progress with TodoWrite for transparency and rollback reference.

---

## Phase 0: Project Context Detection (1-2 min)

Quickly gather project context to determine deployment strategy.

### Detect Framework/Platform

```bash
# Detect JavaScript/TypeScript frameworks
if [ -f "next.config.js" ] || [ -f "next.config.ts" ]; then
  FRAMEWORK="Next.js"
  Read package.json

  # Check for App Router vs Pages Router
  if [ -d "app" ]; then
    ROUTER="App Router"
  else
    ROUTER="Pages Router"
  fi
fi

if [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
  FRAMEWORK="Vite"
fi

if [ -f "angular.json" ]; then
  FRAMEWORK="Angular"
fi

# Check for Python frameworks
if [ -f "manage.py" ]; then
  FRAMEWORK="Django"
  RUNTIME="Python"
fi

if [ -f "app.py" ] || [ -f "main.py" ]; then
  if grep -q "fastapi" requirements.txt 2>/dev/null; then
    FRAMEWORK="FastAPI"
    RUNTIME="Python"
  elif grep -q "flask" requirements.txt 2>/dev/null; then
    FRAMEWORK="Flask"
    RUNTIME="Python"
  fi
fi

# Check for other frameworks
if [ -f "Gemfile" ]; then
  FRAMEWORK="Rails"
  RUNTIME="Ruby"
fi

if [ -f "go.mod" ]; then
  FRAMEWORK="Go"
  RUNTIME="Go"
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

if [ -f ".platform.app.yaml" ]; then
  PLATFORM="Platform.sh"
  DETECTED="Yes"
fi

if [ -d ".github/workflows" ]; then
  # Check for deployment workflows
  if grep -q "vercel" .github/workflows/*.yml 2>/dev/null; then
    CI_PLATFORM="GitHub Actions → Vercel"
  elif grep -q "aws" .github/workflows/*.yml 2>/dev/null; then
    CI_PLATFORM="GitHub Actions → AWS"
  elif grep -q "azure" .github/workflows/*.yml 2>/dev/null; then
    CI_PLATFORM="GitHub Actions → Azure"
  else
    CI_PLATFORM="GitHub Actions"
  fi
fi

if [ -f ".gitlab-ci.yml" ]; then
  CI_PLATFORM="GitLab CI"
fi

if [ -f "azure-pipelines.yml" ]; then
  PLATFORM="Azure"
  CI_PLATFORM="Azure Pipelines"
  DETECTED="Yes"
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

# Railway
if [ -f "railway.json" ]; then
  PLATFORM="Railway"
  DETECTED="Yes"
fi

# Render
if [ -f "render.yaml" ]; then
  PLATFORM="Render"
  DETECTED="Yes"
fi

echo "Detected platform: $PLATFORM"
echo "Framework: $FRAMEWORK"
```

### Detect Environment Variables System

```bash
# Check for environment variable configuration
if [ -f ".env.production" ]; then
  ENV_SYSTEM="Dotenv (production)"
fi

if [ -f ".env.staging" ]; then
  ENV_SYSTEM_STAGING="Dotenv (staging)"
fi

if [ -f ".env.local" ]; then
  echo "⚠️ WARNING: .env.local detected (should not be deployed)"
fi

# Check if .env is gitignored
if [ -f ".gitignore" ] && grep -q "\.env" .gitignore; then
  echo "✓ .env files properly gitignored"
else
  echo "✗ WARNING: .env files may not be gitignored"
fi
```

**Use this context to**:
- Select appropriate deployment commands
- Validate environment configuration
- Choose deployment strategy (build, containerize, serverless)
- Set up health checks

---

## Phase 1: Environment & Target Detection (2-3 min)

### Parse Deployment Argument

Analyze `$ARGUMENTS` to determine deployment target:

**Environment-Based** if:
- `$ARGUMENTS` = "staging" or "stage" or "preview"
- `$ARGUMENTS` = "production" or "prod" or "live"
- `$ARGUMENTS` = "development" or "dev"

**Platform-Based** if:
- `$ARGUMENTS` = "vercel" or "netlify" or "aws" or "heroku" etc.
- Override auto-detected platform

**URL-Based** if:
- `$ARGUMENTS` contains URL pattern (e.g., "https://app-staging.vercel.app")

**Auto-Detect** if:
- `$ARGUMENTS` = "auto" or empty
- Use detected platform and infer environment from branch

### Create Todo List for Deployment

Use TodoWrite to create tracking:

```
1. Validate deployment environment
2. Run pre-flight checks (tests, build, security)
3. Create deployment snapshot/backup
4. Execute deployment
5. Run post-deployment verification
6. Generate deployment report
```

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

### Run Tests

```bash
echo "Running tests..."

# Detect test command
if [ -f "package.json" ]; then
  if grep -q '"test":' package.json; then
    TEST_COMMAND="npm test"
  elif grep -q '"test":' package.json; then
    TEST_COMMAND="pnpm test"
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

### Run Build

```bash
echo "Running build..."

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
    exit 1
  fi
else
  echo "⚠️ No build command found"
fi
```

### Security Scan (Quick)

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

### Type Checking (if TypeScript)

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

### Linting

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

Mark todo #2 as completed.

---

## Phase 3: Create Deployment Snapshot (2-5 min)

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

### Backup Current Deployment (if applicable)

```bash
# For platforms that support snapshots/backups
case "$PLATFORM" in
  "Vercel")
    # Vercel keeps deployment history automatically
    echo "ℹ️ Vercel maintains deployment history"
    ;;
  "AWS"*)
    # Create AMI snapshot or similar
    echo "ℹ️ Consider creating AMI snapshot for AWS deployments"
    ;;
  "Docker"|"Kubernetes")
    # Tag current image as backup
    echo "ℹ️ Tag current container image as backup before deploying"
    ;;
esac
```

### Save Deployment Manifest

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

  # Build is already done in pre-flight
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

    # Push to registry (if configured)
    if [ -n "$DOCKER_REGISTRY" ]; then
      docker push "$DOCKER_REGISTRY/app:$IMAGE_TAG"
      docker push "$DOCKER_REGISTRY/app:$ENVIRONMENT-latest"
    fi

    # Deploy container (example for local/single server)
    # Actual deployment depends on your infrastructure
    echo "ℹ️ Docker image ready: app:$IMAGE_TAG"
  else
    echo "✗ Docker build failed"
    cat "$DEPLOYMENT_DIR/docker-build.log"
    exit 1
  fi
fi
```

#### AWS Serverless Deployment

```bash
if [[ "$PLATFORM" == AWS* ]]; then
  echo "Deploying to AWS..."

  if [ -f "serverless.yml" ]; then
    # Serverless Framework
    serverless deploy --stage "$ENVIRONMENT" > "$DEPLOYMENT_DIR/aws-deploy.log" 2>&1

    # Extract API endpoint
    DEPLOY_URL=$(grep -o "https://[^ ]*\.execute-api\.[^ ]*" "$DEPLOYMENT_DIR/aws-deploy.log" | head -1)

  elif [ -f "template.yaml" ]; then
    # AWS SAM
    sam deploy --stack-name "app-$ENVIRONMENT" > "$DEPLOYMENT_DIR/aws-sam-deploy.log" 2>&1

    # Extract outputs
    aws cloudformation describe-stacks --stack-name "app-$ENVIRONMENT" --query 'Stacks[0].Outputs' > "$DEPLOYMENT_DIR/aws-outputs.json"
  fi

  echo "Deployment URL: $DEPLOY_URL"
  echo "$DEPLOY_URL" > "$DEPLOYMENT_DIR/deployment-url.txt"
fi
```

#### Heroku Deployment

```bash
if [ "$PLATFORM" = "Heroku" ]; then
  echo "Deploying to Heroku..."

  # Determine Heroku app name
  if [ "$ENVIRONMENT" = "production" ]; then
    HEROKU_APP="app-production"
  else
    HEROKU_APP="app-staging"
  fi

  # Deploy via git push
  git push heroku main:main > "$DEPLOYMENT_DIR/heroku-deploy.log" 2>&1

  DEPLOY_URL="https://$HEROKU_APP.herokuapp.com"
  echo "Deployment URL: $DEPLOY_URL"
  echo "$DEPLOY_URL" > "$DEPLOYMENT_DIR/deployment-url.txt"
fi
```

#### Generic/CI-Based Deployment

```bash
if [ -z "$DEPLOY_URL" ]; then
  echo "ℹ️ Using CI/CD pipeline for deployment"

  # Trigger CI/CD pipeline (example for GitHub Actions)
  if [ -n "$CI_PLATFORM" ] && [ "$CI_PLATFORM" = "GitHub Actions" ]; then
    echo "Deployment triggered via GitHub Actions workflow"
    echo "Monitor deployment: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:\/]//' | sed 's/.git$//')/actions"
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

  # Check for JavaScript errors (basic check)
  if grep -q "console.error\|Uncaught\|TypeError" "$DEPLOYMENT_DIR/homepage.html"; then
    echo "⚠️ Potential JavaScript errors detected"
  fi
fi
```

### Performance Check (Optional)

```bash
if [ -n "$DEPLOY_URL" ]; then
  echo "Running performance check..."

  # Measure response time
  RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' "$DEPLOY_URL")

  echo "Response time: ${RESPONSE_TIME}s"
  echo "$RESPONSE_TIME" > "$DEPLOYMENT_DIR/response-time.txt"

  # Run Lighthouse (if installed)
  if command -v lighthouse &> /dev/null; then
    lighthouse "$DEPLOY_URL" --output=json --output-path="$DEPLOYMENT_DIR/lighthouse.json" --chrome-flags="--headless" || true
  fi
fi
```

### Verify Environment Variables

```bash
echo "Verifying environment configuration..."

# Check that environment-specific configs are loaded
# This is platform-specific
case "$PLATFORM" in
  "Vercel")
    vercel env ls "$ENVIRONMENT" > "$DEPLOYMENT_DIR/env-vars.txt" 2>&1 || true
    ;;
  "Netlify")
    netlify env:list > "$DEPLOYMENT_DIR/env-vars.txt" 2>&1 || true
    ;;
  *)
    echo "ℹ️ Manual verification recommended for $PLATFORM"
    ;;
esac
```

Mark todo #5 as completed.

---

## Phase 6: Deployment Report (3-5 min)

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
| Lighthouse Score | [Score] | [Link to report] |

### Smoke Tests

- ✓ Homepage loads correctly
- ✓ Static assets loading
- ✓ API endpoints responding
- ⚠️ Minor JavaScript warnings (non-blocking)

---

## Rollback Information

**Rollback Command**:
```bash
# Rollback to previous deployment
[platform-specific rollback command]
```

**Previous Deployment**:
- Tag: [previous-tag]
- Commit: [previous-commit]
- URL: [previous-url]

**Rollback Procedure**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

---

## Environment Configuration

**Environment Variables** (count): [N]

**Critical Configs Verified**:
- ✓ Database connection
- ✓ API keys configured
- ✓ Third-party integrations

---

## Deployment Artifacts

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

### Follow-Up

- [ ] Monitor application for 1 hour
- [ ] Check error tracking dashboard
- [ ] Verify all integrations working
- [ ] Update deployment documentation

---

## Rollback Plan (If Needed)

If issues are detected:

1. **Immediate**: Rollback to previous version
2. **Investigate**: Review logs and error reports
3. **Fix**: Address issues in development
4. **Re-deploy**: After fixes verified

---

## Issues Encountered

[List any issues encountered during deployment and how they were resolved]

---

## Performance Baseline

**Response Times**:
- Homepage: [X.XX]s
- API: [X.XX]s

**Resource Usage**:
- Memory: [X MB]
- CPU: [X%]

**Lighthouse Scores** (if available):
- Performance: [X/100]
- Accessibility: [X/100]
- Best Practices: [X/100]
- SEO: [X/100]

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

**Rollback Procedure**:
```bash
# Platform-specific rollback
case "$PLATFORM" in
  "Vercel")
    # Vercel allows promoting previous deployment
    vercel rollback
    ;;
  "Netlify")
    # Restore previous deployment
    netlify deploy --prod --dir=.netlify/previous
    ;;
  "Heroku")
    # Rollback release
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

### Zero-Downtime Deployments

For production:
- Use blue-green deployments
- Or canary deployments
- Or rolling deployments
- Avoid direct replacement

### Database Migrations

**CRITICAL**: Handle migrations carefully:
1. Deploy backward-compatible migrations first
2. Deploy code
3. Run forward migrations
4. Never skip migration rollback planning

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
