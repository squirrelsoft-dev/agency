# Test Review Deep Dive

Comprehensive guide to reviewing test quality, coverage, and effectiveness during code review. This document covers test patterns, anti-patterns, coverage metrics, and strategies for ensuring tests actually validate behavior.

## Test Quality Principles

### Tests Should Verify Behavior, Not Implementation

The most common mistake in testing is coupling tests to implementation details. Good tests survive refactoring.

**Bad Test** (Implementation-coupled):
```typescript
test('UserStore maintains internal array', () => {
  const store = new UserStore();
  expect(store._users).toEqual([]); // Testing private implementation
  store.add({ id: 1, name: 'John' });
  expect(store._users.length).toBe(1); // Testing internal structure
});
```

**Good Test** (Behavior-focused):
```typescript
test('UserStore returns added user by ID', () => {
  const store = new UserStore();
  const user = { id: 1, name: 'John' };

  store.add(user);

  expect(store.getById(1)).toEqual(user);
});
```

**Why This Matters**:
- Implementation-coupled tests break when refactoring (even if behavior unchanged)
- Behavior tests serve as documentation of what the code does
- Behavior tests allow safe refactoring with confidence

**Code Review Questions**:
- Does this test access private methods or properties?
- Would this test break if we changed the internal implementation?
- Does this test describe what the code does from a user's perspective?

---

## AAA Pattern (Arrange-Act-Assert)

Every test should follow this three-phase structure for clarity.

### Arrange
Set up the test conditions and inputs.

```typescript
// Arrange phase
const user = createTestUser({ balance: 100 });
const product = createTestProduct({ price: 30 });
const cart = new ShoppingCart(user);
```

### Act
Execute the behavior being tested.

```typescript
// Act phase
const result = cart.addItem(product);
```

### Assert
Verify the expected outcome.

```typescript
// Assert phase
expect(result.success).toBe(true);
expect(user.balance).toBe(70);
expect(cart.total).toBe(30);
```

**Code Review Questions**:
- Are the three phases clearly separated?
- Is there only ONE action being tested (one Act phase)?
- Are assertions focused on the outcome of that action?

---

## Test Coverage Metrics

### Coverage Types

**Line Coverage**: Percentage of code lines executed by tests.
- **Target**: 80%+ overall, but meaningless without quality

**Branch Coverage**: Percentage of decision branches executed.
- **Target**: 75%+ for critical paths
- **Better than line coverage** - ensures all if/else paths tested

**Function Coverage**: Percentage of functions called by tests.
- **Target**: 90%+ for public APIs
- **Gap indicator**: Untested functions are risky

**Statement Coverage**: Similar to line coverage but more granular.
- **Target**: Aligns with line coverage targets

### Coverage Thresholds by Code Type

**Critical Paths** (100% required):
- Authentication and authorization
- Payment processing
- Data integrity operations
- Security-sensitive code
- Regulatory compliance features

**Business Logic** (90%+ required):
- Core domain logic
- Calculation functions
- Validation rules
- State machines
- Workflows

**UI Components** (70-80% acceptable):
- React/Vue components
- Visual elements
- User interactions
- Higher threshold for critical forms

**Infrastructure/Utilities** (85%+ required):
- Shared utilities
- Helper functions
- Data transformations
- API clients

**Glue Code** (60-70% acceptable):
- Configuration
- Middleware setup
- Route definitions
- May be tested via integration tests

### Coverage Is Necessary But Not Sufficient

**100% coverage doesn't guarantee quality**. You can have 100% coverage with terrible tests.

**Bad Example** (100% coverage, zero value):
```typescript
test('add function', () => {
  add(2, 3); // Executes the function
  expect(true).toBe(true); // Meaningless assertion
});
```

**Good Example** (100% coverage, high value):
```typescript
test('add returns sum of positive numbers', () => {
  expect(add(2, 3)).toBe(5);
});

test('add returns sum of negative numbers', () => {
  expect(add(-2, -3)).toBe(-5);
});

test('add handles zero', () => {
  expect(add(0, 5)).toBe(5);
  expect(add(5, 0)).toBe(5);
});
```

**Code Review Questions**:
- Does coverage meet threshold for this code type?
- Are all branches and edge cases covered?
- Do the tests actually assert meaningful outcomes?
- Are error conditions tested?

---

## Test Anti-Patterns to Flag

### 1. Flaky Tests

**Description**: Tests that pass and fail intermittently without code changes.

**Common Causes**:
- Race conditions in async code
- Reliance on external services
- Time-dependent logic
- Shared mutable state between tests
- Non-deterministic behavior (random, Date.now())

**Example**:
```typescript
// BAD: Flaky due to timing
test('debounced function calls after delay', async () => {
  const fn = jest.fn();
  const debounced = debounce(fn, 100);

  debounced();
  await sleep(105); // Timing-dependent!

  expect(fn).toHaveBeenCalledTimes(1);
});

// GOOD: Control time with fake timers
test('debounced function calls after delay', () => {
  jest.useFakeTimers();
  const fn = jest.fn();
  const debounced = debounce(fn, 100);

  debounced();
  jest.advanceTimersByTime(100);

  expect(fn).toHaveBeenCalledTimes(1);
});
```

**What to Flag in Review**:
- Tests using real timers (setTimeout, setInterval)
- Tests making real HTTP requests
- Tests relying on current time (Date.now())
- Tests with Math.random() without seeding
- Tests with sleep/delay calls

### 2. Test Interdependence

**Description**: Tests that depend on execution order or shared state.

**Example**:
```typescript
// BAD: Tests share state
let user;

test('creates user', () => {
  user = createUser({ name: 'John' });
  expect(user.name).toBe('John');
});

test('updates user', () => {
  user.name = 'Jane'; // Depends on previous test!
  expect(user.name).toBe('Jane');
});
```

**What to Flag in Review**:
- Tests accessing module-level variables
- Tests without proper setup/teardown
- Tests that must run in specific order
- Missing beforeEach/afterEach cleanup

### 3. Assertion Roulette

**Description**: Multiple assertions without clear meaning.

**Example**:
```typescript
// BAD: What does this test actually verify?
test('user operations', () => {
  const user = createUser({ name: 'John', age: 30 });
  expect(user).toBeDefined();
  expect(user.name).toBeTruthy();
  expect(user.age).toBeGreaterThan(0);
  expect(user.id).toBeDefined();
  expect(user.createdAt).toBeTruthy();
  // Which assertion's purpose is which?
});
```

**What to Flag in Review**:
- More than 3-4 assertions per test
- Assertions without clear connection to test name
- Generic assertions (toBeTruthy, toBeDefined) without context

### 4. Test Doubles Abuse

**Description**: Over-mocking leads to tests that don't test anything real.

**Example**:
```typescript
// BAD: Mocking everything
test('processPayment processes payment', () => {
  const paymentService = {
    process: jest.fn().mockReturnValue({ success: true })
  };
  const orderService = {
    updateStatus: jest.fn()
  };

  const result = processPayment(paymentService, orderService);

  expect(result).toEqual({ success: true }); // Just testing the mock!
});
```

**When Mocks Are Appropriate**:
- External services (payment gateways, email services)
- Slow operations (database, network)
- Non-deterministic behavior (random, time)
- Unreliable dependencies

**When Mocks Are Problematic**:
- Mocking the system under test
- Mocking everything (no real code exercised)
- Not verifying interactions with mocks
- Mocking for convenience rather than necessity

**What to Flag in Review**:
- Every dependency mocked
- No real code execution
- Mocking internal modules
- Not asserting on mock interactions

### 5. Testing Private Methods

**Description**: Tests that directly call private methods.

**Example**:
```typescript
// BAD: Testing private implementation
test('_calculateDiscount applies correct formula', () => {
  const calculator = new PriceCalculator();
  expect(calculator._calculateDiscount(100, 0.1)).toBe(10);
});
```

**Why This Is Bad**:
- Private methods are implementation details
- Tests break when refactoring internal structure
- Private methods should be tested through public API

**What to Flag in Review**:
- Tests accessing private methods (_methodName)
- Tests accessing private properties
- Tests bypassing public API

### 6. Mystery Guest

**Description**: Tests that rely on external data not visible in the test.

**Example**:
```typescript
// BAD: Where did this user come from?
test('getUser returns user', async () => {
  const user = await getUser(1); // User ID 1 must exist in DB
  expect(user.name).toBe('John'); // How do we know it's John?
});
```

**What to Flag in Review**:
- Tests depending on database fixtures not shown
- Tests using hardcoded IDs without setup
- Tests assuming external state

---

## Test Organization Patterns

### Test File Structure

**Organize by Feature/Module**:
```
src/
  auth/
    AuthService.ts
    AuthService.test.ts
  payment/
    PaymentService.ts
    PaymentService.test.ts
```

**Group Related Tests**:
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    test('creates user with valid data', () => { ... });
    test('throws error with invalid email', () => { ... });
    test('throws error with duplicate email', () => { ... });
  });

  describe('updateUser', () => {
    test('updates user fields', () => { ... });
    test('throws error if user not found', () => { ... });
  });
});
```

**Code Review Questions**:
- Are tests organized logically?
- Are test files co-located with source files?
- Are related tests grouped with describe blocks?
- Do test names clearly describe what they test?

---

## Integration Test Patterns

### Testing API Endpoints

**Good Pattern**:
```typescript
describe('POST /api/users', () => {
  test('creates user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'John', email: 'john@example.com' });

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      name: 'John',
      email: 'john@example.com'
    });

    // Verify in database
    const user = await User.findOne({ email: 'john@example.com' });
    expect(user).toBeDefined();
  });

  test('returns 400 with invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'John', email: 'invalid' });

    expect(response.status).toBe(400);
    expect(response.body.error).toContain('email');
  });
});
```

**What to Check in Review**:
- Tests both success and error cases
- Verifies HTTP status codes
- Checks response body structure
- Validates side effects (database changes)

### Testing Database Operations

**Setup and Teardown**:
```typescript
describe('UserRepository', () => {
  beforeEach(async () => {
    await db.migrate.latest();
    await db.seed.run();
  });

  afterEach(async () => {
    await db.migrate.rollback();
  });

  test('findById returns user', async () => {
    const user = await UserRepository.findById(1);
    expect(user.email).toBe('test@example.com');
  });
});
```

**What to Check in Review**:
- Database is reset between tests
- Tests don't pollute shared database
- Tests use transactions or cleanup
- Tests are isolated from each other

---

## Mutation Testing Concepts

**Mutation Testing**: Introducing small changes (mutations) to code to verify tests catch them.

**Example Mutations**:
- Change `>` to `>=`
- Change `&&` to `||`
- Change constants (0 to 1)
- Remove return statements

**If tests don't catch mutations, they're inadequate**.

**Tools**:
- Stryker (JavaScript/TypeScript)
- PIT (Java)
- mutmut (Python)

**Code Review Application**:
- If test coverage is high but quality suspected, suggest mutation testing
- Use mutation testing reports to identify weak test suites
- Focus on critical paths for mutation testing

---

## Test Naming Conventions

### Good Test Names

Test names should describe:
1. **What is being tested** (system under test)
2. **Under what conditions** (given/when)
3. **Expected behavior** (then)

**Pattern**: `[method/feature] [condition] [expected behavior]`

**Examples**:
```typescript
test('createUser with valid data returns user with ID', () => { ... });
test('createUser with duplicate email throws ValidationError', () => { ... });
test('calculateTotal with empty cart returns zero', () => { ... });
test('authenticate with invalid token returns 401', () => { ... });
```

**What to Flag in Review**:
- Vague names: `test('it works', ...)`
- Generic names: `test('user test', ...)`
- Implementation-focused names: `test('calls validateEmail', ...)`

---

## Code Review Checklist for Tests

### Structure
- [ ] Tests follow AAA pattern (Arrange, Act, Assert)
- [ ] Tests are properly organized (describe blocks)
- [ ] Test files co-located with source files
- [ ] Test names are descriptive and specific

### Quality
- [ ] Tests verify behavior, not implementation
- [ ] Tests are isolated (no interdependence)
- [ ] Tests are deterministic (no flaky tests)
- [ ] Assertions are meaningful and specific
- [ ] Edge cases and error conditions covered

### Coverage
- [ ] Coverage meets threshold for code type
- [ ] All branches tested
- [ ] Error paths tested
- [ ] Critical paths have 100% coverage

### Mocking
- [ ] Mocks used appropriately (external services, slow operations)
- [ ] System under test not mocked
- [ ] Mock interactions verified
- [ ] Real code executed where possible

### Integration Tests
- [ ] API endpoints tested for success and error cases
- [ ] Database operations tested with proper setup/teardown
- [ ] Side effects verified
- [ ] Tests isolated (database cleanup)

### Performance
- [ ] Tests run fast (< 100ms for unit tests)
- [ ] No unnecessary delays or sleeps
- [ ] Fake timers used for time-dependent code
- [ ] Parallel execution possible

---

## Resources

- **Testing Library**: https://testing-library.com/
- **Jest Documentation**: https://jestjs.io/
- **Test Pyramid**: https://martinfowler.com/bliki/TestPyramid.html
- **Mutation Testing**: https://stryker-mutator.io/
- **Test-Driven Development**: https://martinfowler.com/bliki/TestDrivenDevelopment.html
