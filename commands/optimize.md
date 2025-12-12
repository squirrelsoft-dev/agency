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

<!-- Component: prompts/context/framework-detection.md -->
### Detect Framework/Language

Execute framework detection to determine the application framework. This will guide profiling tool selection and optimization strategies.

Refer to framework detection component for full detection logic covering:
- Next.js (React framework)
- Django, Flask, FastAPI (Python)
- Laravel (PHP)
- Express.js (Node.js)
- And others

**Store result in**: `FRAMEWORK` variable

<!-- Component: prompts/context/database-detection.md -->
### Detect Database/ORM

Execute database/ORM detection to identify the data layer technology. This is essential for database optimization targets.

Refer to database detection component for full detection logic covering:
- Prisma, Drizzle ORM, TypeORM, Sequelize (Node.js)
- Django ORM, SQLAlchemy (Python)
- Eloquent (Laravel)
- ActiveRecord (Rails)

**Store result in**: `DATABASE` variable

<!-- Component: prompts/context/build-tool-detection.md -->
### Detect Build Tool

Execute build tool detection to identify the bundler/build system. Required for bundle optimization targets.

Refer to build tool detection component for full detection logic covering:
- Next.js (built-in)
- Vite
- Webpack
- Rollup
- Parcel
- esbuild

**Store result in**: `BUILD_TOOL` variable

<!-- Component: prompts/context/testing-framework-detection.md -->
### Detect Testing Framework

Execute testing framework detection for benchmark verification.

Refer to testing framework detection component for full detection logic covering:
- Jest, Vitest, Mocha (JavaScript/TypeScript)
- Playwright, Cypress (E2E)
- pytest, unittest (Python)
- PHPUnit (PHP)

**Store result in**: `TEST_FRAMEWORK` variable

**Use detected context to**:
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

<!-- Component: prompts/progress/todo-initialization.md -->
### Create Todo List for Optimization

Use TodoWrite to create tracking for optimization phases:

```javascript
[
  {
    "content": "Detect optimization target",
    "status": "in_progress",
    "activeForm": "Detecting optimization target"
  },
  {
    "content": "Profile current performance (baseline)",
    "status": "pending",
    "activeForm": "Profiling current performance"
  },
  {
    "content": "Create optimization plan",
    "status": "pending",
    "activeForm": "Creating optimization plan"
  },
  {
    "content": "Implement optimizations incrementally",
    "status": "pending",
    "activeForm": "Implementing optimizations"
  },
  {
    "content": "Verify improvements with benchmarks",
    "status": "pending",
    "activeForm": "Verifying improvements"
  },
  {
    "content": "Generate performance report",
    "status": "pending",
    "activeForm": "Generating performance report"
  }
]
```

<!-- Component: prompts/specialist-selection/user-approval.md -->
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

<!-- Component: prompts/git/commit-formatting.md -->
#### Step 6: Commit or Rollback

**If improvement is acceptable and tests pass**:

Use conventional commit format with the `perf` type for performance improvements:

```bash
git add -A
git commit -m "$(cat <<'EOF'
perf($ARGUMENTS): $CURRENT_OPT

Improved [metric] by [X%]
Baseline: [baseline value]
Current: [current value]

Performance optimization as part of incremental improvement workflow.
EOF
)"

echo "✅ Committed: $CURRENT_OPT" >> .agency/optimizations/execution-log.md
echo "Improvement: [X%]" >> .agency/optimizations/execution-log.md
```

Refer to commit formatting component for detailed commit message standards and best practices.

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

<!-- Component: prompts/quality-gates/quality-gate-sequence.md -->
### Run Quality Gates

Execute quality gates in order to ensure optimizations haven't broken functionality:

1. **Build** - Verify code compiles/builds successfully
2. **Type Check** - Verify TypeScript types are correct
3. **Linter** - Check code style and quality
4. **Tests** - Execute test suite to verify functionality
5. **Coverage** - Verify sufficient test coverage (target 80%+)

Refer to quality gate sequence component for detailed execution instructions and failure handling.

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

<!-- Component: prompts/reporting/metrics-comparison.md -->
### Compare Final vs Baseline

Create metrics comparison showing improvements using the standard metrics comparison template.

Generate a comparison table showing:
- Before/After values for each key metric
- Absolute change (+/- values)
- Percentage improvement
- Status indicators (✅/⚠️/❌)

**Key Metrics by Target**:
- **Bundle**: Total size, chunk sizes, lazy loading
- **Database**: Query time, query count, N+1 issues
- **Rendering**: LCP, FCP, TTI, CLS, TBT
- **API**: Response time, throughput (RPS), P95/P99 latency
- **Memory**: Heap size, GC frequency, leak detection

Refer to metrics comparison component for detailed table formats and calculation formulas.

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

<!-- Component: prompts/reporting/summary-template.md -->
<!-- Component: prompts/reporting/metrics-comparison.md -->
### Generate Comprehensive Performance Report

Create a detailed performance optimization report using an adapted version of the implementation summary template.

**Report Structure**:

#### Header Section
```markdown
# Performance Optimization Report: [Target]

**Date**: [YYYY-MM-DD HH:MM:SS]
**Target**: [optimization target]
**Framework**: [detected framework]
**Duration**: [total time spent]
**Status**: ✅ SUCCESS / ⚠️ PARTIAL / ❌ FAILED
```

#### Executive Summary
Brief overview (2-3 sentences) of what was optimized and overall results.

**Key Results** (top 3 metrics improved)

**Optimizations**: [N successful] / [M attempted]

#### Baseline Performance
- Reference baseline report from Phase 2
- List key bottlenecks identified
- Root causes of performance issues

#### Optimizations Implemented

For each optimization:
- **Successfully Implemented** ✅
  - Type (bundle/database/rendering/api/memory)
  - Impact level (High/Medium/Low)
  - Changes made (files modified)
  - Before/After metrics
  - Improvement percentage
  - Commit hash

- **Attempted but Rolled Back** ⏪
  - Reason for rollback
  - Learnings from the attempt

#### Final Performance Metrics

Use **metrics comparison component** to generate comparison tables showing:
- Baseline vs Final for all key metrics
- Percentage improvements
- Status indicators
- Target achievement

#### Verification Results
- Build: ✅/❌
- Type Check: ✅/❌
- Linter: ✅/⚠️/❌
- Tests: [X/Y passed]
- Coverage: [X%]
- No regressions detected

#### Recommendations

**Immediate Opportunities** (not implemented):
- Description
- Expected impact
- Reason not implemented
- Recommendation for next cycle

**Long-Term Recommendations**:
- Infrastructure improvements
- Expected impact
- Requirements

**Monitoring Recommendations**:
- Performance monitoring setup
- Performance budgets
- Audit frequency and triggers

#### Artifacts
List all files saved to `.agency/optimizations/`:
- baseline-report.md
- baseline/ directory
- benchmarks/ directory
- execution-log.md
- final-* files
- This report

#### Conclusion
Summary of success, key learnings, and next steps.

**Save report to**: `.agency/optimizations/optimization-report-[YYYYMMDD-HHMMSS].md`

Refer to summary template component for detailed section formats and best practices.

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
