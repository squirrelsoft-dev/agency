# Code Quality Examples: Before & After Refactoring

Real-world examples of code smells and their refactored solutions. Each example shows the problematic code, explains why it's problematic, and provides a clean solution.

## 1. Long Method with High Complexity

### Before (Complexity: 18, Length: 85 lines)

```typescript
function processOrder(order, user, inventory) {
  // Validate order
  if (!order) throw new Error('Order required');
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items');
  }
  if (!user) throw new Error('User required');
  if (!user.paymentMethod) throw new Error('Payment method required');

  // Check inventory
  for (const item of order.items) {
    const inventoryItem = inventory.find(i => i.id === item.productId);
    if (!inventoryItem) {
      throw new Error(`Product ${item.productId} not found`);
    }
    if (inventoryItem.stock < item.quantity) {
      throw new Error(`Insufficient stock for ${inventoryItem.name}`);
    }
  }

  // Calculate totals
  let subtotal = 0;
  for (const item of order.items) {
    subtotal += item.price * item.quantity;
  }

  let discount = 0;
  if (user.isPremium) {
    discount = subtotal * 0.1;
  } else if (subtotal > 100) {
    discount = subtotal * 0.05;
  }

  const tax = (subtotal - discount) * 0.08;
  const shipping = subtotal > 50 ? 0 : 10;
  const total = subtotal - discount + tax + shipping;

  // Process payment
  if (user.paymentMethod === 'card') {
    if (!user.cardNumber || !user.cardExpiry) {
      throw new Error('Card details required');
    }
    // Process card payment
  } else if (user.paymentMethod === 'paypal') {
    if (!user.paypalEmail) {
      throw new Error('PayPal email required');
    }
    // Process PayPal payment
  } else {
    throw new Error('Invalid payment method');
  }

  // Update inventory
  for (const item of order.items) {
    const inventoryItem = inventory.find(i => i.id === item.productId);
    inventoryItem.stock -= item.quantity;
  }

  // Create order record
  const orderRecord = {
    id: generateId(),
    userId: user.id,
    items: order.items,
    subtotal,
    discount,
    tax,
    shipping,
    total,
    status: 'completed',
    createdAt: new Date()
  };

  return orderRecord;
}
```

**Problems**:
- High cyclomatic complexity (18)
- Too many responsibilities (validation, calculation, payment, inventory)
- Hard to test individual pieces
- Difficult to maintain and extend
- Nested conditionals and loops

### After (Multiple functions, each complexity < 5)

```typescript
function processOrder(order, user, inventory) {
  validateOrder(order, user);
  checkInventoryAvailability(order, inventory);

  const pricing = calculatePricing(order, user);
  processPayment(user, pricing.total);
  updateInventory(order, inventory);

  return createOrderRecord(order, user, pricing);
}

function validateOrder(order, user) {
  if (!order?.items?.length) {
    throw new ValidationError('Order must have items');
  }
  if (!user?.paymentMethod) {
    throw new ValidationError('Payment method required');
  }
}

function checkInventoryAvailability(order, inventory) {
  for (const item of order.items) {
    const inventoryItem = findInventoryItem(inventory, item.productId);
    if (inventoryItem.stock < item.quantity) {
      throw new InsufficientStockError(inventoryItem.name);
    }
  }
}

function calculatePricing(order, user) {
  const subtotal = calculateSubtotal(order.items);
  const discount = calculateDiscount(subtotal, user);
  const tax = calculateTax(subtotal - discount);
  const shipping = calculateShipping(subtotal);

  return {
    subtotal,
    discount,
    tax,
    shipping,
    total: subtotal - discount + tax + shipping
  };
}

function calculateDiscount(subtotal, user) {
  if (user.isPremium) return subtotal * 0.1;
  if (subtotal > 100) return subtotal * 0.05;
  return 0;
}

function processPayment(user, amount) {
  const strategy = paymentStrategies[user.paymentMethod];
  if (!strategy) {
    throw new PaymentError('Invalid payment method');
  }
  return strategy.process(user, amount);
}
```

**Improvements**:
- Each function has single responsibility
- Low complexity (< 5 per function)
- Easy to test individual functions
- Clear separation of concerns
- Extensible (e.g., new payment methods)

---

## 2. Duplicate Code (DRY Violation)

### Before

```typescript
// In ProductList component
function ProductList() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    fetch('/api/products')
      .then(res => res.json())
      .then(data => setProducts(data))
      .catch(err => console.error('Error fetching products:', err));
  }, []);

  return <div>{/* render products */}</div>;
}

// In CategoryList component
function CategoryList() {
  const [categories, setCategories] = useState([]);

  useEffect(() => {
    fetch('/api/categories')
      .then(res => res.json())
      .then(data => setCategories(data))
      .catch(err => console.error('Error fetching categories:', err));
  }, []);

  return <div>{/* render categories */}</div>;
}

// In UserProfile component
function UserProfile() {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetch('/api/user/profile')
      .then(res => res.json())
      .then(data => setUser(data))
      .catch(err => console.error('Error fetching user:', err));
  }, []);

  return <div>{/* render user */}</div>;
}
```

**Problems**:
- Same fetching logic repeated 3 times
- Error handling duplicated
- Hard to change (must update 3 places)

### After

```typescript
// Custom hook for data fetching
function useFetch(url) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    setLoading(true);
    fetch(url)
      .then(res => res.json())
      .then(data => {
        setData(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err);
        setLoading(false);
      });
  }, [url]);

  return { data, loading, error };
}

// Clean component code
function ProductList() {
  const { data: products, loading, error } = useFetch('/api/products');

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  return <div>{/* render products */}</div>;
}

function CategoryList() {
  const { data: categories, loading, error } = useFetch('/api/categories');

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  return <div>{/* render categories */}</div>;
}

function UserProfile() {
  const { data: user, loading, error } = useFetch('/api/user/profile');

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  return <div>{/* render user */}</div>;
}
```

**Improvements**:
- Fetching logic in one place
- Consistent error and loading states
- Easy to enhance (add caching, retries, etc.)
- Testable hook

---

## 3. Magic Numbers and Strings

### Before

```typescript
function calculateShipping(weight, distance) {
  if (weight < 5) {
    return distance * 0.5;
  } else if (weight < 20) {
    return distance * 0.8;
  } else {
    return distance * 1.2;
  }
}

function validateUser(user) {
  if (user.age < 18) return false;
  if (user.name.length < 3 || user.name.length > 50) return false;
  if (!user.email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) return false;
  return true;
}

function applyDiscount(price, userType) {
  if (userType === 'premium') return price * 0.9;
  if (userType === 'vip') return price * 0.85;
  if (userType === 'employee') return price * 0.7;
  return price;
}
```

**Problems**:
- Numbers have no meaning (why 5? why 0.5?)
- Strings prone to typos ('premiumm' would fail silently)
- Hard to maintain and update

### After

```typescript
// Constants with clear names
const SHIPPING_RATES = {
  LIGHT_WEIGHT_THRESHOLD_LBS: 5,
  MEDIUM_WEIGHT_THRESHOLD_LBS: 20,
  LIGHT_RATE_PER_MILE: 0.5,
  MEDIUM_RATE_PER_MILE: 0.8,
  HEAVY_RATE_PER_MILE: 1.2
};

const USER_VALIDATION = {
  MIN_AGE: 18,
  MIN_NAME_LENGTH: 3,
  MAX_NAME_LENGTH: 50,
  EMAIL_PATTERN: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
};

const USER_TYPES = {
  PREMIUM: 'premium',
  VIP: 'vip',
  EMPLOYEE: 'employee',
  STANDARD: 'standard'
} as const;

const DISCOUNT_RATES = {
  [USER_TYPES.PREMIUM]: 0.1,
  [USER_TYPES.VIP]: 0.15,
  [USER_TYPES.EMPLOYEE]: 0.3,
  [USER_TYPES.STANDARD]: 0
};

// Clear, self-documenting code
function calculateShipping(weight, distance) {
  let ratePerMile;

  if (weight < SHIPPING_RATES.LIGHT_WEIGHT_THRESHOLD_LBS) {
    ratePerMile = SHIPPING_RATES.LIGHT_RATE_PER_MILE;
  } else if (weight < SHIPPING_RATES.MEDIUM_WEIGHT_THRESHOLD_LBS) {
    ratePerMile = SHIPPING_RATES.MEDIUM_RATE_PER_MILE;
  } else {
    ratePerMile = SHIPPING_RATES.HEAVY_RATE_PER_MILE;
  }

  return distance * ratePerMile;
}

function validateUser(user) {
  if (user.age < USER_VALIDATION.MIN_AGE) return false;
  if (user.name.length < USER_VALIDATION.MIN_NAME_LENGTH ||
      user.name.length > USER_VALIDATION.MAX_NAME_LENGTH) return false;
  if (!USER_VALIDATION.EMAIL_PATTERN.test(user.email)) return false;
  return true;
}

function applyDiscount(price, userType) {
  const discountRate = DISCOUNT_RATES[userType] ?? DISCOUNT_RATES[USER_TYPES.STANDARD];
  return price * (1 - discountRate);
}
```

**Improvements**:
- Numbers have clear meaning
- Easy to change rates in one place
- Type-safe string constants
- Self-documenting code

---

## 4. Deeply Nested Conditionals

### Before

```typescript
function processPayment(order, user, paymentInfo) {
  if (order) {
    if (user) {
      if (paymentInfo) {
        if (paymentInfo.method === 'card') {
          if (paymentInfo.cardNumber) {
            if (paymentInfo.cvv && paymentInfo.cvv.length === 3) {
              if (paymentInfo.expiry) {
                if (isValidExpiry(paymentInfo.expiry)) {
                  return processCardPayment(order, paymentInfo);
                } else {
                  throw new Error('Card expired');
                }
              } else {
                throw new Error('Expiry required');
              }
            } else {
              throw new Error('Invalid CVV');
            }
          } else {
            throw new Error('Card number required');
          }
        } else {
          throw new Error('Payment method not supported');
        }
      } else {
        throw new Error('Payment info required');
      }
    } else {
      throw new Error('User required');
    }
  } else {
    throw new Error('Order required');
  }
}
```

**Problems**:
- Nesting depth: 8 levels (hard to read)
- Error messages buried deep
- Hard to understand control flow
- Difficult to add new conditions

### After

```typescript
function processPayment(order, user, paymentInfo) {
  // Early returns for validation
  if (!order) throw new Error('Order required');
  if (!user) throw new Error('User required');
  if (!paymentInfo) throw new Error('Payment info required');

  if (paymentInfo.method !== 'card') {
    throw new Error('Payment method not supported');
  }

  validateCardInfo(paymentInfo);
  return processCardPayment(order, paymentInfo);
}

function validateCardInfo(paymentInfo) {
  if (!paymentInfo.cardNumber) {
    throw new Error('Card number required');
  }
  if (!paymentInfo.cvv || paymentInfo.cvv.length !== 3) {
    throw new Error('Invalid CVV');
  }
  if (!paymentInfo.expiry) {
    throw new Error('Expiry required');
  }
  if (!isValidExpiry(paymentInfo.expiry)) {
    throw new Error('Card expired');
  }
}
```

**Improvements**:
- Max nesting: 1 level
- Clear validation flow
- Easy to read top-to-bottom
- Extracted validation logic

---

## 5. God Class

### Before

```typescript
class UserService {
  // Authentication
  async login(email, password) { /* ... */ }
  async logout(userId) { /* ... */ }
  async validateToken(token) { /* ... */ }

  // User Management
  async createUser(userData) { /* ... */ }
  async updateUser(userId, updates) { /* ... */ }
  async deleteUser(userId) { /* ... */ }

  // Email Operations
  async sendWelcomeEmail(user) { /* ... */ }
  async sendPasswordResetEmail(user) { /* ... */ }
  async sendNotificationEmail(user, message) { /* ... */ }

  // Payment Operations
  async processPayment(userId, amount) { /* ... */ }
  async refundPayment(transactionId) { /* ... */ }
  async getPaymentHistory(userId) { /* ... */ }

  // Analytics
  async trackUserActivity(userId, action) { /* ... */ }
  async generateUserReport(userId) { /* ... */ }
  async exportUserData(userId) { /* ... */ }
}
```

**Problems**:
- Single class with 5+ responsibilities
- Hard to test (must mock everything)
- Changes to one feature affect entire class
- Violates Single Responsibility Principle

### After

```typescript
// Authentication Service
class AuthService {
  async login(email, password) { /* ... */ }
  async logout(userId) { /* ... */ }
  async validateToken(token) { /* ... */ }
}

// User Management Service
class UserService {
  async createUser(userData) { /* ... */ }
  async updateUser(userId, updates) { /* ... */ }
  async deleteUser(userId) { /* ... */ }
}

// Email Service
class EmailService {
  async sendWelcomeEmail(user) { /* ... */ }
  async sendPasswordResetEmail(user) { /* ... */ }
  async sendNotificationEmail(user, message) { /* ... */ }
}

// Payment Service
class PaymentService {
  async processPayment(userId, amount) { /* ... */ }
  async refundPayment(transactionId) { /* ... */ }
  async getPaymentHistory(userId) { /* ... */ }
}

// Analytics Service
class AnalyticsService {
  async trackUserActivity(userId, action) { /* ... */ }
  async generateUserReport(userId) { /* ... */ }
  async exportUserData(userId) { /* ... */ }
}
```

**Improvements**:
- Each class has single responsibility
- Easy to test in isolation
- Changes localized to relevant class
- Clear boundaries between concerns

---

## 6. Primitive Obsession

### Before

```typescript
function createUser(name, email, age, street, city, state, zip) {
  if (!email.includes('@')) throw new Error('Invalid email');
  if (age < 18) throw new Error('Must be 18+');
  if (!name || name.length < 2) throw new Error('Invalid name');

  return {
    name,
    email,
    age,
    address: `${street}, ${city}, ${state} ${zip}`
  };
}

function sendEmail(toEmail, fromEmail, subject, body) {
  if (!toEmail.includes('@')) throw new Error('Invalid to email');
  if (!fromEmail.includes('@')) throw new Error('Invalid from email');
  // send email
}
```

**Problems**:
- Same validation repeated
- Address is just a string (hard to parse)
- Too many primitive parameters
- No type safety or domain modeling

### After

```typescript
// Value Objects
class Email {
  constructor(private value: string) {
    if (!value.includes('@')) {
      throw new ValidationError('Invalid email format');
    }
  }

  toString() {
    return this.value;
  }
}

class Address {
  constructor(
    public street: string,
    public city: string,
    public state: string,
    public zip: string
  ) {}

  toString() {
    return `${this.street}, ${this.city}, ${this.state} ${this.zip}`;
  }
}

class Age {
  constructor(private value: number) {
    if (value < 18) {
      throw new ValidationError('Must be 18 or older');
    }
    if (value > 120) {
      throw new ValidationError('Invalid age');
    }
  }

  getValue() {
    return this.value;
  }
}

// Clean function signatures
function createUser(
  name: string,
  email: Email,
  age: Age,
  address: Address
) {
  // Validation already done by value objects
  return {
    name,
    email: email.toString(),
    age: age.getValue(),
    address: address.toString()
  };
}

function sendEmail(to: Email, from: Email, subject: string, body: string) {
  // Email validation already done
  // send email
}
```

**Improvements**:
- Validation centralized in value objects
- Type-safe domain modeling
- Reusable validation logic
- Self-documenting code

---

## 7. Long Parameter List

### Before

```typescript
function createInvoice(
  customerId,
  customerName,
  customerEmail,
  customerAddress,
  items,
  subtotal,
  tax,
  shipping,
  discount,
  total,
  paymentMethod,
  paymentStatus,
  dueDate,
  notes
) {
  // 14 parameters!
  return {
    customerId,
    customerName,
    customerEmail,
    customerAddress,
    items,
    subtotal,
    tax,
    shipping,
    discount,
    total,
    paymentMethod,
    paymentStatus,
    dueDate,
    notes
  };
}
```

**Problems**:
- 14 parameters (hard to remember order)
- Easy to pass wrong arguments
- Hard to add new parameters
- No clear grouping

### After

```typescript
interface Customer {
  id: string;
  name: string;
  email: string;
  address: string;
}

interface Payment {
  method: string;
  status: string;
  dueDate: Date;
}

interface InvoiceTotals {
  subtotal: number;
  tax: number;
  shipping: number;
  discount: number;
  total: number;
}

function createInvoice(
  customer: Customer,
  items: InvoiceItem[],
  totals: InvoiceTotals,
  payment: Payment,
  notes?: string
) {
  return {
    customer,
    items,
    ...totals,
    payment,
    notes
  };
}
```

**Improvements**:
- Grouped related parameters
- Self-documenting through types
- Easy to extend
- Optional parameters clear

---

## 8. Callback Hell (Pyramid of Doom)

### Before

```typescript
function processOrder(orderId, callback) {
  getOrder(orderId, (err, order) => {
    if (err) return callback(err);

    validateOrder(order, (err, valid) => {
      if (err) return callback(err);

      processPayment(order, (err, payment) => {
        if (err) return callback(err);

        updateInventory(order, (err, inventory) => {
          if (err) return callback(err);

          sendConfirmation(order, (err, sent) => {
            if (err) return callback(err);

            callback(null, { order, payment, inventory });
          });
        });
      });
    });
  });
}
```

**Problems**:
- Deeply nested (5 levels)
- Hard to follow control flow
- Error handling repeated
- Difficult to add steps

### After

```typescript
async function processOrder(orderId) {
  const order = await getOrder(orderId);
  await validateOrder(order);
  const payment = await processPayment(order);
  const inventory = await updateInventory(order);
  await sendConfirmation(order);

  return { order, payment, inventory };
}
```

**Improvements**:
- Linear, easy to read
- Natural error propagation
- Easy to add/remove steps
- Modern async/await syntax

---

## Quick Reference: Code Smell Patterns

| Smell | Red Flag | Solution |
|-------|----------|----------|
| Long Method | > 50 lines, complexity > 10 | Extract functions |
| Duplicate Code | Same logic in 3+ places | Extract to shared function |
| Magic Numbers | Unexplained constants | Named constants |
| Deep Nesting | > 4 levels of indentation | Early returns, extract |
| God Class | > 10 methods, mixed concerns | Split by responsibility |
| Long Parameters | > 4 parameters | Parameter object |
| Primitive Obsession | Primitives for domain concepts | Value objects |
| Callback Hell | Nested callbacks | async/await |
