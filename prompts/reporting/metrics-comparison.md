# Reporting: Metrics Comparison Template

Standardized format for before/after metrics tables showing improvements from implementation.

## When to Use

**Include metrics comparison when**:
- Performance optimization implemented
- Code quality improvements made
- Test coverage increased
- Build/bundle size reduced
- Security vulnerabilities fixed
- Technical debt reduced

**Skip if**:
- New feature with no baseline
- Metrics not applicable
- No before state to compare

---

## Metric Categories

### Performance Metrics

**Web Vitals**:
- Largest Contentful Paint (LCP)
- First Contentful Paint (FCP)
- Time to Interactive (TTI)
- Cumulative Layout Shift (CLS)
- First Input Delay (FID)
- Total Blocking Time (TBT)

**Bundle Metrics**:
- Bundle size (KB/MB)
- Number of chunks
- Code splitting effectiveness
- Lazy loading usage

**Runtime Metrics**:
- API response time
- Database query time
- Cache hit rate
- Memory usage

### Code Quality Metrics

**Linting**:
- Error count
- Warning count
- Rule violations

**Type Coverage**:
- Type coverage percentage
- Any types count
- Type errors

**Complexity**:
- Cyclomatic complexity
- Lines of code
- Function length
- Nesting depth

### Testing Metrics

**Coverage**:
- Line coverage %
- Branch coverage %
- Function coverage %
- Statement coverage %

**Test Count**:
- Total tests
- Passing tests
- Failing tests
- Skipped tests

**Test Performance**:
- Test suite duration
- Slowest tests
- Flaky test count

### Security Metrics

**Vulnerabilities**:
- Critical vulnerabilities
- High vulnerabilities
- Medium vulnerabilities
- Low vulnerabilities

**Dependencies**:
- Outdated dependencies
- Dependencies with known CVEs
- License issues

### Build Metrics

**Build Time**:
- Total build duration
- Type check duration
- Lint duration
- Test duration

**Artifact Size**:
- Output size
- Compression ratio
- Asset count

---

## Comparison Table Template

### Basic Two-Column Comparison

```markdown
## Metrics Comparison

| Metric | Before | After | Change | Improvement |
|--------|--------|-------|--------|-------------|
| [Metric Name] | [Before Value] | [After Value] | [+/-X] | [+X%] / [-X%] |
```

**Example**:
```markdown
## Performance Metrics

| Metric | Before | After | Change | Improvement |
|--------|--------|-------|--------|-------------|
| Bundle Size | 450 KB | 320 KB | -130 KB | -28.9% ↓ |
| LCP | 3.2s | 1.8s | -1.4s | -43.8% ↓ |
| TTI | 5.1s | 2.9s | -2.2s | -43.1% ↓ |
| API Response | 850ms | 340ms | -510ms | -60.0% ↓ |
```

### Multi-Category Comparison

```markdown
## Metrics Summary

### Performance

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| [Metric 1] | [Value] | [Value] | [+/-X%] |
| [Metric 2] | [Value] | [Value] | [+/-X%] |

### Code Quality

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| [Metric 1] | [Value] | [Value] | [+/-X%] |
| [Metric 2] | [Value] | [Value] | [+/-X%] |

### Testing

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| [Metric 1] | [Value] | [Value] | [+/-X%] |
| [Metric 2] | [Value] | [Value] | [+/-X%] |
```

### Detailed Comparison with Status

```markdown
## Detailed Metrics

| Category | Metric | Before | After | Change | Status | Notes |
|----------|--------|--------|-------|--------|--------|-------|
| Performance | Bundle Size | 450 KB | 320 KB | -130 KB (-28.9%) | ✅ Target Met | Target: <350 KB |
| Performance | LCP | 3.2s | 1.8s | -1.4s (-43.8%) | ✅ Target Met | Target: <2.5s |
| Quality | Lint Errors | 24 | 0 | -24 (100%) | ✅ Resolved | All errors fixed |
| Quality | TypeScript Errors | 8 | 0 | -8 (100%) | ✅ Resolved | Type safety complete |
| Testing | Coverage | 65% | 82% | +17% | ✅ Target Met | Target: >80% |
| Testing | Passing Tests | 45/48 | 57/57 | +12 tests | ✅ All Pass | All tests passing |
```

---

## Formatting Guidelines

### Numbers

**File Sizes**:
- Use appropriate units: B, KB, MB, GB
- Round to 1-2 decimal places
- Example: `1.5 MB`, `450 KB`, `32 B`

**Percentages**:
- Show 1 decimal place for precision
- Include sign (+/-)
- Example: `+28.5%`, `-15.3%`

**Time Durations**:
- Use appropriate units: ms, s, min
- Round to 1 decimal place
- Example: `1.5s`, `850ms`, `2.3 min`

**Counts**:
- Whole numbers only
- Use commas for thousands
- Example: `1,234`, `45`, `0`

### Change Indicators

**Arrows**:
- Improvement: ↓ (for reductions in bad metrics)
- Improvement: ↑ (for increases in good metrics)
- Regression: ↑ (for increases in bad metrics)
- Regression: ↓ (for decreases in good metrics)

**Color Indicators** (using emoji):
- ✅ Good/Met Target
- ⚠️ Warning/Partial
- ❌ Bad/Regression

**Examples**:
- `+17% ↑` - Coverage increased (good)
- `-130 KB ↓` - Bundle size decreased (good)
- `+5 errors ↑` - Errors increased (bad)
- `-15% ↓` - Coverage decreased (bad)

### Status Indicators

**Status Values**:
- `✅ Target Met` - Meets or exceeds target
- `✅ Resolved` - Issue completely fixed
- `✅ All Pass` - All items passing
- `⚠️ Improved` - Better but not at target
- `⚠️ Partial` - Some improvement
- `❌ Regression` - Worse than before
- `❌ Target Missed` - Did not meet target

---

## Calculation Formulas

### Percentage Change

```
percentage_change = ((after - before) / before) × 100

Examples:
- Coverage: 65% → 82% = ((82 - 65) / 65) × 100 = +26.2%
- Bundle: 450 KB → 320 KB = ((320 - 450) / 450) × 100 = -28.9%
```

### Absolute Change

```
absolute_change = after - before

Examples:
- Tests: 48 → 57 = +9 tests
- Errors: 24 → 0 = -24 errors
```

### Improvement Rate

```
For reductions (lower is better):
  improvement = ((before - after) / before) × 100

For increases (higher is better):
  improvement = ((after - before) / before) × 100

Examples:
- Response time: 850ms → 340ms
  Improvement = ((850 - 340) / 850) × 100 = 60.0% faster
- Coverage: 65% → 82%
  Improvement = ((82 - 65) / 65) × 100 = 26.2% increase
```

---

## Metric-Specific Templates

### Performance Optimization

```markdown
## Performance Improvements

### Web Vitals

| Metric | Before | After | Improvement | Target | Status |
|--------|--------|-------|-------------|--------|--------|
| LCP (Largest Contentful Paint) | 3.2s | 1.8s | -1.4s (-43.8%) ↓ | <2.5s | ✅ Met |
| FCP (First Contentful Paint) | 1.8s | 0.9s | -0.9s (-50.0%) ↓ | <1.8s | ✅ Met |
| TTI (Time to Interactive) | 5.1s | 2.9s | -2.2s (-43.1%) ↓ | <3.8s | ✅ Met |
| CLS (Cumulative Layout Shift) | 0.15 | 0.05 | -0.10 (-66.7%) ↓ | <0.1 | ✅ Met |
| TBT (Total Blocking Time) | 450ms | 180ms | -270ms (-60.0%) ↓ | <300ms | ✅ Met |

### Bundle Analysis

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Total Bundle Size | 1.2 MB | 850 KB | -350 KB (-29.2%) ↓ |
| Main Bundle | 450 KB | 320 KB | -130 KB (-28.9%) ↓ |
| Vendor Bundle | 750 KB | 530 KB | -220 KB (-29.3%) ↓ |
| Number of Chunks | 8 | 12 | +4 (+50.0%) ↑ |
| Lazy Loaded Routes | 3 | 7 | +4 (+133.3%) ↑ |

### Runtime Performance

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| API Response Time (avg) | 850ms | 340ms | -510ms (-60.0%) ↓ |
| Database Query Time | 120ms | 45ms | -75ms (-62.5%) ↓ |
| Cache Hit Rate | 45% | 78% | +33% (+73.3%) ↑ |
| Memory Usage | 180 MB | 125 MB | -55 MB (-30.6%) ↓ |
```

### Code Quality Improvement

```markdown
## Code Quality Metrics

### Linting Results

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Total Issues | 156 | 12 | -144 (-92.3%) ↓ |
| Errors | 24 | 0 | -24 (100%) ✅ |
| Warnings | 132 | 12 | -120 (-90.9%) ↓ |

**Top Issues Resolved**:
- `no-unused-vars`: 45 instances → 0
- `no-explicit-any`: 18 instances → 0
- `prefer-const`: 32 instances → 0

### Type Coverage

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Type Coverage | 72% | 95% | +23% (+31.9%) ↑ |
| `any` Types | 45 | 3 | -42 (-93.3%) ↓ |
| Type Errors | 8 | 0 | -8 (100%) ✅ |
| Strict Mode | ❌ Disabled | ✅ Enabled | ✅ |

### Code Complexity

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Avg Cyclomatic Complexity | 8.5 | 4.2 | -4.3 (-50.6%) ↓ |
| Functions >50 lines | 23 | 7 | -16 (-69.6%) ↓ |
| Max Nesting Depth | 6 | 3 | -3 (-50.0%) ↓ |
| Duplicate Code Blocks | 12 | 2 | -10 (-83.3%) ↓ |
```

### Test Coverage Improvement

```markdown
## Testing Metrics

### Coverage

| Coverage Type | Before | After | Improvement | Target | Status |
|---------------|--------|-------|-------------|--------|--------|
| Line Coverage | 65.3% | 82.1% | +16.8% (+25.7%) ↑ | >80% | ✅ Met |
| Branch Coverage | 58.7% | 76.4% | +17.7% (+30.2%) ↑ | >75% | ✅ Met |
| Function Coverage | 70.2% | 88.5% | +18.3% (+26.1%) ↑ | >85% | ✅ Met |
| Statement Coverage | 66.1% | 83.2% | +17.1% (+25.9%) ↑ | >80% | ✅ Met |

### Test Suite

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Total Tests | 145 | 203 | +58 (+40.0%) ↑ |
| Passing | 142 | 203 | +61 (+43.0%) ↑ |
| Failing | 3 | 0 | -3 (100%) ✅ |
| Skipped | 0 | 0 | No change |
| Test Duration | 45.2s | 38.7s | -6.5s (-14.4%) ↓ |

### Coverage Gaps Closed

| Module | Before | After | Improvement |
|--------|--------|-------|-------------|
| Authentication | 45% | 92% | +47% (+104.4%) ↑ |
| API Handlers | 58% | 85% | +27% (+46.6%) ↑ |
| Database Layer | 72% | 88% | +16% (+22.2%) ↑ |
| UI Components | 68% | 79% | +11% (+16.2%) ↑ |
```

### Security Improvement

```markdown
## Security Metrics

### Vulnerabilities

| Severity | Before | After | Fixed |
|----------|--------|-------|-------|
| Critical | 2 | 0 | -2 (100%) ✅ |
| High | 5 | 0 | -5 (100%) ✅ |
| Medium | 12 | 3 | -9 (-75.0%) ↓ |
| Low | 23 | 18 | -5 (-21.7%) ↓ |
| **Total** | **42** | **21** | **-21 (-50.0%)** ↓ |

### Dependencies

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Outdated Packages | 34 | 8 | -26 (-76.5%) ↓ |
| Packages with CVEs | 7 | 0 | -7 (100%) ✅ |
| Major Version Behind | 12 | 3 | -9 (-75.0%) ↓ |
| License Issues | 2 | 0 | -2 (100%) ✅ |

### Security Practices

| Practice | Before | After | Status |
|----------|--------|-------|--------|
| Input Validation | ⚠️ Partial | ✅ Complete | ✅ Implemented |
| SQL Injection Prevention | ⚠️ Some endpoints | ✅ All endpoints | ✅ Secured |
| XSS Protection | ❌ Missing | ✅ Implemented | ✅ Protected |
| CSRF Tokens | ❌ Not used | ✅ Enabled | ✅ Protected |
| Authentication | ⚠️ Basic | ✅ JWT + Refresh | ✅ Enhanced |
```

### Build Performance

```markdown
## Build Metrics

### Build Times

| Stage | Before | After | Improvement |
|-------|--------|-------|-------------|
| Type Check | 12.3s | 8.5s | -3.8s (-30.9%) ↓ |
| Linting | 8.7s | 6.2s | -2.5s (-28.7%) ↓ |
| Compilation | 45.2s | 32.1s | -13.1s (-29.0%) ↓ |
| Testing | 52.8s | 38.7s | -14.1s (-26.7%) ↓ |
| **Total Build** | **2m 59s** | **2m 5s** | **-54s (-30.2%)** ↓ |

### Build Artifacts

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Output Size | 2.8 MB | 1.9 MB | -0.9 MB (-32.1%) ↓ |
| Gzipped Size | 890 KB | 620 KB | -270 KB (-30.3%) ↓ |
| Number of Files | 234 | 189 | -45 (-19.2%) ↓ |
| Source Maps Size | 4.5 MB | 3.1 MB | -1.4 MB (-31.1%) ↓ |
```

---

## Summary Section Template

After detailed metrics, provide a summary:

```markdown
## Metrics Summary

**Overall Improvement**: [X]% average improvement across all metrics

**Key Achievements**:
- ✅ [Achievement 1 with metric]
- ✅ [Achievement 2 with metric]
- ✅ [Achievement 3 with metric]

**Most Significant Improvements**:
1. **[Metric Name]**: [Before] → [After] ([+/-X%] improvement)
   - Impact: [What this means for users/system]
2. **[Metric Name]**: [Before] → [After] ([+/-X%] improvement)
   - Impact: [What this means for users/system]
3. **[Metric Name]**: [Before] → [After] ([+/-X%] improvement)
   - Impact: [What this means for users/system]

**Targets Met**: [X/Y] ([Z]%)

**Remaining Work**:
- [Metric still below target]
- [Area needing improvement]
```

**Example**:
```markdown
## Metrics Summary

**Overall Improvement**: 42% average improvement across all metrics

**Key Achievements**:
- ✅ All critical and high security vulnerabilities resolved (100%)
- ✅ Test coverage increased from 65% to 82% (+17%)
- ✅ Bundle size reduced by 29%, improving load times by 44%

**Most Significant Improvements**:
1. **API Response Time**: 850ms → 340ms (-60.0% improvement)
   - Impact: Faster page loads and better user experience
2. **Security Vulnerabilities**: 42 → 21 (-50.0% improvement)
   - Impact: Significantly reduced attack surface
3. **Test Coverage**: 65% → 82% (+26.2% improvement)
   - Impact: Higher confidence in code reliability

**Targets Met**: 8/10 (80%)

**Remaining Work**:
- Medium security vulnerabilities: 3 remaining (target: 0)
- Branch coverage: 76% (target: 80%)
```

---

## Best Practices

### Data Collection

1. **Capture Baseline**: Always record before metrics at start
2. **Use Same Tools**: Ensure before/after use identical measurement methods
3. **Multiple Runs**: Average multiple measurements for accuracy
4. **Document Environment**: Note conditions that affect metrics

### Presentation

1. **Focus on Impact**: Highlight most significant changes
2. **Use Consistent Units**: Don't mix KB and MB in same column
3. **Round Appropriately**: 1-2 decimal places sufficient
4. **Show Context**: Include targets and status indicators
5. **Explain Significance**: Note what improvements mean for users

### Honesty

1. **Show Regressions**: Don't hide negative changes
2. **Explain Trade-offs**: Some metrics may worsen for good reasons
3. **Note Limitations**: Acknowledge what wasn't measured
4. **Realistic Targets**: Set achievable benchmarks

---

## Quick Reference

**Improvement Direction**:
- Performance (LCP, TTI, response time): Lower is better ↓
- Bundle size, memory usage: Lower is better ↓
- Coverage, cache hit rate: Higher is better ↑
- Errors, vulnerabilities: Lower is better (ideally 0) ↓
- Test count: Higher is better ↑
- Build time: Lower is better ↓

**Status Shortcuts**:
- All errors fixed: `✅ Resolved`
- Target achieved: `✅ Target Met`
- All tests pass: `✅ All Pass`
- Improved but not target: `⚠️ Improved`
- Worse than before: `❌ Regression`
