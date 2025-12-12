# Project Context: Testing Framework Detection

Detect the test framework(s) used in the project to run tests correctly, generate appropriate test code, and validate test coverage.

## Detection Strategy

Check for test frameworks in order of likelihood:

### 1. Jest (JavaScript/TypeScript)

**Primary Indicators**:
```bash
# Check package.json
grep '"jest"' package.json
```

**Secondary Indicators**:
- `jest.config.js`, `jest.config.ts`, or `jest.config.mjs`
- `setupTests.js` or `setupTests.ts`
- `package.json` has `"jest"` key
- Test files: `*.test.js`, `*.test.ts`, `*.spec.js`, `*.spec.ts`
- `__tests__/` directories

**Run Command**:
```bash
npm test
# Or
npm run test
npx jest
```

**Coverage Command**:
```bash
npm test -- --coverage
# Or
npx jest --coverage
```

**Framework**: `Jest`
**Type**: Unit, Integration, Snapshot
**Language**: JavaScript, TypeScript

---

### 2. Vitest (Vite-based)

**Primary Indicators**:
```bash
# Check package.json
grep '"vitest"' package.json
```

**Secondary Indicators**:
- `vitest.config.ts` or `vitest.config.js`
- `vite.config.ts` with test configuration
- Test files: `*.test.ts`, `*.spec.ts`
- Often paired with Vite projects

**Run Command**:
```bash
npm test
# Or
npm run test
npx vitest
```

**Coverage Command**:
```bash
npm test -- --coverage
# Or
npx vitest --coverage
```

**Framework**: `Vitest`
**Type**: Unit, Integration
**Language**: JavaScript, TypeScript
**Note**: Fast alternative to Jest for Vite projects

---

### 3. Playwright (E2E Testing)

**Primary Indicators**:
```bash
# Check package.json
grep '"@playwright/test"' package.json
```

**Secondary Indicators**:
- `playwright.config.ts` or `playwright.config.js`
- `tests/` or `e2e/` directory with `.spec.ts` files
- `test-results/` directory
- `playwright-report/` directory

**Run Command**:
```bash
npx playwright test
# Or
npm run test:e2e
```

**UI Mode**:
```bash
npx playwright test --ui
```

**Headed Mode** (see browser):
```bash
npx playwright test --headed
```

**Framework**: `Playwright`
**Type**: E2E, Integration, Visual
**Language**: JavaScript, TypeScript
**Browsers**: Chromium, Firefox, WebKit

---

### 4. Cypress (E2E Testing)

**Primary Indicators**:
```bash
# Check package.json
grep '"cypress"' package.json
```

**Secondary Indicators**:
- `cypress.config.js` or `cypress.config.ts`
- `cypress/` directory with `e2e/`, `fixtures/`, `support/`
- Test files in `cypress/e2e/*.cy.js` or `cypress/integration/`

**Run Command**:
```bash
npx cypress run
# Or
npm run test:e2e
```

**Interactive Mode**:
```bash
npx cypress open
```

**Framework**: `Cypress`
**Type**: E2E, Integration
**Language**: JavaScript, TypeScript
**Browsers**: Chrome, Firefox, Edge, Electron

---

### 5. pytest (Python)

**Primary Indicators**:
```bash
# Check requirements or pyproject.toml
grep -i "pytest" requirements.txt || grep -i "pytest" pyproject.toml
```

**Secondary Indicators**:
- `pytest.ini` or `pyproject.toml` with `[tool.pytest.ini_options]`
- `conftest.py` files
- Test files: `test_*.py` or `*_test.py`
- `tests/` directory

**Run Command**:
```bash
pytest
# Or
python -m pytest
```

**Coverage Command**:
```bash
pytest --cov=src --cov-report=html
# Or
pytest --cov=. --cov-report=term-missing
```

**Framework**: `pytest`
**Type**: Unit, Integration, Functional
**Language**: Python

---

### 6. PHPUnit (PHP)

**Primary Indicators**:
```bash
# Check composer.json
grep '"phpunit/phpunit"' composer.json
```

**Secondary Indicators**:
- `phpunit.xml` or `phpunit.xml.dist`
- Test files in `tests/` directory with `*Test.php`
- Extends `PHPUnit\Framework\TestCase`

**Run Command**:
```bash
./vendor/bin/phpunit
# Or
php artisan test (Laravel)
```

**Coverage Command**:
```bash
./vendor/bin/phpunit --coverage-html coverage
```

**Framework**: `PHPUnit`
**Type**: Unit, Integration
**Language**: PHP

---

### 7. RSpec (Ruby)

**Primary Indicators**:
```bash
# Check Gemfile
grep "gem 'rspec'" Gemfile
```

**Secondary Indicators**:
- `.rspec` configuration file
- `spec/` directory
- Test files: `*_spec.rb`
- `spec/spec_helper.rb`

**Run Command**:
```bash
bundle exec rspec
# Or
rspec
```

**Framework**: `RSpec`
**Type**: Unit, Integration, Feature
**Language**: Ruby

---

### 8. Mocha (JavaScript)

**Primary Indicators**:
```bash
# Check package.json
grep '"mocha"' package.json
```

**Secondary Indicators**:
- `.mocharc.js` or `.mocharc.json`
- Test files in `test/` directory
- Often paired with Chai for assertions

**Run Command**:
```bash
npm test
# Or
npx mocha
```

**Framework**: `Mocha`
**Type**: Unit, Integration
**Language**: JavaScript, TypeScript
**Note**: Requires separate assertion library (Chai, Should.js)

---

### 9. Testing Library (React/Vue/Svelte)

**Primary Indicators**:
```bash
# Check package.json
grep '"@testing-library/react"' package.json
grep '"@testing-library/vue"' package.json
grep '"@testing-library/svelte"' package.json
```

**Secondary Indicators**:
- Used with Jest or Vitest
- Test files use `render`, `screen`, `fireEvent`
- Component testing focus

**Framework**: `Testing Library` (with Jest/Vitest)
**Type**: Component, Integration
**Language**: JavaScript, TypeScript
**Note**: Not standalone - used with Jest/Vitest

---

### 10. unittest (Python - Built-in)

**Primary Indicators**:
```bash
# No dependencies needed - built into Python
# Check for test files
find . -name "test_*.py" -o -name "*_test.py"
```

**Secondary Indicators**:
- Tests extend `unittest.TestCase`
- No pytest in dependencies
- `if __name__ == '__main__': unittest.main()`

**Run Command**:
```bash
python -m unittest discover
# Or
python -m unittest tests/test_module.py
```

**Framework**: `unittest`
**Type**: Unit, Integration
**Language**: Python (built-in)

---

## Detection Algorithm

```bash
# Check for test frameworks in order of priority:

# JavaScript/TypeScript - Unit/Integration
if grep -q '"vitest"' package.json 2>/dev/null; then
  UNIT_TEST="Vitest"
elif grep -q '"jest"' package.json 2>/dev/null; then
  UNIT_TEST="Jest"
elif grep -q '"mocha"' package.json 2>/dev/null; then
  UNIT_TEST="Mocha"
fi

# JavaScript/TypeScript - E2E
if grep -q '"@playwright/test"' package.json 2>/dev/null; then
  E2E_TEST="Playwright"
elif grep -q '"cypress"' package.json 2>/dev/null; then
  E2E_TEST="Cypress"
fi

# Python
if grep -qi "pytest" requirements.txt 2>/dev/null || grep -qi "pytest" pyproject.toml 2>/dev/null; then
  UNIT_TEST="pytest"
elif find . -name "test_*.py" | grep -q .; then
  UNIT_TEST="unittest"
fi

# PHP
if grep -q '"phpunit/phpunit"' composer.json 2>/dev/null; then
  UNIT_TEST="PHPUnit"
fi

# Ruby
if grep -q "gem 'rspec'" Gemfile 2>/dev/null; then
  UNIT_TEST="RSpec"
fi

# Component Testing Library
if grep -q '"@testing-library/' package.json 2>/dev/null; then
  COMPONENT_TEST="Testing Library"
fi
```

---

## Multiple Test Frameworks

Many projects use multiple frameworks for different test types:

### Common Combinations

**Next.js / React**:
- Unit: Jest or Vitest
- Component: Testing Library
- E2E: Playwright or Cypress

**Django**:
- Unit: pytest
- E2E: Playwright or Selenium

**Laravel**:
- Unit: PHPUnit
- Browser: Laravel Dusk or Playwright

### Execution Strategy

When multiple frameworks detected:

1. **Run unit tests first** (fastest feedback)
2. **Run integration tests** (medium speed)
3. **Run E2E tests last** (slowest)

```bash
# Example: Next.js with Jest + Playwright
npm run test              # Jest unit/component tests
npm run test:e2e          # Playwright E2E tests
```

---

## Test File Patterns

### Jest/Vitest
- `*.test.js`, `*.test.ts`
- `*.spec.js`, `*.spec.ts`
- `__tests__/**/*.js`

### Playwright
- `*.spec.ts` in `tests/` or `e2e/`
- `playwright.config.ts` defines test directory

### Cypress
- `*.cy.js`, `*.cy.ts` in `cypress/e2e/`
- `cypress.config.js` defines patterns

### pytest
- `test_*.py` in `tests/` or any directory
- `*_test.py`
- `conftest.py` for fixtures

### PHPUnit
- `*Test.php` in `tests/`
- Extends `TestCase`

### RSpec
- `*_spec.rb` in `spec/`
- Organized by type: `spec/models/`, `spec/controllers/`

---

## Test Commands by Framework

### Jest
```bash
# Run all tests
npm test

# Watch mode
npm test -- --watch

# Coverage
npm test -- --coverage

# Single file
npm test -- path/to/test.test.js
```

### Vitest
```bash
# Run all tests
npm test

# Watch mode (default)
npm run test

# Coverage
npm test -- --coverage

# UI mode
npm test -- --ui
```

### Playwright
```bash
# All tests
npx playwright test

# Specific file
npx playwright test tests/example.spec.ts

# Headed mode
npx playwright test --headed

# Debug mode
npx playwright test --debug

# UI mode
npx playwright test --ui
```

### Cypress
```bash
# Headless
npx cypress run

# Interactive
npx cypress open

# Specific spec
npx cypress run --spec "cypress/e2e/login.cy.js"
```

### pytest
```bash
# All tests
pytest

# Specific file
pytest tests/test_auth.py

# Coverage
pytest --cov=src --cov-report=html

# Verbose
pytest -v

# Stop on first failure
pytest -x
```

### PHPUnit
```bash
# All tests
./vendor/bin/phpunit

# Specific test
./vendor/bin/phpunit tests/Unit/ExampleTest.php

# Coverage
./vendor/bin/phpunit --coverage-html coverage
```

---

## Coverage Thresholds

### Standard Targets
- **Excellent**: 80%+ coverage
- **Good**: 70-80% coverage
- **Acceptable**: 60-70% coverage
- **Needs Improvement**: < 60% coverage

### Coverage Commands

**Jest**:
```bash
npm test -- --coverage --coverageThreshold='{"global":{"branches":80,"functions":80,"lines":80,"statements":80}}'
```

**Vitest**:
```bash
npm test -- --coverage --coverage.lines=80 --coverage.functions=80
```

**pytest**:
```bash
pytest --cov=src --cov-report=term-missing --cov-fail-under=80
```

**PHPUnit**:
```json
// phpunit.xml
<coverage>
  <report>
    <html outputDirectory="coverage"/>
  </report>
</coverage>
```

---

## Fallback Strategy

### When No Test Framework Detected

1. **Check package.json scripts**:
   ```bash
   jq -r '.scripts.test' package.json
   ```

2. **Search for test files**:
   ```bash
   find . -name "*.test.*" -o -name "*.spec.*" -o -name "test_*"
   ```

3. **Ask user**:
   ```
   ⚠️ No test framework detected.

   Please specify:
   - Test framework to use (Jest, Vitest, pytest, etc.)
   - Or confirm: "No tests exist yet"
   ```

4. **Suggest framework** based on project type:
   - Next.js/React → Jest or Vitest
   - Django/FastAPI → pytest
   - Laravel → PHPUnit
   - Rails → RSpec

---

## Usage Examples

### Example 1: Jest + Playwright
```bash
$ grep '"jest"' package.json
"jest": "^29.7.0"
$ grep '"@playwright/test"' package.json
"@playwright/test": "^1.40.0"

✅ Testing Frameworks Detected:
1. Jest - Unit & Component Testing
   - Run: npm test
   - Coverage: npm test -- --coverage
   - Files: *.test.ts in src/

2. Playwright - E2E Testing
   - Run: npx playwright test
   - UI Mode: npx playwright test --ui
   - Files: *.spec.ts in tests/

📋 Test Execution Order:
1. Run Jest (fast unit tests)
2. Run Playwright (slower E2E tests)
```

### Example 2: pytest Only
```bash
$ grep -i "pytest" requirements.txt
pytest==7.4.3
pytest-cov==4.1.0

✅ Testing Framework Detected:
- pytest - Unit & Integration Testing
  - Run: pytest
  - Coverage: pytest --cov=src --cov-report=html
  - Files: test_*.py in tests/
  - Config: pyproject.toml
```

### Example 3: No Tests
```bash
$ grep '"jest"' package.json
(no output)
$ find . -name "*.test.*"
(no output)

⚠️ No test framework detected.

📋 Recommendations:
- For Next.js/React: Install Jest or Vitest
- Add test files: *.test.ts, *.spec.ts
- Create test directory: tests/ or __tests__/

Would you like me to:
1. Set up testing framework
2. Proceed without tests (not recommended)
```

---

## Validation

After detection, verify by:

1. **Test Command**: Run test command to ensure it works
2. **Test Files**: Confirm test files exist and are discoverable
3. **Coverage**: Verify coverage command produces reports

**Report Format**:
```markdown
## Testing Framework Detection

**Unit/Integration**: [Framework]
- Command: [command]
- Coverage: [command]
- Files: [pattern]

**E2E** (if applicable): [Framework]
- Command: [command]
- UI Mode: [command]
- Files: [pattern]

**Component** (if applicable): [Framework]
- Used with: [Jest/Vitest]
- Files: [pattern]

**Verified**:
- ✅ Test command works
- ✅ Test files found: [count] files
- ✅ Coverage generation working
```

---

## Commands Using This Component

- `/agency:test` - Primary user - run appropriate tests
- `/agency:implement` - Generate tests with correct framework
- `/agency:work` - Run tests during development
- `/agency:refactor` - Verify refactoring with tests
- `/agency:review` - Check test coverage
- `/agency:sprint` - Run tests for multiple issues
- `/agency:optimize` - Verify optimizations don't break tests
