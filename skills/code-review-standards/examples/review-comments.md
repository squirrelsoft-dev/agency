# Code Review Comment Templates

Pre-written comment templates for common code review scenarios. These templates provide constructive, specific feedback that helps developers improve their code while maintaining a positive tone.

## Security Issues

### Authentication Missing

```
🔒 **Security: Missing Authentication**

This endpoint processes sensitive user data but doesn't require authentication.
Any user (or anonymous attacker) could access/modify this resource.

**Recommended fix**: Add authentication middleware:
```ts
app.delete('/api/users/:id', requireAuth, async (req, res) => {
  // existing code
});
```

**Priority**: HIGH - Must fix before merge
```

###

 Authorization Check Missing

```
🔒 **Security: Missing Authorization Check**

This endpoint checks authentication but not authorization. Any authenticated
user could delete any other user's resource.

**Recommended fix**: Verify ownership or admin role:
```ts
if (req.user.id !== req.params.id && !req.user.isAdmin) {
  return res.status(403).json({ error: "Unauthorized" });
}
```

**Priority**: HIGH - Must fix before merge
```

### SQL Injection Risk

```
🔒 **Security: SQL Injection Vulnerability**

This query concatenates user input directly into the SQL string, allowing
SQL injection attacks.

**Current code is vulnerable**:
```ts
const query = `SELECT * FROM users WHERE email = '${email}'`;
```

**Recommended fix**: Use parameterized queries:
```ts
const query = `SELECT * FROM users WHERE email = ?`;
const users = await db.execute(query, [email]);
```

**Priority**: CRITICAL - Blocks merge
**Reference**: OWASP Top 10 #3 (Injection)
```

### Sensitive Data in Logs

```
🔒 **Security: Sensitive Data Logged**

This log statement includes a password, which will appear in plaintext in
log files and monitoring systems.

**Recommended fix**: Redact sensitive fields:
```ts
console.log("User login attempt:", {
  email: email,
  password: "[REDACTED]"
});
```

**Priority**: MEDIUM - Should fix before merge
```

---

## Code Quality

### Extract to Reusable Function

```
♻️ **Code Quality: Extract to Reusable Function**

This calculation logic appears in 3 different places. Consider extracting
to a shared utility function for better maintainability.

**Suggested refactoring**:
```ts
// utils/cart.ts
export function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

// In components
const total = calculateTotal(items);
```

**Benefits**: Single source of truth, easier testing, consistent behavior

**Priority**: LOW - Nice to have
```

### Magic Number

```
♻️ **Code Quality: Magic Number**

The constant `65` appears without explanation. Consider defining it as
a named constant for clarity.

**Suggested improvement**:
```ts
const RETIREMENT_AGE = 65;

if (user.age > RETIREMENT_AGE) {
  // apply senior discount
}
```

**Priority**: LOW - Nice to have
```

### High Complexity

```
♻️ **Code Quality: High Complexity**

This function has a cyclomatic complexity of 18, making it hard to
understand and test. Consider breaking it into smaller functions.

**Suggested approach**:
1. Extract validation logic → `validateOrder()`
2. Extract calculation logic → `calculatePricing()`
3. Extract payment logic → `processPayment()`

Each smaller function will be easier to test and maintain.

**Priority**: MEDIUM - Should refactor
```

### Inconsistent Naming

```
♻️ **Code Quality: Inconsistent Naming**

Variable `usr` abbreviates "user" but elsewhere in the codebase we use
the full word. Let's maintain consistency.

**Suggested change**: `usr` → `user`

**Priority**: LOW - Style consistency
```

### Missing Early Return

```
♻️ **Code Quality: Deep Nesting**

This function has 5 levels of nesting. Consider using early returns
for better readability.

**Current pattern**:
```ts
if (condition1) {
  if (condition2) {
    if (condition3) {
      // deeply nested logic
    }
  }
}
```

**Suggested refactoring**:
```ts
if (!condition1) return;
if (!condition2) return;
if (!condition3) return;
// main logic (no nesting)
```

**Priority**: MEDIUM - Readability improvement
```

---

## Performance

### N+1 Query

```
⚡ **Performance: N+1 Query Problem**

This code executes 1 query for posts, then N additional queries for authors
(one per post). This will cause performance issues with many posts.

**Current approach** (N+1 queries):
```ts
const posts = await db.query('SELECT * FROM posts');
for (const post of posts) {
  post.author = await db.query('SELECT * FROM users WHERE id = ?', [post.authorId]);
}
```

**Recommended fix** (single query with JOIN):
```ts
const posts = await db.query(`
  SELECT p.*, u.name as authorName, u.email as authorEmail
  FROM posts p
  JOIN users u ON p.authorId = u.id
`);
```

**Impact**: With 100 posts, this reduces 101 queries → 1 query

**Priority**: MEDIUM - Performance optimization
```

### Missing Index

```
⚡ **Performance: Missing Database Index**

This query filters by `customer_email` but the column isn't indexed,
causing a full table scan on every request.

**Recommended fix**: Add an index:
```sql
CREATE INDEX idx_orders_customer_email ON orders(customer_email);
```

**Impact**: Speeds up query from O(n) to O(log n)

**Priority**: MEDIUM - Performance optimization
```

### Missing Pagination

```
⚡ **Performance: Missing Pagination**

This endpoint returns ALL users without pagination, which could be
thousands of records. This will cause performance and memory issues.

**Recommended fix**: Implement pagination:
```ts
app.get('/api/users', async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const offset = (page - 1) * limit;

  const users = await db.query(
    'SELECT * FROM users LIMIT ? OFFSET ?',
    [limit, offset]
  );

  res.json({ users, page, limit });
});
```

**Priority**: HIGH - Prevents production issues
```

### Unnecessary Re-render

```
⚡ **Performance: Unnecessary Re-renders**

This component creates a new object on every render, causing child
components to re-render unnecessarily.

**Current code** (new object every render):
```tsx
function Parent() {
  const options = { key: 'value' }; // New object!
  return <Child options={options} />;
}
```

**Recommended fix**: Use useMemo:
```tsx
function Parent() {
  const options = useMemo(() => ({ key: 'value' }), []);
  return <Child options={options} />;
}
```

**Priority**: LOW - Micro-optimization (only matters for heavy components)
```

---

## Testing

### Missing Test

```
🧪 **Testing: Missing Unit Test**

This function contains important business logic but has no test coverage.
Please add tests covering:

1. Success case with valid input
2. Error case with invalid input
3. Edge case with boundary values

**Example test structure**:
```ts
describe('calculateDiscount', () => {
  test('applies 10% discount for premium users', () => {
    expect(calculateDiscount(100, { isPremium: true })).toBe(10);
  });

  test('applies no discount for standard users', () => {
    expect(calculateDiscount(100, { isPremium: false })).toBe(0);
  });
});
```

**Priority**: HIGH - Required for merge
```

### Testing Implementation

```
🧪 **Testing: Testing Implementation Details**

This test accesses private methods/properties, coupling it to
implementation details. It will break when refactoring internal structure.

**Current test** (implementation-focused):
```ts
expect(component._internalState).toBe(5);
```

**Recommended approach** (behavior-focused):
```ts
expect(component.getValue()).toBe(5);
```

**Priority**: MEDIUM - Test quality improvement
```

### Flaky Test

```
🧪 **Testing: Potentially Flaky Test**

This test uses real timers and may fail intermittently due to timing issues.

**Current test**:
```ts
await sleep(105); // Timing-dependent!
expect(fn).toHaveBeenCalled();
```

**Recommended fix**: Use fake timers:
```ts
jest.useFakeTimers();
debounced();
jest.advanceTimersByTime(100);
expect(fn).toHaveBeenCalled();
```

**Priority**: MEDIUM - Prevents CI flakiness
```

### Missing Error Case

```
🧪 **Testing: Missing Error Case**

Tests cover the success path but not error conditions. Please add tests
for error scenarios:

**Suggested tests**:
```ts
test('throws ValidationError with invalid email', () => {
  expect(() => createUser({ email: 'invalid' }))
    .toThrow(ValidationError);
});

test('throws NotFoundError when user does not exist', () => {
  expect(() => getUser(999))
    .toThrow(NotFoundError);
});
```

**Priority**: MEDIUM - Improves test coverage
```

---

## Documentation

### Missing JSDoc

```
📚 **Documentation: Missing Function Documentation**

This public API function lacks documentation. Please add JSDoc with:
- Parameter descriptions and types
- Return value description
- Example usage
- Notes on side effects or caveats

**Suggested documentation**:
```ts
/**
 * Fetches user profile with eager-loaded preferences.
 *
 * @param id - User UUID
 * @returns User with preferences, or null if not found
 * @throws DatabaseError if connection fails
 *
 * Note: This function caches results for 5 minutes to reduce DB load.
 * Use getUserByIdFresh() if you need uncached data.
 *
 * @example
 * const user = await getUserById('123e4567-e89b-12d3-a456-426614174000');
 * console.log(user.preferences);
 */
async function getUserById(id: string): Promise<User | null> {
  // implementation
}
```

**Priority**: MEDIUM - API documentation
```

### Unclear Logic

```
📚 **Documentation: Complex Logic Needs Explanation**

This calculation is non-obvious and would benefit from a comment
explaining the formula and why it's structured this way.

**Suggested comment**:
```ts
// Calculate final price with compound discount and tax
// Formula: (base × (1 + tax%) × (1 - discount%)) + shipping
// Example: $100 × 1.08 × 0.90 + $5 = $102.20
// Note: Tax is applied before discount per accounting policy
const price = base * (1 + taxRate) * (1 - discountRate) + shipping;
```

**Priority**: LOW - Code clarity
```

---

## Positive Feedback

### Great Test Coverage

```
✅ **Great Test Coverage!**

Excellent work on the test coverage for this feature. The tests cover:
- Success cases
- Error conditions
- Edge cases (empty arrays, null values, boundary values)

The tests are well-structured with the AAA pattern and have clear,
descriptive names. This makes the code safe to refactor with confidence.
```

### Clean Refactoring

```
✅ **Nice Refactoring!**

This refactoring significantly improves code clarity:
- Extracted complex logic into well-named functions
- Reduced cyclomatic complexity from 15 → 5
- Much easier to test and maintain

Great work on keeping the code clean!
```

### Security Awareness

```
✅ **Good Security Practice**

Nice catch on using parameterized queries here. This properly prevents
SQL injection vulnerabilities. It's great to see security-conscious coding!
```

### Performance Optimization

```
✅ **Smart Optimization**

Good call on using memoization here. This prevents expensive recalculations
and will improve performance, especially for frequently-accessed data.

The before/after benchmarks in the PR description are helpful for
understanding the impact.
```

---

## General Questions

### Clarifying Intent

```
❓ **Question: Clarify Intent**

I'm trying to understand the reasoning behind this approach. Could you help
me understand:

1. Why was approach X chosen over approach Y?
2. Are there performance/security considerations I'm missing?
3. Is this pattern documented somewhere I should review?

This will help me provide better feedback and learn from your solution.
```

### Alternative Approach

```
💡 **Suggestion: Consider Alternative Approach**

Have you considered using [alternative approach]? It might offer these
benefits:

**Pros**:
- Benefit 1
- Benefit 2

**Cons**:
- Tradeoff 1

I'm curious about your thoughts on this approach. There may be constraints
I'm not aware of that make the current approach better.
```

---

## Decision Templates

### Approve with Minor Nitpicks

```
✅ **Approved with Minor Suggestions**

The code looks good and is ready to merge! I left a few minor suggestions
for future consideration, but they don't block this PR:

1. [Minor suggestion 1]
2. [Minor suggestion 2]

These are style preferences and can be addressed in a follow-up if desired.

Great work on this feature!
```

### Request Changes

```
🔄 **Changes Requested**

This PR has some issues that need to be addressed before merging:

**Must Fix** (blocking):
1. Security: SQL injection vulnerability in UserController.ts:45
2. Missing tests for new PaymentService methods
3. Performance: N+1 query in OrdersController.ts:78

**Should Fix** (important but not blocking):
1. High complexity in processOrder() function
2. Missing error handling for network requests

Once these are addressed, I'll re-review. Happy to discuss any of these points!
```

### Approve Enthusiastically

```
🎉 **Excellent Work - Approved!**

This is a really solid implementation:

✅ Clean, readable code with good naming
✅ Comprehensive test coverage (95%+)
✅ Good error handling and edge cases covered
✅ Performance considerations addressed
✅ Security best practices followed

The code review was a pleasure. Great job!
```

---

## Tone Guidelines

### DO ✅
- Be specific and actionable
- Explain the "why" behind suggestions
- Offer alternatives or examples
- Ask questions to understand context
- Acknowledge good work
- Use friendly, collaborative language

### DON'T ❌
- Make vague criticisms ("this is bad")
- Use dismissive language
- Assume incompetence
- Focus only on negatives
- Make demands without explanation
- Use sarcasm or passive-aggressive tone

### Example Transformations

**Bad**: "This code is terrible"
**Good**: "Consider refactoring this for better maintainability. Here's how..."

**Bad**: "You forgot error handling"
**Good**: "This function could benefit from error handling for the network request. Example: ..."

**Bad**: "Everyone knows you shouldn't do this"
**Good**: "This pattern can lead to X issue. A safer approach is Y because..."

**Bad**: "Why did you do it this way?"
**Good**: "I'm curious about the reasoning behind this approach. Could you help me understand the constraints or requirements that led to this solution?"
