# Common Test Patterns

## Setup and Teardown Patterns

### BeforeEach/AfterEach

```javascript
describe('UserRepository', () => {
  let repository;
  let testUser;

  beforeEach(async () => {
    // Fresh repository for each test
    repository = new UserRepository();

    // Create test data
    testUser = await repository.create({
      email: 'test@example.com',
      name: 'Test User'
    });
  });

  afterEach(async () => {
    // Clean up after each test
    await repository.deleteAll();
  });

  test('finds user by id', async () => {
    const found = await repository.findById(testUser.id);
    expect(found.email).toBe('test@example.com');
  });

  test('updates user', async () => {
    await repository.update(testUser.id, { name: 'Updated' });
    const found = await repository.findById(testUser.id);
    expect(found.name).toBe('Updated');
  });
});
```

### BeforeAll/AfterAll

```javascript
describe('Database Integration', () => {
  beforeAll(async () => {
    // One-time setup (expensive operations)
    await database.connect();
    await database.migrate();
  });

  afterAll(async () => {
    // One-time cleanup
    await database.disconnect();
  });

  beforeEach(async () => {
    // Per-test cleanup
    await database.truncate();
  });

  // Tests...
});
```

### Test Fixtures

```javascript
// fixtures/users.js
export const testUsers = {
  admin: {
    email: 'admin@example.com',
    role: 'admin',
    permissions: ['read', 'write', 'delete']
  },
  regular: {
    email: 'user@example.com',
    role: 'user',
    permissions: ['read']
  },
  premium: {
    email: 'premium@example.com',
    role: 'user',
    isPremium: true
  }
};

// Usage in tests
import { testUsers } from './fixtures/users';

test('admin can delete users', async () => {
  const admin = await createUser(testUsers.admin);
  const result = await UserService.delete(admin, '123');
  expect(result.success).toBe(true);
});
```

## Mocking Patterns

### Mock Functions

```javascript
// Simple mock
const mockCallback = jest.fn();

test('calls callback with result', () => {
  processData('input', mockCallback);

  expect(mockCallback).toHaveBeenCalledTimes(1);
  expect(mockCallback).toHaveBeenCalledWith('processed: input');
});

// Mock with return value
const mockFetch = jest.fn(() => Promise.resolve({
  json: () => Promise.resolve({ id: '123' })
}));

global.fetch = mockFetch;

test('fetches data', async () => {
  const data = await fetchUser('123');

  expect(mockFetch).toHaveBeenCalledWith('/api/users/123');
  expect(data.id).toBe('123');
});

// Mock with multiple return values
const mockRandom = jest.fn()
  .mockReturnValueOnce(0.1)
  .mockReturnValueOnce(0.5)
  .mockReturnValueOnce(0.9);

Math.random = mockRandom;

test('generates different values', () => {
  expect(generateId()).toBe('id-01');
  expect(generateId()).toBe('id-05');
  expect(generateId()).toBe('id-09');
});
```

### Mock Modules

```javascript
// Mock entire module
jest.mock('./EmailService');
import { EmailService } from './EmailService';

test('sends email after registration', async () => {
  await UserService.register({ email: 'test@example.com' });

  expect(EmailService.send).toHaveBeenCalledWith({
    to: 'test@example.com',
    template: 'welcome'
  });
});

// Partial mock
jest.mock('./utils', () => ({
  ...jest.requireActual('./utils'),
  generateId: jest.fn(() => 'mock-id')
}));

// Mock with implementation
jest.mock('./database', () => ({
  query: jest.fn((sql) => {
    if (sql.includes('users')) {
      return [{ id: '123', name: 'Test' }];
    }
    return [];
  })
}));
```

### Spy on Methods

```javascript
test('calls internal method', () => {
  const service = new UserService();
  const spy = jest.spyOn(service, 'validateEmail');

  service.createUser({ email: 'test@example.com' });

  expect(spy).toHaveBeenCalledWith('test@example.com');

  spy.mockRestore(); // Restore original implementation
});

// Spy on console
test('logs error message', () => {
  const consoleSpy = jest.spyOn(console, 'error').mockImplementation();

  processWithError();

  expect(consoleSpy).toHaveBeenCalledWith('Error:', expect.any(String));

  consoleSpy.mockRestore();
});
```

### Mock Timers

```javascript
beforeEach(() => {
  jest.useFakeTimers();
});

afterEach(() => {
  jest.useRealTimers();
});

test('debounces function calls', () => {
  const callback = jest.fn();
  const debounced = debounce(callback, 1000);

  debounced('a');
  debounced('b');
  debounced('c');

  expect(callback).not.toHaveBeenCalled();

  jest.advanceTimersByTime(1000);

  expect(callback).toHaveBeenCalledTimes(1);
  expect(callback).toHaveBeenCalledWith('c');
});

test('interval function runs every second', () => {
  const callback = jest.fn();

  startInterval(callback);

  jest.advanceTimersByTime(3000);

  expect(callback).toHaveBeenCalledTimes(3);
});
```

### Mock Dates

```javascript
beforeAll(() => {
  jest.useFakeTimers();
  jest.setSystemTime(new Date('2024-01-01T00:00:00Z'));
});

afterAll(() => {
  jest.useRealTimers();
});

test('calculates days until expiration', () => {
  const expiryDate = new Date('2024-01-10');

  const days = getDaysUntilExpiry(expiryDate);

  expect(days).toBe(9);
});

test('formats current date', () => {
  const formatted = formatCurrentDate();

  expect(formatted).toBe('2024-01-01');
});
```

## Async Testing Patterns

### Promises

```javascript
// Return promise
test('fetches user', () => {
  return fetchUser('123').then(user => {
    expect(user.id).toBe('123');
  });
});

// Async/await (preferred)
test('fetches user', async () => {
  const user = await fetchUser('123');
  expect(user.id).toBe('123');
});

// Test rejection
test('throws when user not found', async () => {
  await expect(fetchUser('999')).rejects.toThrow(NotFoundError);
  await expect(fetchUser('999')).rejects.toThrow('User not found');
});
```

### Callbacks

```javascript
test('calls callback with data', (done) => {
  fetchUser('123', (error, user) => {
    try {
      expect(error).toBeNull();
      expect(user.id).toBe('123');
      done();
    } catch (e) {
      done(e);
    }
  });
});

// With error callback
test('calls error callback on failure', (done) => {
  fetchUser('invalid', (error, user) => {
    expect(error).toBeDefined();
    expect(user).toBeUndefined();
    done();
  });
});
```

### waitFor (Testing Library)

```javascript
test('displays loading then data', async () => {
  render(<UserProfile userId="123" />);

  // Initially loading
  expect(screen.getByText('Loading...')).toBeInTheDocument();

  // Wait for data to load
  await waitFor(() => {
    expect(screen.getByText('Test User')).toBeInTheDocument();
  });

  expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
});

// With timeout
await waitFor(
  () => {
    expect(screen.getByText('Loaded')).toBeInTheDocument();
  },
  { timeout: 5000 }
);
```

### Multiple Async Operations

```javascript
test('handles parallel requests', async () => {
  const [user, posts, comments] = await Promise.all([
    fetchUser('123'),
    fetchPosts('123'),
    fetchComments('123')
  ]);

  expect(user.id).toBe('123');
  expect(posts).toHaveLength(5);
  expect(comments).toHaveLength(10);
});

test('handles sequential operations', async () => {
  const user = await createUser({ email: 'test@example.com' });
  const profile = await createProfile({ userId: user.id });
  const settings = await createSettings({ profileId: profile.id });

  expect(settings.profileId).toBe(profile.id);
  expect(profile.userId).toBe(user.id);
});
```

## React Testing Patterns

### Component Rendering

```javascript
import { render, screen } from '@testing-library/react';

test('renders with props', () => {
  render(<UserCard user={{ name: 'John', email: 'john@example.com' }} />);

  expect(screen.getByText('John')).toBeInTheDocument();
  expect(screen.getByText('john@example.com')).toBeInTheDocument();
});

test('renders with children', () => {
  render(
    <Card>
      <h1>Title</h1>
      <p>Content</p>
    </Card>
  );

  expect(screen.getByText('Title')).toBeInTheDocument();
  expect(screen.getByText('Content')).toBeInTheDocument();
});
```

### User Interactions

```javascript
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('handles button click', () => {
  const onClick = jest.fn();
  render(<Button onClick={onClick}>Click me</Button>);

  fireEvent.click(screen.getByText('Click me'));

  expect(onClick).toHaveBeenCalledTimes(1);
});

test('handles form submission', async () => {
  const onSubmit = jest.fn();
  render(<LoginForm onSubmit={onSubmit} />);

  await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
  await userEvent.type(screen.getByLabelText('Password'), 'password123');
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));

  expect(onSubmit).toHaveBeenCalledWith({
    email: 'test@example.com',
    password: 'password123'
  });
});
```

### Custom Hooks

```javascript
import { renderHook, act } from '@testing-library/react';

test('useCounter increments', () => {
  const { result } = renderHook(() => useCounter());

  expect(result.current.count).toBe(0);

  act(() => {
    result.current.increment();
  });

  expect(result.current.count).toBe(1);
});

test('useCounter with initial value', () => {
  const { result } = renderHook(() => useCounter(10));

  expect(result.current.count).toBe(10);
});
```

### Context Providers

```javascript
const Wrapper = ({ children }) => (
  <ThemeProvider theme="dark">
    <AuthProvider user={testUser}>
      {children}
    </AuthProvider>
  </ThemeProvider>
);

test('uses context values', () => {
  render(<UserProfile />, { wrapper: Wrapper });

  expect(screen.getByText('Dark Mode')).toBeInTheDocument();
  expect(screen.getByText(testUser.name)).toBeInTheDocument();
});

// Hook with context
test('useAuth returns user', () => {
  const { result } = renderHook(() => useAuth(), { wrapper: Wrapper });

  expect(result.current.user).toEqual(testUser);
});
```

## API Testing Patterns

### REST API

```javascript
import request from 'supertest';
import app from '../app';

describe('User API', () => {
  test('GET /api/users returns users', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect(200)
      .expect('Content-Type', /json/);

    expect(response.body).toHaveLength(10);
    expect(response.body[0]).toHaveProperty('id');
    expect(response.body[0]).toHaveProperty('email');
  });

  test('POST /api/users creates user', async () => {
    const userData = {
      email: 'new@example.com',
      name: 'New User'
    };

    const response = await request(app)
      .post('/api/users')
      .send(userData)
      .expect(201);

    expect(response.body.email).toBe(userData.email);
    expect(response.body.id).toBeDefined();
  });

  test('PUT /api/users/:id updates user', async () => {
    const user = await createTestUser();

    await request(app)
      .put(`/api/users/${user.id}`)
      .send({ name: 'Updated Name' })
      .expect(200);

    const updated = await findUser(user.id);
    expect(updated.name).toBe('Updated Name');
  });

  test('DELETE /api/users/:id deletes user', async () => {
    const user = await createTestUser();

    await request(app)
      .delete(`/api/users/${user.id}`)
      .expect(204);

    const found = await findUser(user.id);
    expect(found).toBeNull();
  });
});
```

### Authentication

```javascript
describe('Protected Routes', () => {
  let authToken;

  beforeEach(async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'password' });

    authToken = response.body.token;
  });

  test('requires authentication', async () => {
    await request(app)
      .get('/api/profile')
      .expect(401);
  });

  test('allows access with valid token', async () => {
    await request(app)
      .get('/api/profile')
      .set('Authorization', `Bearer ${authToken}`)
      .expect(200);
  });

  test('rejects invalid token', async () => {
    await request(app)
      .get('/api/profile')
      .set('Authorization', 'Bearer invalid-token')
      .expect(401);
  });
});
```

## Database Testing Patterns

### Transaction Rollback

```javascript
describe('User Repository', () => {
  let transaction;

  beforeEach(async () => {
    transaction = await db.transaction();
  });

  afterEach(async () => {
    await transaction.rollback();
  });

  test('creates user', async () => {
    const user = await repository.create(
      { email: 'test@example.com' },
      { transaction }
    );

    expect(user.id).toBeDefined();

    // User exists in transaction
    const found = await repository.findById(user.id, { transaction });
    expect(found).toBeTruthy();
  });

  // After test, rollback means user doesn't exist in database
});
```

### In-Memory Database

```javascript
import { MongoMemoryServer } from 'mongodb-memory-server';

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

beforeEach(async () => {
  await mongoose.connection.db.dropDatabase();
});
```

## Snapshot Testing

### Component Snapshots

```javascript
test('matches snapshot', () => {
  const { container } = render(<UserCard user={testUser} />);

  expect(container).toMatchSnapshot();
});

// Update snapshots: npm test -- -u
```

### Inline Snapshots

```javascript
test('formats user data', () => {
  const result = formatUser({
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com'
  });

  expect(result).toMatchInlineSnapshot(`
    {
      "displayName": "John Doe",
      "email": "john@example.com",
    }
  `);
});
```

### Property Testing

```javascript
test('formats any valid user', () => {
  const users = [
    { name: 'Alice', email: 'alice@example.com' },
    { name: 'Bob', email: 'bob@example.com' },
    { name: 'Charlie', email: 'charlie@example.com' }
  ];

  users.forEach(user => {
    const result = formatUser(user);

    expect(result).toMatchObject({
      name: expect.any(String),
      email: expect.stringMatching(/@/)
    });
  });
});
```

## Parameterized Tests

### test.each

```javascript
test.each([
  [1, 1, 2],
  [1, 2, 3],
  [2, 3, 5],
])('adds %i + %i to equal %i', (a, b, expected) => {
  expect(add(a, b)).toBe(expected);
});

test.each([
  { email: 'test@example.com', valid: true },
  { email: 'invalid', valid: false },
  { email: 'no-at-sign.com', valid: false },
  { email: '@no-local.com', valid: false },
])('validates email: $email', ({ email, valid }) => {
  expect(validateEmail(email)).toBe(valid);
});
```

### describe.each

```javascript
describe.each([
  { role: 'admin', canDelete: true },
  { role: 'user', canDelete: false },
  { role: 'guest', canDelete: false },
])('$role permissions', ({ role, canDelete }) => {
  test('can delete', () => {
    const user = { role };
    expect(userCanDelete(user)).toBe(canDelete);
  });
});
```

## Error Testing Patterns

### Exception Testing

```javascript
test('throws for invalid input', () => {
  expect(() => {
    validateEmail('invalid');
  }).toThrow('Invalid email format');
});

test('throws specific error type', () => {
  expect(() => {
    processPayment(-100);
  }).toThrow(ValidationError);
});

test('async error', async () => {
  await expect(fetchUser('invalid')).rejects.toThrow(NotFoundError);
});
```

### Error Boundaries (React)

```javascript
test('catches error and displays fallback', () => {
  const ThrowError = () => {
    throw new Error('Test error');
  };

  render(
    <ErrorBoundary fallback={<div>Error occurred</div>}>
      <ThrowError />
    </ErrorBoundary>
  );

  expect(screen.getByText('Error occurred')).toBeInTheDocument();
});
```

## Test Organization

### Grouping Tests

```javascript
describe('UserService', () => {
  describe('create', () => {
    test('creates user with valid data', () => {});
    test('throws error for invalid email', () => {});
    test('throws error for duplicate email', () => {});
  });

  describe('update', () => {
    test('updates user fields', () => {});
    test('throws error when user not found', () => {});
  });

  describe('delete', () => {
    test('deletes user', () => {});
    test('throws error when user not found', () => {});
  });
});
```

### Skip/Only Tests

```javascript
// Run only this test
test.only('focused test', () => {
  // Only this runs
});

// Skip this test
test.skip('skipped test', () => {
  // This doesn't run
});

// Conditional skip
const skipOnCI = process.env.CI ? test.skip : test;

skipOnCI('local only test', () => {
  // Runs locally but not in CI
});
```

## Best Practices

1. **Use Descriptive Names** - Test names should describe behavior
2. **Follow AAA Pattern** - Arrange, Act, Assert
3. **One Assertion Per Test** - Keep tests focused
4. **Independent Tests** - No shared state
5. **Clean Up** - Use afterEach/afterAll
6. **Mock External Dependencies** - API calls, databases
7. **Test Behavior, Not Implementation** - Focus on outputs
8. **Use Test Data Factories** - Reusable test data
9. **Avoid Logic in Tests** - Tests should be simple
10. **Keep Tests Fast** - < 10ms for unit tests

---

**Remember**: Good test patterns make tests easier to write, maintain, and understand. Choose patterns that fit your specific use case.
