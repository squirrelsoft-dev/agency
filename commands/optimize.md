---
description: Performance optimization with profiling, benchmarking, and verification
argument-hint: target (bundle/database/rendering/api/memory/auto)
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion]
---

# Optimize Performance: $ARGUMENTS

Performance optimization with profiling, benchmarking, and measurable improvements.

## Your Mission

Optimize performance for target: **$ARGUMENTS**

Follow the optimization lifecycle: detect target → profile baseline → plan optimizations → implement incrementally → verify improvements → report results.

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

Quickly gather project context to select appropriate profiling tools and optimization strategies.

### Detect Framework/Language

```bash
# Detect JavaScript/TypeScript frameworks
if [ -f "next.config.js" ] || [ -f "next.config.ts" ]; then
  FRAMEWORK="Next.js"
  # Read package.json to get Next.js version
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

if [ -f "webpack.config.js" ]; then
  FRAMEWORK="Webpack-based"
fi

# Check for Python frameworks
if [ -f "manage.py" ]; then
  FRAMEWORK="Django"
fi

if [ -f "app.py" ] || [ -f "main.py" ]; then
  # Check requirements.txt for FastAPI
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

### Detect Database/ORM

```bash
# Check package.json for database libraries
if [ -f "package.json" ]; then
  if grep -q "prisma" package.json; then
    DATABASE="Prisma"
  elif grep -q "drizzle-orm" package.json; then
    DATABASE="Drizzle"
  elif grep -q "typeorm" package.json; then
    DATABASE="TypeORM"
  elif grep -q "@supabase/supabase-js" package.json; then
    DATABASE="Supabase"
  elif grep -q "mongodb" package.json; then
    DATABASE="MongoDB"
  elif grep -q "pg" package.json; then
    DATABASE="PostgreSQL"
  fi
fi

# Check Python requirements
if [ -f "requirements.txt" ]; then
  if grep -q "sqlalchemy" requirements.txt; then
    DATABASE="SQLAlchemy"
  elif grep -q "django" requirements.txt; then
    DATABASE="Django ORM"
  elif grep -q "pymongo" requirements.txt; then
    DATABASE="MongoDB (PyMongo)"
  fi
fi
```

### Detect Build Tool

```bash
# Detect bundler/build tool
if [ -f "next.config.js" ] || [ -f "next.config.ts" ]; then
  BUILD_TOOL="Next.js (webpack/turbopack)"
fi

if [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
  BUILD_TOOL="Vite"
fi

if [ -f "webpack.config.js" ]; then
  BUILD_TOOL="Webpack"
fi

if [ -f "rollup.config.js" ]; then
  BUILD_TOOL="Rollup"
fi
```

### Detect Testing Framework

```bash
# Check for test frameworks (for benchmark verification)
if [ -f "package.json" ]; then
  if grep -q "jest" package.json; then
    TEST_FRAMEWORK="Jest"
  elif grep -q "vitest" package.json; then
    TEST_FRAMEWORK="Vitest"
  elif grep -q "mocha" package.json; then
    TEST_FRAMEWORK="Mocha"
  fi
fi
```

**Use this context to**:
- Select appropriate profiling tools (bundle analyzer, Lighthouse, database profiler)
- Choose optimization strategies (code splitting, query optimization, caching)
- Determine benchmark commands
- Select specialist agents (performance-benchmarker, backend-architect, etc.)

---

## Phase 1: Optimization Target Detection (2-3 min)

### Parse Target Argument

Analyze `$ARGUMENTS` to determine optimization target:

**Bundle Optimization** if:
- `$ARGUMENTS` = "bundle" or "build" or "size"
- Related keywords: "webpack", "chunk", "tree-shaking", "code-splitting"

**Database Optimization** if:
- `$ARGUMENTS` = "database" or "db" or "queries" or "sql"
- Related keywords: "prisma", "query", "n+1", "indexes"

**Rendering Optimization** if:
- `$ARGUMENTS` = "rendering" or "render" or "ui" or "ssr"
- Related keywords: "react", "hydration", "layout-shift", "paint"

**API Optimization** if:
- `$ARGUMENTS` = "api" or "endpoint" or "latency" or "throughput"
- Related keywords: "response-time", "requests", "caching"

**Memory Optimization** if:
- `$ARGUMENTS` = "memory" or "heap" or "leak"
- Related keywords: "gc", "allocation", "retain"

**Auto-Detect** if:
- `$ARGUMENTS` = "auto" or empty or unclear
- Run all profilers and prioritize by biggest issues

### Create Todo List for Optimization

Use TodoWrite to create tracking for optimization phases:

```
1. Detect optimization target
2. Profile current performance (baseline)
3. Create optimization plan
4. Implement optimizations incrementally
5. Verify improvements with benchmarks
6. Generate performance report
```

### Get User Confirmation

If target is auto-detected, use AskUserQuestion to confirm:

```
Question: "Detected optimization target: [TARGET]. Is this correct?"
Options:
  - "Yes, proceed with [TARGET] optimization"
  - "Change to bundle optimization"
  - "Change to database optimization"
  - "Change to rendering optimization"
  - "Change to API optimization"
  - "Run full performance audit (all targets)"
```

Mark todo #1 as completed.

---

## Phase 2: Performance Profiling & Baseline (10-20 min)

### Create Profiling Directory

```bash
# Create directory for profiling results
mkdir -p .agency/optimizations
mkdir -p .agency/optimizations/baseline
mkdir -p .agency/optimizations/benchmarks
```

### Run Profiling Tools by Target

Mark todo #2 as in_progress.

#### Bundle Optimization Profiling

**For Next.js**:
```bash
# Install bundle analyzer if not present
if ! grep -q "@next/bundle-analyzer" package.json; then
  npm install --save-dev @next/bundle-analyzer
fi

# Create next.config.js with analyzer
# Add bundle analyzer configuration
# Run production build with analyzer
ANALYZE=true npm run build

# Output will open in browser - save screenshot or copy stats
```

**For Webpack**:
```bash
# Install webpack-bundle-analyzer
npm install --save-dev webpack-bundle-analyzer

# Add to webpack config or run
npx webpack-bundle-analyzer dist/stats.json
```

**For Vite**:
```bash
# Install vite-bundle-visualizer
npm install --save-dev rollup-plugin-visualizer

# Add to vite.config.ts and run build
npm run build
```

**Capture Baseline Metrics**:
```bash
# Get build output size
ls -lh .next/ | grep -E "(static|chunks)" > .agency/optimizations/baseline/bundle-size.txt

# Or for general build
du -sh dist/ > .agency/optimizations/baseline/bundle-size.txt
```

#### Database Optimization Profiling

**For PostgreSQL (Prisma/Drizzle/Raw)**:
```bash
# Enable query logging
# In postgres: ALTER DATABASE yourdb SET log_statement = 'all';

# Run application under typical load
# Use slow query log

# Analyze specific queries
psql -d yourdb -c "EXPLAIN ANALYZE SELECT ..." > .agency/optimizations/baseline/query-plans.txt

# Check for missing indexes
psql -d yourdb -c "
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY abs(correlation) DESC
LIMIT 20;
" > .agency/optimizations/baseline/index-candidates.txt
```

**For Prisma**:
```bash
# Enable query logging in Prisma
# Add to schema.prisma: log = ["query", "info", "warn", "error"]

# Or use Prisma Studio
npx prisma studio
```

**Capture Baseline Metrics**:
- Average query time
- Slowest queries (top 10)
- Query count per endpoint
- Missing indexes
- N+1 query patterns

#### Rendering Optimization Profiling

**Using Lighthouse (CLI)**:
```bash
# Install Lighthouse CLI
npm install -g lighthouse

# Run Lighthouse on key pages
lighthouse http://localhost:3000 --output json --output-path .agency/optimizations/baseline/lighthouse-home.json
lighthouse http://localhost:3000/dashboard --output json --output-path .agency/optimizations/baseline/lighthouse-dashboard.json

# Extract key metrics
cat .agency/optimizations/baseline/lighthouse-home.json | grep -E "(first-contentful-paint|largest-contentful-paint|cumulative-layout-shift|total-blocking-time)"
```

**Using React DevTools Profiler**:
- Open React DevTools
- Start profiling
- Perform typical user interactions
- Stop and export flame graph
- Save to `.agency/optimizations/baseline/react-profiler.json`

**Capture Baseline Metrics**:
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Total Blocking Time (TBT)
- Cumulative Layout Shift (CLS)
- Time to Interactive (TTI)
- Hydration time (for SSR)

#### API Optimization Profiling

**Using autocannon (HTTP benchmarking)**:
```bash
# Install autocannon
npm install -g autocannon

# Benchmark key endpoints
autocannon -c 10 -d 30 http://localhost:3000/api/users > .agency/optimizations/baseline/api-users.txt
autocannon -c 10 -d 30 http://localhost:3000/api/posts > .agency/optimizations/baseline/api-posts.txt

# Benchmark with POST requests
autocannon -c 10 -d 30 -m POST -H "Content-Type: application/json" -b '{"test": true}' http://localhost:3000/api/create
```

**Using k6 (load testing)**:
```bash
# Install k6
# Create k6 script
cat > .agency/optimizations/baseline/k6-script.js <<'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 10,
  duration: '30s',
};

export default function() {
  let res = http.get('http://localhost:3000/api/users');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
EOF

# Run k6
k6 run .agency/optimizations/baseline/k6-script.js > .agency/optimizations/baseline/k6-results.txt
```

**Capture Baseline Metrics**:
- Requests per second (RPS)
- Average response time
- P95/P99 latency
- Error rate
- Throughput

#### Memory Optimization Profiling

**Using Chrome DevTools (Heap Snapshot)**:
- Open Chrome DevTools
- Go to Memory tab
- Take heap snapshot
- Perform actions that might leak
- Take another snapshot
- Compare snapshots
- Export to `.agency/optimizations/baseline/heap-snapshot.heapsnapshot`

**Using Node.js --inspect**:
```bash
# Start app with inspector
node --inspect server.js

# Or for Next.js
NODE_OPTIONS='--inspect' npm run dev

# Connect Chrome DevTools to node inspector
# Take heap snapshots
```

**Using clinic.js (Node.js profiling)**:
```bash
# Install clinic
npm install -g clinic

# Run clinic doctor (diagnoses performance issues)
clinic doctor -- node server.js

# Run clinic bubbleprof (async operations)
clinic bubbleprof -- node server.js

# Run clinic flame (flamegraph)
clinic flame -- node server.js
```

**Capture Baseline Metrics**:
- Heap size
- Memory leaks (retainer analysis)
- GC frequency/duration
- Memory allocation rate

### Generate Baseline Report

Create comprehensive baseline report:

```markdown
# Performance Baseline Report

**Date**: [current date]
**Target**: [optimization target]
**Framework**: [detected framework]

## Baseline Metrics

### [Target-Specific Metrics]

[Include specific metrics from profiling above]

## Bottlenecks Identified

1. **[Bottleneck 1]**: [Description]
   - Impact: [High/Medium/Low]
   - Metric: [specific measurement]
   - Location: [file/query/component]

2. **[Bottleneck 2]**: [Description]
   - Impact: [High/Medium/Low]
   - Metric: [specific measurement]
   - Location: [file/query/component]

## Optimization Opportunities

1. [Opportunity 1] - Expected improvement: [X%]
2. [Opportunity 2] - Expected improvement: [X%]
3. [Opportunity 3] - Expected improvement: [X%]

## Profiling Artifacts

- [List files in .agency/optimizations/baseline/]

---

**Next Step**: Create optimization plan prioritized by impact
```

Save to `.agency/optimizations/baseline-report.md`

Mark todo #2 as completed.

---

## Phase 3: Optimization Plan Creation (5-7 min)

Mark todo #3 as in_progress.

### Select Optimization Specialist

Based on target, spawn the appropriate specialist to review baseline and create plan:

| Target | Specialist Agent |
|--------|------------------|
| **Bundle** | Frontend Developer or senior-developer |
| **Database** | Backend Architect |
| **Rendering** | Frontend Developer or ArchitectUX |
| **API** | Backend Architect or performance-benchmarker |
| **Memory** | Senior Developer or backend-architect |
| **Auto/Multiple** | Performance Benchmarker |

### Spawn Optimization Planner

Use the Task tool to spawn the specialist:

```
Task: Create optimization plan for [TARGET]

Agent: [selected specialist]

Context:
- Optimization target: [TARGET]
- Framework: [detected framework]
- Baseline report: [read .agency/optimizations/baseline-report.md]
- Key bottlenecks: [summarize top 3]

Instructions:
1. Review the baseline profiling report
2. Prioritize optimizations by:
   - Impact (performance improvement)
   - Effort (implementation complexity)
   - Risk (potential for breaking changes)
3. Create incremental optimization plan with:
   - Each optimization as a separate step
   - Expected improvement (quantitative)
   - Implementation approach
   - Rollback strategy if no improvement
4. Include specific techniques:
   - For bundle: Code splitting, tree shaking, lazy loading, compression
   - For database: Indexes, query optimization, connection pooling, caching
   - For rendering: React.memo, useMemo, virtual scrolling, SSR optimization
   - For API: Caching, batching, parallel requests, response compression
   - For memory: Leak fixes, GC tuning, object pooling

Please create a detailed, prioritized optimization plan.
```

**Wait for the specialist to complete the plan.**

### Review and Refine Plan

Review the specialist's plan and ensure it includes:

1. **Prioritization** (High/Medium/Low impact)
2. **Incremental steps** (can execute one at a time)
3. **Success criteria** (specific metrics to verify)
4. **Rollback strategy** (how to undo if no improvement)
5. **Risk assessment** (breaking change potential)

### Present Plan to User

Use AskUserQuestion or present clearly:

```markdown
## Optimization Plan for [TARGET]

### Summary
[Brief overview of optimization strategy]

### Optimizations (Prioritized by Impact)

#### High Impact
1. **[Optimization 1]** - Expected: [X% improvement]
   - Approach: [brief description]
   - Effort: [Low/Medium/High]
   - Risk: [Low/Medium/High]

2. **[Optimization 2]** - Expected: [X% improvement]
   - Approach: [brief description]
   - Effort: [Low/Medium/High]
   - Risk: [Low/Medium/High]

#### Medium Impact
3. **[Optimization 3]** - Expected: [X% improvement]
   - Approach: [brief description]

### Execution Strategy
- Execute optimizations incrementally
- Benchmark after each optimization
- Rollback if no improvement or tests fail
- Estimated total time: [X hours]

**Ready to proceed with optimizations?**
```

If user asks for modifications, update the plan.

**STOP HERE until user approves the plan.**

Mark todo #3 as completed.

---

## Phase 4: Optimization Implementation (2-8 hours)

Mark todo #4 as in_progress.

### Prepare for Incremental Execution

```bash
# Create git checkpoint before optimizations
git add -A
git commit -m "chore: baseline before performance optimizations for $ARGUMENTS"

# Create optimization tracking file
cat > .agency/optimizations/execution-log.md <<EOF
# Optimization Execution Log

**Target**: $ARGUMENTS
**Start Time**: $(date)

## Optimizations

EOF
```

### Execute Optimizations Incrementally

For each optimization in the plan (in priority order):

#### Step 1: Create Checkpoint

```bash
CURRENT_OPT="[optimization name]"
echo "## Optimization: $CURRENT_OPT" >> .agency/optimizations/execution-log.md
echo "**Started**: $(date)" >> .agency/optimizations/execution-log.md

# Git checkpoint
git add -A
git commit -m "chore: checkpoint before $CURRENT_OPT"
```

#### Step 2: Implement Optimization

**Option A: Direct Implementation** (for simple optimizations):
```bash
# Use Edit tool to make changes
# Example: Add React.memo to component
```

**Option B: Delegate to Specialist** (for complex optimizations):
```
Task: Implement optimization - [optimization name]

Agent: [appropriate specialist]

Context:
- Optimization target: [TARGET]
- Specific optimization: [name and description]
- Expected improvement: [X%]
- Files to modify: [list]

Instructions:
1. Implement the optimization as described
2. Maintain existing functionality (all tests must pass)
3. Add comments explaining the optimization
4. DO NOT commit changes - I will handle benchmarking

Please implement this optimization now.
```

#### Step 3: Run Benchmark

```bash
echo "### Benchmark" >> .agency/optimizations/execution-log.md

# Run appropriate benchmark based on target

# For bundle:
npm run build
du -sh .next/ > .agency/optimizations/benchmarks/$CURRENT_OPT-bundle.txt

# For database:
# Run same queries as baseline
psql -d yourdb -c "EXPLAIN ANALYZE [query]" > .agency/optimizations/benchmarks/$CURRENT_OPT-query.txt

# For rendering:
lighthouse http://localhost:3000 --output json --output-path .agency/optimizations/benchmarks/$CURRENT_OPT-lighthouse.json

# For API:
autocannon -c 10 -d 30 http://localhost:3000/api/endpoint > .agency/optimizations/benchmarks/$CURRENT_OPT-api.txt

# For memory:
# Take heap snapshot after same operations
```

#### Step 4: Compare to Baseline

Compare benchmark results to baseline:

```bash
# Example for bundle size
BASELINE_SIZE=$(cat .agency/optimizations/baseline/bundle-size.txt | awk '{print $1}')
CURRENT_SIZE=$(cat .agency/optimizations/benchmarks/$CURRENT_OPT-bundle.txt | awk '{print $1}')

# Calculate improvement percentage
# (For demonstration - actual calculation would be more robust)

echo "Baseline: $BASELINE_SIZE" >> .agency/optimizations/execution-log.md
echo "Current: $CURRENT_SIZE" >> .agency/optimizations/execution-log.md
```

Determine if improvement meets expectations:
- **Improvement ≥ expected**: Success! Commit this optimization
- **Improvement < expected but positive**: Partial success, ask user if acceptable
- **No improvement or regression**: Rollback

#### Step 5: Run Tests

```bash
# Run test suite to ensure no functionality broken
npm test

if [ $? -ne 0 ]; then
  echo "❌ Tests failed after $CURRENT_OPT" >> .agency/optimizations/execution-log.md

  # Rollback
  git reset --hard HEAD~1

  echo "Rolled back $CURRENT_OPT due to test failures" >> .agency/optimizations/execution-log.md

  # Ask user what to do
  Use AskUserQuestion:
    Question: "Optimization '$CURRENT_OPT' caused test failures. How to proceed?"
    Options:
      - "Skip this optimization and continue"
      - "Attempt to fix the issues"
      - "Abort optimization workflow"
fi
```

#### Step 6: Commit or Rollback

**If improvement is acceptable and tests pass**:
```bash
git add -A
git commit -m "perf($ARGUMENTS): $CURRENT_OPT

Improved [metric] by [X%]
Baseline: [baseline value]
Current: [current value]"

echo "✅ Committed: $CURRENT_OPT" >> .agency/optimizations/execution-log.md
echo "Improvement: [X%]" >> .agency/optimizations/execution-log.md
```

**If no improvement or regression**:
```bash
git reset --hard HEAD~1

echo "⏪ Rolled back: $CURRENT_OPT (no improvement)" >> .agency/optimizations/execution-log.md
```

### Repeat for All Optimizations

Continue executing optimizations incrementally, benchmarking after each, until all high and medium priority optimizations are attempted.

### Update Todo Progress

As optimizations complete, update TodoWrite with progress:
```
Currently implementing optimization 3 of 7: [optimization name]
```

Mark todo #4 as completed when all optimizations attempted.

---

## Phase 5: Verification & Regression Testing (10-15 min)

Mark todo #5 as in_progress.

### Run Full Test Suite

```bash
# Ensure all tests still pass
npm test

# Check coverage hasn't decreased
npm run test:coverage

# Save coverage report
cp coverage/coverage-summary.json .agency/optimizations/final-coverage.json
```

### Run Final Comprehensive Benchmark

Run complete benchmark suite to capture final state:

```bash
# Bundle
npm run build
du -sh .next/ > .agency/optimizations/final-bundle.txt

# Lighthouse (if rendering optimization)
lighthouse http://localhost:3000 --output json --output-path .agency/optimizations/final-lighthouse.json

# API (if API optimization)
autocannon -c 10 -d 30 http://localhost:3000/api/endpoint > .agency/optimizations/final-api.txt

# Database (if database optimization)
# Re-run slow queries and compare
```

### Compare Final vs Baseline

Create comparison showing improvements:

```markdown
# Final vs Baseline Comparison

## Bundle Size (if applicable)
- Baseline: [X MB]
- Final: [Y MB]
- **Improvement: [Z%] reduction**

## Database Queries (if applicable)
- Baseline avg query time: [X ms]
- Final avg query time: [Y ms]
- **Improvement: [Z%] faster**

## Rendering Performance (if applicable)
- Baseline LCP: [X ms]
- Final LCP: [Y ms]
- **Improvement: [Z%] faster**

## API Performance (if applicable)
- Baseline RPS: [X]
- Final RPS: [Y]
- **Improvement: [Z%] more requests/sec**

## Memory Usage (if applicable)
- Baseline heap: [X MB]
- Final heap: [Y MB]
- **Improvement: [Z%] reduction**
```

### Verify No Regressions

Check for unintended negative impacts:

```bash
# Build time (should not significantly increase)
# Bundle size for other chunks (shouldn't grow)
# Test execution time (shouldn't slow down)
# Development server startup (shouldn't slow down)
```

If regressions found, decide if trade-off is acceptable or if rollback needed.

### Consistency Check

Run benchmarks multiple times (3 runs) to ensure consistency:

```bash
# Run benchmark 3 times
for i in 1 2 3; do
  echo "Run $i:"
  [benchmark command] > .agency/optimizations/consistency-run-$i.txt
done

# Verify results are within 5% variance
```

Mark todo #5 as completed.

---

## Phase 6: Performance Report & Recommendations (5-7 min)

Mark todo #6 as in_progress.

### Generate Comprehensive Performance Report

Create detailed report with all findings:

```markdown
# Performance Optimization Report

**Date**: [current date]
**Target**: [optimization target]
**Framework**: [detected framework]
**Duration**: [total time spent]

---

## Executive Summary

[Brief overview of what was optimized and overall results]

**Key Results**:
- [Metric 1]: [X%] improvement ([baseline] → [final])
- [Metric 2]: [Y%] improvement ([baseline] → [final])
- [Metric 3]: [Z%] improvement ([baseline] → [final])

**Optimizations Implemented**: [N successful] / [M attempted]

---

## Baseline Performance

[Include baseline metrics from Phase 2]

### Bottlenecks Identified

1. **[Bottleneck 1]**: [description]
   - Impact: High
   - Root cause: [explanation]

2. **[Bottleneck 2]**: [description]
   - Impact: Medium
   - Root cause: [explanation]

---

## Optimizations Implemented

### Successfully Implemented

#### 1. [Optimization Name] ✅

**Type**: [bundle/database/rendering/api/memory]
**Impact**: [High/Medium/Low]
**Effort**: [Low/Medium/High]

**Changes Made**:
- [File 1]: [changes]
- [File 2]: [changes]

**Results**:
- Baseline: [value]
- Final: [value]
- **Improvement: [X%]**

**Commit**: [commit hash]

---

#### 2. [Optimization Name] ✅

[Same structure as above]

---

### Attempted but Rolled Back

#### 1. [Optimization Name] ⏪

**Reason for Rollback**: [No improvement / Test failures / Regression in other area]

**What We Learned**: [Insight from attempt]

---

## Final Performance Metrics

### [Target-Specific Metrics]

[Include final benchmark results]

**Comparison to Baseline**:

| Metric | Baseline | Final | Improvement |
|--------|----------|-------|-------------|
| [Metric 1] | [X] | [Y] | **[Z%]** |
| [Metric 2] | [X] | [Y] | **[Z%]** |
| [Metric 3] | [X] | [Y] | **[Z%]** |

**Overall Performance Improvement**: [Overall %]

---

## Verification

### Tests
- ✅ All tests passing ([N] tests)
- ✅ Coverage maintained: [X%]

### Build
- ✅ Build successful
- ✅ Build time: [X seconds] (baseline: [Y seconds])

### No Regressions Detected
- ✅ Bundle size for other chunks stable
- ✅ Development server startup time stable
- ✅ Test execution time stable

---

## Recommendations for Further Optimization

### Immediate Opportunities (Not Implemented)

1. **[Opportunity 1]**: [description]
   - Expected impact: [X%]
   - Reason not implemented: [time/complexity/risk]
   - Recommended for next optimization cycle

2. **[Opportunity 2]**: [description]
   - Expected impact: [Y%]
   - Reason not implemented: [time/complexity/risk]

### Long-Term Recommendations

1. **[Recommendation 1]**: [description]
   - Requires: [infrastructure/refactoring/new tool]
   - Expected impact: [X%]

2. **[Recommendation 2]**: [description]
   - Requires: [infrastructure/refactoring/new tool]
   - Expected impact: [Y%]

### Monitoring Recommendations

To maintain performance improvements:

1. **Set up performance monitoring**:
   - [Tool recommendation]: [why]
   - Key metrics to track: [list]

2. **Establish performance budgets**:
   - Bundle size: max [X] MB
   - LCP: max [Y] ms
   - API p95: max [Z] ms

3. **Regular performance audits**:
   - Frequency: [monthly/quarterly]
   - Triggers: [before major releases, after large features]

---

## Artifacts

All optimization artifacts saved to `.agency/optimizations/`:

- `baseline-report.md` - Initial profiling results
- `baseline/` - Baseline benchmark data
- `benchmarks/` - Per-optimization benchmarks
- `execution-log.md` - Detailed execution log
- `final-*.txt` - Final benchmark results
- `optimization-report-[date].md` - This report

---

## Conclusion

[Summary of optimization success, key learnings, and next steps]

**Status**: ✅ Optimization Complete

---

**Generated**: [timestamp]
**Optimization Target**: $ARGUMENTS
```

Save this report to `.agency/optimizations/optimization-report-[date].md`

Mark todo #6 as completed.

---

## Error Handling

### If Profiling Fails

**Profiling Tool Not Available**:
- Install the tool if possible (`npm install -g lighthouse`, etc.)
- Or use alternative profiling method
- Document limitation in baseline report

**Application Won't Start**:
- Check that dependencies are installed
- Verify environment variables set
- Fix issues before proceeding

**Baseline Capture Fails**:
- Try manual profiling
- Document process in baseline report
- Ensure at least basic metrics captured

### If Optimization Fails

**Implementation Error**:
- Review error from specialist agent
- Either fix directly or re-delegate with adjusted instructions
- If repeated failures, mark optimization as "attempted but blocked"

**Benchmark Failure**:
- Verify application still works
- Check if benchmark tool has issues
- Try alternative benchmarking method

**No Improvement**:
- Roll back the optimization (git reset)
- Document why it didn't work
- Move to next optimization

### If Verification Fails

**Tests Fail**:
- Do NOT proceed to commit
- Roll back to last working state
- Identify which optimization broke tests
- Fix or skip that optimization

**Regression Detected**:
- Assess severity of regression
- If severe, roll back
- If minor, ask user if trade-off acceptable
- Document trade-offs in report

### If User Requests Changes

**Change Target Mid-Optimization**:
- Complete current optimization or roll back
- Switch to new target
- Restart from Phase 1

**Abort Optimization**:
- Save current progress
- Generate partial report
- Reset to baseline if requested

---

## Important Notes

### Optimization Principles

1. **Measure First**: Never optimize without profiling - you might optimize the wrong thing
2. **Incremental Changes**: One optimization at a time allows isolation of impact
3. **Always Benchmark**: Numbers don't lie - measure every change
4. **Preserve Functionality**: All tests must pass - performance without correctness is worthless
5. **Document Trade-offs**: Some optimizations have costs (complexity, maintenance)

### Safety Guidelines

- **Always create git checkpoints** before each optimization
- **Never skip testing** - performance improvements that break functionality are regressions
- **Rollback liberally** - if no improvement, don't keep the change
- **Verify consistency** - run benchmarks multiple times to ensure stable results
- **Watch for regressions** - improvements in one area shouldn't hurt another

### Performance Budgets

After optimization, consider setting performance budgets:

**Bundle Size**:
- Initial bundle: max 200KB (gzipped)
- Total bundle: max 1MB (gzipped)
- Individual chunks: max 100KB (gzipped)

**Web Vitals**:
- LCP: < 2.5s (good), < 4.0s (needs improvement)
- FID: < 100ms (good), < 300ms (needs improvement)
- CLS: < 0.1 (good), < 0.25 (needs improvement)

**API Performance**:
- P50 latency: < 100ms
- P95 latency: < 500ms
- P99 latency: < 1000ms

**Database**:
- Average query time: < 50ms
- Slow query threshold: > 100ms
- No N+1 queries

### Common Optimization Techniques

**Bundle Optimization**:
- Code splitting (route-based, component-based)
- Tree shaking (remove unused code)
- Lazy loading (defer non-critical code)
- Compression (Brotli > gzip)
- Minification (terser, esbuild)

**Database Optimization**:
- Indexes (on frequently queried columns)
- Query optimization (avoid SELECT *, use LIMIT)
- Connection pooling (reduce connection overhead)
- Caching (Redis, in-memory)
- Batch operations (reduce round trips)

**Rendering Optimization**:
- React.memo (prevent unnecessary re-renders)
- useMemo/useCallback (memoize expensive computations)
- Virtual scrolling (for long lists)
- Image optimization (next/image, responsive images)
- Font optimization (font-display: swap, subset fonts)

**API Optimization**:
- Caching (HTTP caching, API-level caching)
- Request batching (combine multiple requests)
- Parallel requests (fetch independent data simultaneously)
- Response compression (gzip, Brotli)
- CDN (for static assets)

**Memory Optimization**:
- Fix memory leaks (event listeners, closures, timers)
- Object pooling (reuse objects instead of creating new)
- WeakMap/WeakSet (allow garbage collection)
- Stream processing (for large data)
- Lazy initialization (defer object creation)

---

## Skills to Reference

Activate and reference these skills as needed:

**Required**:
- `agency-workflow-patterns` - Orchestration patterns (ACTIVATE IMMEDIATELY)

**Technology-Specific** (activate based on project):
- `nextjs-16-expert` - Next.js optimization techniques
- `react-performance` - React rendering optimization
- `database-optimization` - SQL query and index optimization
- `webpack-optimization` - Bundle optimization strategies

**Specialist Skills**:
- `web-performance` - Web vitals and Lighthouse optimization
- `node-performance` - Node.js profiling and optimization
- `api-performance` - REST/GraphQL API optimization

---

## Related Commands

- `/agency:work [issue]` - Implement issue (may include performance improvements)
- `/agency:review [pr]` - Review PR (can check for performance issues)
- `/agency:test [component]` - Generate tests (including performance tests)
- `/agency:refactor [scope]` - Refactor code (often improves performance as side effect)

---

**Remember**:

- **Measure, don't guess**: Profile before optimizing
- **One change at a time**: Isolate the impact of each optimization
- **Benchmark everything**: Numbers prove improvement
- **Preserve functionality**: Tests must pass
- **Document results**: Future you (and your team) will thank you

Performance optimization is a scientific process: hypothesize, experiment, measure, conclude.

---

**End of /agency:optimize command**
