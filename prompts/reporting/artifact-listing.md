# Reporting: Artifact Listing Template

Standardized format for listing generated files, reports, logs, and other artifacts.

## When to Use

**List artifacts after**:
- Implementation completion
- Code review
- Testing
- Build/deployment
- Report generation
- Multi-specialist handoff

**Purpose**: Provide clear inventory of all generated outputs for reference and verification.

---

## Artifact Categories

### Implementation Artifacts

**Code Files**:
- Source code (`.ts`, `.tsx`, `.js`, `.jsx`)
- Configuration files (`.json`, `.yaml`, `.toml`)
- Style files (`.css`, `.scss`, `.module.css`)
- Test files (`.test.ts`, `.spec.ts`)

**Documentation**:
- README files
- API documentation
- ADRs (Architecture Decision Records)
- Code comments
- Type definitions

**Data/Schema**:
- Database migrations
- Schema definitions
- Seed data files
- SQL scripts

### Report Artifacts

**Quality Reports**:
- Implementation summaries
- Code review reports
- Verification results
- Test coverage reports

**Metrics Reports**:
- Performance benchmarks
- Build reports
- Security scan results
- Dependency audits

### Build Artifacts

**Compiled Output**:
- Build output files
- Bundled assets
- Minified code
- Source maps

**Deployment Artifacts**:
- Docker images
- Container configs
- Deployment manifests
- Environment configs

### Test Artifacts

**Test Output**:
- Test results
- Coverage reports
- Test logs
- Screenshots (E2E tests)

**Test Data**:
- Mock data files
- Test fixtures
- Snapshot files

### Handoff Artifacts

**Multi-Specialist**:
- Per-specialist plans
- Specialist summaries
- Verification reports
- Integration documentation
- Execution state

---

## Listing Template

### Simple File List

```markdown
## Artifacts Generated

### Created Files ([X] total)

- `path/to/file1.ts` - [Brief description]
- `path/to/file2.tsx` - [Brief description]
- `path/to/file3.test.ts` - [Brief description]

### Modified Files ([Y] total)

- `path/to/file4.ts` - [What changed]
- `path/to/file5.tsx` - [What changed]

### Deleted Files ([Z] total)

- `path/to/old-file.ts` - [Why deleted]
```

### Categorized Artifact List

```markdown
## Implementation Artifacts

### Source Code ([X] files)

**Components**:
- `src/components/LoginForm.tsx` - Login form component with validation
- `src/components/RegisterForm.tsx` - User registration form
- `src/components/ProtectedRoute.tsx` - Route wrapper for authentication

**API Handlers**:
- `src/api/auth/login.ts` - POST /api/auth/login endpoint
- `src/api/auth/register.ts` - POST /api/auth/register endpoint
- `src/api/auth/logout.ts` - POST /api/auth/logout endpoint

**Utilities**:
- `src/lib/auth.ts` - Authentication utilities and JWT handling
- `src/lib/validation.ts` - Input validation helpers

### Tests ([Y] files)

- `src/components/LoginForm.test.tsx` - Login form component tests (12 tests)
- `src/api/auth/login.test.ts` - Login endpoint tests (8 tests)
- `src/lib/auth.test.ts` - Auth utilities tests (15 tests)

### Configuration ([Z] files)

- `.env.example` - Environment variables template
- `prisma/schema.prisma` - Updated database schema with User model

### Documentation ([W] files)

- `docs/api/authentication.md` - Authentication API documentation
- `docs/architecture/auth-flow.md` - Authentication flow ADR

## Report Artifacts

### Quality Reports

- `.agency/implementations/impl-user-auth-20241211-143022.md` - Implementation summary
- `.agency/reviews/review-user-auth-20241211-150033.md` - Code review report

### Test Reports

- `coverage/lcov-report/index.html` - HTML coverage report
- `coverage/coverage-summary.json` - Coverage summary JSON

## Build Artifacts

### Output Files

- `.next/` - Next.js build output (production build)
- `.next/static/` - Static assets bundle (1.2 MB)
```

### Detailed Artifact List with Metadata

```markdown
## Artifacts Inventory

| Type | Path | Description | Size | Lines | Purpose |
|------|------|-------------|------|-------|---------|
| Component | `src/components/LoginForm.tsx` | Login form with validation | 4.2 KB | 142 | User authentication UI |
| API | `src/api/auth/login.ts` | Login endpoint handler | 2.1 KB | 68 | Process login requests |
| Test | `src/api/auth/login.test.ts` | Login endpoint tests | 3.5 KB | 98 | Verify login logic |
| Config | `prisma/schema.prisma` | Database schema | 1.8 KB | 54 | Define User model |
| Docs | `docs/api/authentication.md` | API documentation | 6.3 KB | 203 | Document auth endpoints |
| Report | `.agency/implementations/impl-user-auth.md` | Implementation summary | 12.4 KB | 380 | Track implementation |

**Totals**: 6 artifacts, 30.3 KB, 945 lines
```

---

## Multi-Specialist Artifacts

### Handoff Directory Structure

```markdown
## Multi-Specialist Handoff Artifacts

**Handoff Directory**: `.agency/handoff/user-authentication/`

### Coordination Artifacts

- `execution-state.json` - Execution state tracking (2.1 KB)
  - 2 specialists tracked (backend-architect, frontend-developer)
  - Execution strategy: Sequential
  - Status: Completed

### Integration Artifacts

**Directory**: `integration/`

- `api-contract.md` - Shared API contract definitions (4.5 KB)
  - 3 endpoints documented
  - Request/response schemas
  - Authentication requirements
- `type-definitions.ts` - Shared TypeScript types (1.8 KB)
  - User type
  - AuthResponse type
  - LoginCredentials type

### Backend Architect Artifacts

**Directory**: `backend-architect/`

- `plan.md` - Backend-specific plan (5.2 KB)
  - 8 tasks assigned
  - 5 files to create
- `summary.md` - Backend completion summary (8.7 KB)
  - 5 files created
  - 2 files modified
  - API contracts documented
  - Test results included
- `verification.md` - Reality-checker verification (3.4 KB)
  - Status: ✅ PASSED
  - 0 critical issues
  - 2 medium issues (documented)
- `files-changed.json` - File tracking (0.5 KB)
  - 5 created
  - 2 modified
  - 0 deleted

### Frontend Developer Artifacts

**Directory**: `frontend-developer/`

- `plan.md` - Frontend-specific plan (4.8 KB)
  - 6 tasks assigned
  - 4 components to create
- `summary.md` - Frontend completion summary (7.3 KB)
  - 4 components created
  - 3 pages updated
  - Integration with backend verified
  - Test results included
- `verification.md` - Reality-checker verification (2.9 KB)
  - Status: ✅ PASSED
  - 0 critical issues
  - 1 low issue (acceptable)
- `files-changed.json` - File tracking (0.4 KB)
  - 4 created
  - 3 modified
  - 0 deleted

### Integration Review

- `integration-review.md` - Cross-specialist integration review (6.1 KB)
  - Status: ✅ PASS
  - API contracts verified
  - Type consistency checked
  - 0 integration issues

**Total Handoff Artifacts**: 14 files, 47.6 KB
```

---

## Report Artifacts by Phase

### Phase-by-Phase Listing

```markdown
## Implementation Artifacts by Phase

### Phase 1: Planning

- `.agency/plans/plan-user-authentication.md` - Feature plan (8.2 KB)
  - 12 requirements
  - 15 implementation steps
  - 5 success criteria

### Phase 2: Implementation

**Source Code**:
- 5 components created (src/components/)
- 3 API endpoints created (src/api/auth/)
- 2 utility modules created (src/lib/)

**Tests**:
- 8 test files created
- 35 total tests
- 82% coverage achieved

### Phase 3: Verification

**Build Artifacts**:
- `.next/` - Production build output
- `build-log.txt` - Build log (successful)

**Test Results**:
- `test-results.json` - Test results summary
- `coverage/` - Coverage reports

### Phase 4: Code Review

**Review Reports**:
- `.agency/reviews/review-user-auth-20241211-150033.md` - Code review (9.5 KB)
  - 0 critical issues
  - 1 high issue (fixed)
  - 3 medium issues (documented)

### Phase 5: Documentation

**Documentation**:
- `docs/api/authentication.md` - API docs (6.3 KB)
- `docs/architecture/auth-flow.md` - Architecture ADR (4.7 KB)
- `README.md` - Updated with auth setup instructions

### Phase 6: Summary

**Summary Report**:
- `.agency/implementations/impl-user-auth-20241211-143022.md` - Final summary (12.4 KB)
  - Complete implementation record
  - Metrics comparison
  - Verification results
  - Next steps
```

---

## Artifact Size Summary

### Size Calculation Template

```markdown
## Artifact Size Summary

### By Category

| Category | Files | Total Size | Average Size |
|----------|-------|------------|--------------|
| Source Code | 12 | 45.6 KB | 3.8 KB |
| Tests | 8 | 28.2 KB | 3.5 KB |
| Documentation | 4 | 18.5 KB | 4.6 KB |
| Configuration | 3 | 6.2 KB | 2.1 KB |
| Reports | 5 | 52.3 KB | 10.5 KB |
| **Total** | **32** | **150.8 KB** | **4.7 KB** |

### By Specialist

| Specialist | Files Created | Files Modified | Total Changes |
|------------|---------------|----------------|---------------|
| Backend Architect | 5 | 2 | 7 |
| Frontend Developer | 4 | 3 | 7 |
| **Total** | **9** | **5** | **14** |

### Code Statistics

| Metric | Value |
|--------|-------|
| Total Lines Added | +1,234 |
| Total Lines Removed | -56 |
| Net Change | +1,178 |
| Files Changed | 14 |
| Commits | 8 |
```

---

## Artifact Access Instructions

### How to Access Artifacts

```markdown
## Accessing Generated Artifacts

### Implementation Summary

**Location**: `.agency/implementations/impl-user-auth-20241211-143022.md`

**View**:
```bash
cat .agency/implementations/impl-user-auth-20241211-143022.md
# or
open .agency/implementations/impl-user-auth-20241211-143022.md
```

### Code Review Report

**Location**: `.agency/reviews/review-user-auth-20241211-150033.md`

**View**:
```bash
cat .agency/reviews/review-user-auth-20241211-150033.md
```

### Coverage Report

**Location**: `coverage/lcov-report/index.html`

**View in Browser**:
```bash
open coverage/lcov-report/index.html
```

### Handoff Artifacts

**Location**: `.agency/handoff/user-authentication/`

**View Structure**:
```bash
ls -R .agency/handoff/user-authentication/
```

**View Specific Summary**:
```bash
cat .agency/handoff/user-authentication/backend-architect/summary.md
```

### Build Output

**Location**: `.next/` or `build/`

**View Build Stats**:
```bash
ls -lh .next/static/
```
```

---

## Artifact Verification Checklist

```markdown
## Artifact Verification

### Required Artifacts Present

- [ ] Implementation summary created
- [ ] All source files created/modified as planned
- [ ] Tests created for new functionality
- [ ] Documentation updated
- [ ] Build artifacts generated successfully
- [ ] Coverage reports generated
- [ ] Code review report created
- [ ] Multi-specialist handoff artifacts (if applicable)

### Artifact Quality

- [ ] Summaries are complete (no [TBD] placeholders)
- [ ] File paths are accurate
- [ ] Descriptions are meaningful
- [ ] Metadata (size, lines) calculated
- [ ] Access instructions provided
- [ ] Verification results documented

### Organization

- [ ] Artifacts organized by category
- [ ] Naming follows conventions
- [ ] Timestamps included
- [ ] Paths are absolute or relative to project root
- [ ] Directory structure clear
```

---

## Quick Artifact Templates

### Minimal Artifact List

```markdown
## Artifacts

**Implementation**:
- `.agency/implementations/impl-[feature]-[timestamp].md` - Summary

**Files Changed**: [X] created, [Y] modified, [Z] deleted
- See implementation summary for detailed file list

**Reports**:
- Code review: `.agency/reviews/review-[feature]-[timestamp].md`
- Coverage: `coverage/lcov-report/index.html`
```

### Standard Artifact List

```markdown
## Generated Artifacts

### Source Code ([X] files)
[List of created/modified files with descriptions]

### Tests ([Y] files)
[List of test files with test counts]

### Documentation ([Z] files)
[List of docs with descriptions]

### Reports
- **Implementation Summary**: [path] ([size])
- **Code Review**: [path] ([size])
- **Coverage Report**: [path]

### Build Output
- **Build**: [path] ([size])
- **Status**: ✅ Success
```

### Comprehensive Artifact List

```markdown
## Complete Artifact Inventory

### Implementation Artifacts
[Categorized source files with metadata table]

### Report Artifacts
[All reports with paths, sizes, summaries]

### Build Artifacts
[Build outputs with sizes and verification]

### Multi-Specialist Artifacts
[Handoff directory structure and contents]

### Artifact Summary
[Size and count statistics]

### Access Instructions
[How to view each artifact type]

### Verification Checklist
[Checklist of required artifacts]
```

---

## Best Practices

### Naming Conventions

**Implementation Summaries**:
- Pattern: `impl-[feature-name]-[YYYYMMDD-HHMMSS].md`
- Example: `impl-user-authentication-20241211-143022.md`

**Code Reviews**:
- Pattern: `review-[feature-name]-[YYYYMMDD-HHMMSS].md`
- Example: `review-user-authentication-20241211-150033.md`

**Handoff Directories**:
- Pattern: `.agency/handoff/[feature-name]/`
- Example: `.agency/handoff/user-authentication/`

### Organization

1. **Group by Type**: Source, tests, docs, reports
2. **Use Directories**: Keep artifacts organized in `.agency/`
3. **Include Timestamps**: For historical tracking
4. **Provide Paths**: Always use absolute or project-relative paths
5. **Add Descriptions**: Every artifact should have purpose explained

### Metadata

**Always Include**:
- File path
- Brief description
- File size (for reports)
- Line count (for code)
- Purpose/context

**Optional but Helpful**:
- Creation timestamp
- Creator (specialist/agent)
- Related artifacts
- Dependencies

### Accessibility

1. **Clear Paths**: Use consistent path format
2. **Access Instructions**: Show how to view artifacts
3. **Link Related**: Connect related artifacts
4. **Organize Hierarchically**: Use sections and subsections
5. **Summary First**: High-level view before details

---

## Artifact Retention

### Keep Permanently

- Implementation summaries
- Code review reports
- Architecture decision records (ADRs)
- Critical incident reports

### Keep Temporarily

- Build artifacts (until next build)
- Test output (until next test run)
- Coverage reports (until next coverage run)
- Handoff artifacts (until feature deployed)

### Archive After Deployment

- Multi-specialist handoff directories
- Verification reports
- Execution state files

**Archival Command**:
```bash
# Archive handoff directory
tar -czf .agency/handoff/user-authentication/archive/handoff-$(date +%Y%m%d-%H%M%S).tar.gz \
  .agency/handoff/user-authentication/**/plan.md \
  .agency/handoff/user-authentication/**/summary.md \
  .agency/handoff/user-authentication/**/verification.md
```
