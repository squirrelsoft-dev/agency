# Project Context: Project Size Detection

Categorize project size (small/medium/large) to adapt command execution strategies, resource allocation, and complexity handling.

## Size Categories

### Small Project
**Characteristics**:
- **File count**: < 50 source files
- **Lines of code**: < 5,000 LOC
- **Dependencies**: < 20 packages
- **Team size**: 1-2 developers
- **Complexity**: Single feature or simple app

**Examples**:
- CLI tool
- Simple website
- Small utility library
- Prototype
- Learning project

**Command Adaptations**:
- Faster execution (less to scan)
- Simpler quality gates
- Single-specialist workflows
- Basic testing sufficient

---

### Medium Project
**Characteristics**:
- **File count**: 50-500 source files
- **Lines of code**: 5,000-50,000 LOC
- **Dependencies**: 20-100 packages
- **Team size**: 3-10 developers
- **Complexity**: Multiple features, organized modules

**Examples**:
- SaaS application
- E-commerce site
- Internal tool
- Mobile app
- Standard web application

**Command Adaptations**:
- Moderate execution time
- Full quality gate sequence
- May need multi-specialist workflows
- Comprehensive testing required
- Code organization matters

---

### Large Project
**Characteristics**:
- **File count**: > 500 source files
- **Lines of code**: > 50,000 LOC
- **Dependencies**: > 100 packages
- **Team size**: > 10 developers
- **Complexity**: Multiple modules, microservices, complex architecture

**Examples**:
- Enterprise application
- Monorepo with multiple apps
- Platform with many services
- Complex SaaS with multiple modules
- Large-scale open source project

**Command Adaptations**:
- Longer execution time (warn user)
- Scope limiting critical
- Multi-specialist workflows common
- Extensive testing required
- Performance considerations
- May need batching/parallelization

---

## Detection Metrics

### 1. Source File Count

**Count Strategy**:
```bash
# JavaScript/TypeScript projects
find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.jsx" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.next/*" \
  ! -path "*/dist/*" \
  ! -path "*/build/*" \
  | wc -l

# Python projects
find . -type f -name "*.py" \
  ! -path "*/venv/*" \
  ! -path "*/__pycache__/*" \
  ! -path "*/site-packages/*" \
  | wc -l

# PHP projects
find . -type f -name "*.php" \
  ! -path "*/vendor/*" \
  | wc -l

# Ruby projects
find . -type f -name "*.rb" \
  ! -path "*/vendor/*" \
  | wc -l
```

**Thresholds**:
- **Small**: < 50 files
- **Medium**: 50-500 files
- **Large**: > 500 files

---

### 2. Lines of Code (LOC)

**Count Strategy**:
```bash
# Using cloc (if available)
cloc . --exclude-dir=node_modules,dist,build,.next,venv,vendor

# Using find + wc (rough estimate)
find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.php" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/dist/*" \
  ! -path "*/vendor/*" \
  -exec wc -l {} + | tail -1
```

**Thresholds**:
- **Small**: < 5,000 LOC
- **Medium**: 5,000-50,000 LOC
- **Large**: > 50,000 LOC

---

### 3. Dependency Count

**Count Strategy**:

**JavaScript/TypeScript**:
```bash
# Count dependencies in package.json
jq -r '(.dependencies // {}) + (.devDependencies // {}) | length' package.json
```

**Python**:
```bash
# Count lines in requirements.txt
wc -l < requirements.txt

# Or count from pyproject.toml
grep -c "^[a-zA-Z]" pyproject.toml
```

**PHP**:
```bash
# Count dependencies in composer.json
jq -r '(.require // {}) + (.["require-dev"] // {}) | length' composer.json
```

**Ruby**:
```bash
# Count gems in Gemfile
grep -c "^[[:space:]]*gem" Gemfile
```

**Thresholds**:
- **Small**: < 20 dependencies
- **Medium**: 20-100 dependencies
- **Large**: > 100 dependencies

---

### 4. Directory Depth & Structure

**Complexity Indicators**:
```bash
# Count subdirectories (deeper = more complex)
find . -type d ! -path "*/node_modules/*" ! -path "*/.*" | wc -l

# Check for monorepo indicators
test -d packages || test -d apps

# Check for microservices
test -d services && ls services/ | wc -l
```

**Structure Complexity**:
- **Simple**: Flat structure, few directories
- **Moderate**: Organized modules, clear separation
- **Complex**: Deep nesting, monorepo, microservices

---

### 5. Git History

**Activity Indicators**:
```bash
# Count commits
git rev-list --count HEAD

# Count contributors
git log --format='%ae' | sort -u | wc -l

# Check age of repository
git log --reverse --format='%ai' | head -1
```

**Maturity**:
- **New**: < 100 commits, < 3 months old
- **Established**: 100-1000 commits, 3-12 months
- **Mature**: > 1000 commits, > 1 year

---

## Detection Algorithm

```bash
#!/bin/bash

# Count source files (language-agnostic)
FILE_COUNT=$(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" -o -name "*.php" -o -name "*.rb" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.next/*" \
  ! -path "*/dist/*" \
  ! -path "*/build/*" \
  ! -path "*/vendor/*" \
  ! -path "*/venv/*" \
  | wc -l)

# Count dependencies (check package.json first)
if test -f package.json; then
  DEP_COUNT=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | length' package.json 2>/dev/null || echo 0)
elif test -f composer.json; then
  DEP_COUNT=$(jq -r '(.require // {}) + (.["require-dev"] // {}) | length' composer.json 2>/dev/null || echo 0)
elif test -f requirements.txt; then
  DEP_COUNT=$(wc -l < requirements.txt 2>/dev/null || echo 0)
else
  DEP_COUNT=0
fi

# Estimate LOC (rough)
LOC=$(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" -o -name "*.php" -o -name "*.rb" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/dist/*" \
  ! -path "*/vendor/*" \
  ! -path "*/venv/*" \
  -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')

# Determine size based on multiple metrics
if [ "$FILE_COUNT" -lt 50 ] && [ "$DEP_COUNT" -lt 20 ] && [ "$LOC" -lt 5000 ]; then
  PROJECT_SIZE="Small"
elif [ "$FILE_COUNT" -gt 500 ] || [ "$DEP_COUNT" -gt 100 ] || [ "$LOC" -gt 50000 ]; then
  PROJECT_SIZE="Large"
else
  PROJECT_SIZE="Medium"
fi

echo "$PROJECT_SIZE"
```

---

## Size-Based Adaptations

### Command Execution Strategy

**Small Projects**:
- **Speed**: Fast execution, minimal overhead
- **Scope**: Work on entire codebase at once
- **Testing**: Quick test runs
- **Specialists**: Usually single specialist sufficient
- **Quality Gates**: May skip some gates for speed

**Medium Projects**:
- **Speed**: Standard execution time
- **Scope**: Work on specific modules/features
- **Testing**: Full test suite, may take minutes
- **Specialists**: May need multiple specialists
- **Quality Gates**: Full sequence recommended

**Large Projects**:
- **Speed**: Warn user about execution time
- **Scope**: MUST limit scope to specific areas
- **Testing**: May need to run subset of tests
- **Specialists**: Multi-specialist workflows common
- **Quality Gates**: All gates critical, may run in parallel
- **Performance**: Consider batching, caching

---

### Timeout Adjustments

**Small Projects**:
- Build timeout: 2 minutes
- Test timeout: 5 minutes
- Total workflow: 10 minutes

**Medium Projects**:
- Build timeout: 5 minutes
- Test timeout: 15 minutes
- Total workflow: 30 minutes

**Large Projects**:
- Build timeout: 10 minutes
- Test timeout: 30 minutes
- Total workflow: 60 minutes
- **Warn user** about long execution

---

### Scope Limiting Strategies

**Small Projects**:
- Scope limiting optional
- Can work on entire codebase

**Medium Projects**:
- Scope limiting recommended
- Focus on specific modules/features
- Example: "Work on authentication module"

**Large Projects**:
- Scope limiting **REQUIRED**
- Must specify:
  - Specific module/package
  - Feature area
  - Service (if microservices)
- Example: "Work on user-service authentication only"

---

## Monorepo Detection

### Indicators
```bash
# Check for monorepo structure
test -d packages || test -d apps || test -f pnpm-workspace.yaml || test -f lerna.json

# Count packages
if test -d packages; then
  ls packages/ | wc -l
fi
```

### Monorepo Size
```bash
# Count total files across all packages
find packages/ -type f \( -name "*.js" -o -name "*.ts" \) | wc -l

# Count packages
PACKAGE_COUNT=$(ls packages/ | wc -l)
```

**Monorepo Considerations**:
- Even if individual packages are small, monorepo is **Large**
- Must scope to specific package(s)
- May need different specialists per package
- Test/build strategies per package

---

## Usage Examples

### Example 1: Small Project (CLI Tool)
```bash
$ find . -name "*.ts" ! -path "*/node_modules/*" | wc -l
23

$ jq -r '(.dependencies // {}) + (.devDependencies // {}) | length' package.json
12

$ find . -name "*.ts" -exec wc -l {} + | tail -1
1,847 total

✅ Project Size: Small
- Files: 23 TypeScript files
- Dependencies: 12 packages
- LOC: ~1,847 lines

📋 Adaptations:
- Fast execution expected (< 5 minutes)
- Full codebase scans acceptable
- Single specialist sufficient
- Quick test runs
```

### Example 2: Medium Project (SaaS App)
```bash
$ find . -name "*.tsx" -o -name "*.ts" ! -path "*/node_modules/*" | wc -l
187

$ jq -r '(.dependencies // {}) + (.devDependencies // {}) | length' package.json
64

$ cloc . --exclude-dir=node_modules,dist,.next
TypeScript: 18,234 LOC

✅ Project Size: Medium
- Files: 187 TypeScript files
- Dependencies: 64 packages
- LOC: ~18,234 lines

📋 Adaptations:
- Standard execution time (10-20 minutes)
- Scope to specific features recommended
- May need multiple specialists
- Full quality gates recommended
```

### Example 3: Large Project (Enterprise Monorepo)
```bash
$ ls packages/ | wc -l
24

$ find packages/ -name "*.ts" -o -name "*.tsx" | wc -l
1,342

$ jq -r '(.dependencies // {}) + (.devDependencies // {}) | length' package.json
156

✅ Project Size: Large (Monorepo)
- Packages: 24 packages
- Files: 1,342 TypeScript files
- Dependencies: 156 packages
- LOC: ~73,000 lines (estimated)

⚠️ Large Project Detected

📋 Adaptations:
- ⏱️ Execution may take 30-60 minutes
- 🎯 SCOPE LIMITING REQUIRED
  - Specify package: "work on @myapp/auth package"
  - Or feature area: "update authentication in user-service"
- 👥 Multi-specialist workflows likely
- 🧪 May run subset of tests (full suite = 45 min)
- ⚡ Consider parallel quality gates

Please specify scope for this work.
```

---

## Validation

After detection, verify and report:

**Report Format**:
```markdown
## Project Size Detection

**Size**: [Small/Medium/Large]

**Metrics**:
- Source files: [count] files
- Dependencies: [count] packages
- Lines of code: ~[count] LOC
- Directories: [count]
- Git commits: [count] commits
- Contributors: [count] developers

**Structure**:
- Type: [Monorepo/Single package/Microservices]
- Packages: [count] (if monorepo)
- Services: [count] (if microservices)

**Maturity**: [New/Established/Mature]

**Adaptations**:
- Expected execution time: [estimate]
- Scope limiting: [Required/Recommended/Optional]
- Specialists: [Single/Multiple likely]
- Quality gates: [Full/Standard/Fast]

[Large projects only]
⚠️ **Large Project Notice**:
This is a large project. Please specify scope to ensure efficient execution.
```

---

## Commands Using This Component

- `/agency:implement` - Adjust implementation strategy
- `/agency:work` - Determine scope requirements
- `/agency:refactor` - Plan refactoring scope
- `/agency:test` - Adjust test execution strategy
- `/agency:optimize` - Target optimization efforts
- `/agency:sprint` - Estimate sprint capacity
- `/agency:review` - Scope review depth
- `/agency:deploy` - Adjust deployment strategy
