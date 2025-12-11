# Coverage Standards

## Coverage Metrics

### Types of Coverage

**Line Coverage**:
- Percentage of code lines executed
- Most common metric
- Can miss edge cases

**Branch Coverage**:
- Percentage of conditional branches executed
- Better than line coverage
- Catches if/else coverage

**Function Coverage**:
- Percentage of functions called
- Useful for API coverage
- Can miss function internals

**Statement Coverage**:
- Percentage of statements executed
- Similar to line coverage
- More granular

### Coverage Thresholds by Code Type

```json
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      },
      "./src/critical/**/*.ts": {
        "branches": 100,
        "functions": 100,
        "lines": 100,
        "statements": 100
      },
      "./src/utils/**/*.ts": {
        "branches": 90,
        "functions": 90,
        "lines": 90,
        "statements": 90
      },
      "./src/components/**/*.tsx": {
        "branches": 70,
        "functions": 70,
        "lines": 70,
        "statements": 70
      }
    }
  }
}
```

**By Component Type**:

| Component Type | Branches | Functions | Lines | Rationale |
|---------------|----------|-----------|-------|-----------|
| **Authentication** | 100% | 100% | 100% | Security critical |
| **Payment Processing** | 100% | 100% | 100% | Financial critical |
| **Data Validation** | 100% | 100% | 100% | Data integrity |
| **Business Logic** | 90% | 90% | 90% | Core functionality |
| **API Endpoints** | 90% | 90% | 90% | Contract testing |
| **Utilities** | 90% | 90% | 90% | Widely used |
| **UI Components** | 70% | 70% | 70% | Visual testing better |
| **Config/Setup** | 50% | 50% | 50% | Less critical |
| **Types/Interfaces** | N/A | N/A | N/A | No runtime code |

## Quality Over Quantity

### Bad Coverage Examples

**Example 1: Calling Without Asserting**:
```javascript
// ❌ 100% coverage but useless test
test('user service methods exist', () => {
  const service = new UserService();

  service.createUser({ email: 'test@example.com' }); // Called but not verified!
  service.getUser('123'); // Called but not verified!
  service.updateUser('123', { name: 'New Name' }); // Called but not verified!
  service.deleteUser('123'); // Called but not verified!

  expect(service).toBeDefined(); // Only assertion
});
```

**Example 2: Testing Trivial Code**:
```javascript
// ❌ Testing getters/setters
class User {
  constructor(name) {
    this.name = name;
  }

  getName() {
    return this.name;
  }

  setName(name) {
    this.name = name;
  }
}

test('getName returns name', () => {
  const user = new User('John');
  expect(user.getName()).toBe('John'); // Trivial
});

test('setName sets name', () => {
  const user = new User('John');
  user.setName('Jane');
  expect(user.getName()).toBe('Jane'); // Trivial
});
```

### Good Coverage Examples

**Example 1: Testing Behavior**:
```javascript
// ✅ Tests actual behavior with edge cases
describe('UserService.createUser', () => {
  it('should create user with hashed password', async () => {
    const user = await UserService.createUser({
      email: 'test@example.com',
      password: 'plaintext'
    });

    expect(user.password).not.toBe('plaintext');
    expect(user.password).toMatch(/^\$2[aby]\$/); // bcrypt
  });

  it('should send welcome email after creation', async () => {
    await UserService.createUser({ email: 'test@example.com' });

    expect(EmailService.send).toHaveBeenCalledWith({
      to: 'test@example.com',
      template: 'welcome'
    });
  });

  it('should throw error for duplicate email', async () => {
    await UserService.createUser({ email: 'test@example.com' });

    await expect(
      UserService.createUser({ email: 'test@example.com' })
    ).rejects.toThrow('Email already exists');
  });

  it('should validate email format', async () => {
    await expect(
      UserService.createUser({ email: 'invalid-email' })
    ).rejects.toThrow('Invalid email');
  });
});
```

**Example 2: Testing Edge Cases**:
```javascript
// ✅ Comprehensive edge case testing
describe('calculateDiscount', () => {
  describe('valid inputs', () => {
    it('should calculate percentage correctly', () => {
      expect(calculateDiscount(100, 10)).toBe(10);
      expect(calculateDiscount(50, 20)).toBe(10);
      expect(calculateDiscount(200, 50)).toBe(100);
    });

    it('should handle decimal percentages', () => {
      expect(calculateDiscount(100, 10.5)).toBe(10.5);
      expect(calculateDiscount(99.99, 15.75)).toBeCloseTo(15.75, 2);
    });
  });

  describe('boundary conditions', () => {
    it('should handle 0% discount', () => {
      expect(calculateDiscount(100, 0)).toBe(0);
    });

    it('should handle 100% discount', () => {
      expect(calculateDiscount(100, 100)).toBe(100);
    });

    it('should handle $0 price', () => {
      expect(calculateDiscount(0, 50)).toBe(0);
    });
  });

  describe('error cases', () => {
    it('should throw for negative discount', () => {
      expect(() => calculateDiscount(100, -10)).toThrow();
    });

    it('should throw for discount over 100', () => {
      expect(() => calculateDiscount(100, 150)).toThrow();
    });

    it('should throw for negative price', () => {
      expect(() => calculateDiscount(-100, 10)).toThrow();
    });

    it('should throw for non-numeric inputs', () => {
      expect(() => calculateDiscount('100', 10)).toThrow();
      expect(() => calculateDiscount(100, 'ten')).toThrow();
    });
  });
});
```

## Uncovered Code Analysis

### Finding Uncovered Code

**Generate Coverage Report**:
```bash
# Jest
npm test -- --coverage

# View HTML report
open coverage/lcov-report/index.html
```

**Analyze Uncovered Lines**:
```javascript
// Coverage report shows:
// Line 45: Not covered
// Line 67-72: Not covered

// Example uncovered code
function processPayment(amount, method) {
  if (amount <= 0) {
    throw new Error('Invalid amount'); // Line 45 - Not covered!
  }

  if (method === 'credit') {
    return processCreditCard(amount);
  } else if (method === 'paypal') {
    return processPayPal(amount);  // Lines 67-72 - Not covered!
  }

  throw new Error('Unknown payment method');
}
```

**Add Missing Tests**:
```javascript
// Add tests for uncovered lines
describe('processPayment', () => {
  it('should throw error for zero amount', () => {
    expect(() => processPayment(0, 'credit')).toThrow('Invalid amount');
  });

  it('should throw error for negative amount', () => {
    expect(() => processPayment(-10, 'credit')).toThrow('Invalid amount');
  });

  it('should process PayPal payment', async () => {
    const result = await processPayment(100, 'paypal');
    expect(result.method).toBe('paypal');
  });
});
```

### When Low Coverage is OK

**Acceptable Reasons**:
1. **Unreachable Code**: Dead code that should be removed
2. **Error Recovery**: Rare error paths that are hard to trigger
3. **Third-Party Code**: Dependencies you don't control
4. **Generated Code**: Auto-generated files
5. **Deprecated Code**: Code being phased out

**Document Exceptions**:
```javascript
// jest.config.js
module.exports = {
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/generated/',
    '/__tests__/fixtures/',
    '\\.config\\.js$'
  ],
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.tsx',
    '!src/deprecated/**'
  ]
};
```

## Coverage Gates in CI/CD

### GitHub Actions Example

```yaml
name: Test & Coverage
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run tests with coverage
        run: npm test -- --coverage

      - name: Check coverage threshold
        run: |
          COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage $COVERAGE% is below threshold 80%"
            exit 1
          fi

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
          flags: unittests
          fail_ci_if_error: true

      - name: Comment coverage on PR
        uses: romeovs/lcov-reporter-action@v0.3.1
        with:
          lcov-file: ./coverage/lcov.info
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Blocking PRs on Coverage Drop

```yaml
- name: Check coverage delta
  run: |
    BASE_COVERAGE=$(curl -s https://codecov.io/api/gh/${{ github.repository }}/branch/main | jq '.commit.totals.c')
    CURRENT_COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
    DELTA=$(echo "$CURRENT_COVERAGE - $BASE_COVERAGE" | bc)

    if (( $(echo "$DELTA < -2" | bc -l) )); then
      echo "Coverage dropped by ${DELTA}% (threshold: -2%)"
      exit 1
    fi
```

## Coverage Reporting

### HTML Report

```bash
npm test -- --coverage --coverageReporters=html

# View report
open coverage/index.html
```

**Report shows**:
- File-by-file coverage
- Highlighted uncovered lines
- Branch coverage visualization
- Drill-down to specific files

### Text Summary

```bash
npm test -- --coverage --coverageReporters=text-summary

# Output:
# =============================== Coverage summary ===============================
# Statements   : 85.23% ( 1245/1461 )
# Branches     : 78.45% ( 456/581 )
# Functions    : 82.15% ( 234/285 )
# Lines        : 85.67% ( 1198/1398 )
# ================================================================================
```

### JSON Report

```bash
npm test -- --coverage --coverageReporters=json

# Programmatic access
cat coverage/coverage-summary.json
```

### Badge Generation

```markdown
<!-- README.md -->
[![Coverage](https://codecov.io/gh/username/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/username/repo)

<!-- Or custom badge -->
![Coverage](https://img.shields.io/badge/coverage-85%25-brightgreen)
```

## Improving Coverage

### Strategy 1: Test Uncovered Critical Paths

**Priority Order**:
1. Authentication/Authorization
2. Payment processing
3. Data validation
4. Core business logic
5. Error handling

**Example**:
```javascript
// Find: Authentication has 60% coverage
// Action: Add tests for missing paths

describe('Authentication', () => {
  // Existing tests...

  // Add missing tests
  it('should handle expired tokens', async () => {
    const expiredToken = generateToken({ expiresIn: '-1h' });
    await expect(verifyToken(expiredToken)).rejects.toThrow('Token expired');
  });

  it('should handle malformed tokens', async () => {
    await expect(verifyToken('malformed')).rejects.toThrow('Invalid token');
  });

  it('should prevent token reuse after logout', async () => {
    const token = await login('user@example.com', 'password');
    await logout(token);
    await expect(verifyToken(token)).rejects.toThrow('Token invalidated');
  });
});
```

### Strategy 2: Identify Patterns in Uncovered Code

**Look for**:
- Error handling not tested
- Edge cases missed
- Conditional branches not covered

**Example**:
```javascript
// Uncovered: else branch in validation
function validateAge(age) {
  if (age >= 18) {
    return true;
  } else {
    throw new Error('Must be 18 or older'); // Not covered!
  }
}

// Add test
it('should reject age under 18', () => {
  expect(() => validateAge(17)).toThrow('Must be 18 or older');
  expect(() => validateAge(0)).toThrow('Must be 18 or older');
});
```

### Strategy 3: Remove Dead Code

```javascript
// ❌ Dead code lowering coverage
function processOrder(order) {
  if (order.status === 'pending') {
    return processPendingOrder(order);
  } else if (order.status === 'shipped') {
    return trackShipment(order);
  } else if (order.status === 'legacy') {
    // This never happens anymore - remove it!
    return processLegacyOrder(order);
  }
}

// ✅ Remove dead code
function processOrder(order) {
  if (order.status === 'pending') {
    return processPendingOrder(order);
  } else if (order.status === 'shipped') {
    return trackShipment(order);
  }
  throw new Error(`Unknown status: ${order.status}`);
}
```

## Coverage Anti-Patterns

### Anti-Pattern 1: Testing for 100%

```javascript
// ❌ Bad: Testing just to hit 100%
test('toString returns string', () => {
  const user = new User('John');
  expect(typeof user.toString()).toBe('string'); // Meaningless
});

// ✅ Good: Test meaningful behavior
test('toString returns formatted user info', () => {
  const user = new User('John', 'john@example.com');
  expect(user.toString()).toBe('John <john@example.com>');
});
```

### Anti-Pattern 2: Coverage as Only Metric

```javascript
// ❌ 100% coverage but no real testing
test('complex function runs', () => {
  const result = complexBusinessLogic(data);
  expect(result).toBeDefined(); // Covers lines but tests nothing!
});

// ✅ Test actual behavior
test('applies discount when user is premium', () => {
  const user = { isPremium: true };
  const price = 100;

  const result = calculatePrice(user, price);

  expect(result).toBe(90); // 10% premium discount
});
```

### Anti-Pattern 3: Snapshot Testing Everything

```javascript
// ❌ Lazy snapshot testing
test('component renders', () => {
  const { container } = render(<ComplexComponent />);
  expect(container).toMatchSnapshot(); // Covers everything, tests nothing
});

// ✅ Test specific behavior
test('shows error message when submission fails', async () => {
  render(<ComplexComponent />);

  fireEvent.click(screen.getByText('Submit'));

  await waitFor(() => {
    expect(screen.getByText('Submission failed')).toBeInTheDocument();
  });
});
```

## Best Practices

1. **Focus on Critical Code First** - 100% coverage on auth, payments, validation
2. **Quality Over Quantity** - Meaningful tests > high coverage
3. **Track Trends** - Coverage should improve over time
4. **Review Uncovered Code** - Understand why code isn't covered
5. **Don't Game the System** - Write tests that catch real bugs
6. **Use Multiple Metrics** - Branch coverage + line coverage
7. **Document Exceptions** - Explain why some code isn't covered
8. **Integrate in CI/CD** - Enforce coverage in pipeline
9. **Review Coverage Reports** - Regular coverage audits
10. **Test Behavior, Not Implementation** - Focus on what, not how

## Tools & Resources

### Coverage Tools

**Jest**:
```bash
npm test -- --coverage
```

**Vitest**:
```bash
vitest --coverage
```

**Istanbul/NYC** (for any test runner):
```bash
nyc npm test
```

### Coverage Services

- **Codecov**: https://codecov.io
- **Coveralls**: https://coveralls.io
- **SonarQube**: https://www.sonarqube.org

### Configuration Examples

**Jest Coverage Config**:
```json
{
  "jest": {
    "collectCoverage": true,
    "coverageDirectory": "coverage",
    "coverageReporters": ["text", "lcov", "html"],
    "collectCoverageFrom": [
      "src/**/*.{js,jsx,ts,tsx}",
      "!src/**/*.test.{js,jsx,ts,tsx}",
      "!src/**/*.stories.{js,jsx,ts,tsx}"
    ],
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

## References

- [Jest Coverage Documentation](https://jestjs.io/docs/configuration#collectcoverage-boolean)
- [Istanbul Documentation](https://istanbul.js.org/)
- [Martin Fowler: Test Coverage](https://martinfowler.com/bliki/TestCoverage.html)
