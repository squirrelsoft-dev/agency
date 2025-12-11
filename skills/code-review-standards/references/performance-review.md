# Performance Review Guide

## Database Performance

### N+1 Query Problem

**Detecting N+1 Queries**:
```javascript
// ❌ N+1 Problem: 1 query + N queries
const getPosts = async () => {
  const posts = await Post.findAll(); // 1 query
  for (const post of posts) {
    post.author = await User.findById(post.authorId); // N queries!
    post.comments = await Comment.findAll({ postId: post.id }); // N more queries!
  }
  return posts;
};
// Total: 1 + 2N queries for N posts

// ✅ Fixed: Eager loading
const getPosts = async () => {
  return Post.findAll({
    include: [
      { model: User, as: 'author' },
      { model: Comment, as: 'comments' }
    ]
  });
};
// Total: 1 query with joins
```

**Sequelize Example**:
```javascript
// ❌ Bad: Lazy loading in loop
const users = await User.findAll();
for (const user of users) {
  const posts = await user.getPosts(); // N queries
}

// ✅ Good: Eager loading
const users = await User.findAll({
  include: [{ model: Post }]
});
```

**Prisma Example**:
```javascript
// ❌ Bad: Multiple queries
const users = await prisma.user.findMany();
const usersWithPosts = await Promise.all(
  users.map(async (user) => ({
    ...user,
    posts: await prisma.post.findMany({ where: { userId: user.id } })
  }))
);

// ✅ Good: Include relation
const users = await prisma.user.findMany({
  include: { posts: true }
});
```

### Query Optimization

**Use Indexes**:
```sql
-- ❌ Slow: No index on email
SELECT * FROM users WHERE email = 'user@example.com';

-- ✅ Fast: Index on email
CREATE INDEX idx_users_email ON users(email);
SELECT * FROM users WHERE email = 'user@example.com';
```

**Select Only Needed Fields**:
```javascript
// ❌ Bad: Select all fields
const users = await User.findAll();

// ✅ Good: Select specific fields
const users = await User.findAll({
  attributes: ['id', 'name', 'email']
});
```

**Limit Results**:
```javascript
// ❌ Bad: Return everything
const posts = await Post.findAll();

// ✅ Good: Paginate
const posts = await Post.findAll({
  limit: 20,
  offset: page * 20,
  order: [['createdAt', 'DESC']]
});
```

**Use Appropriate Joins**:
```javascript
// ❌ Bad: Loading unnecessary data
const posts = await Post.findAll({
  include: [
    { model: User, include: [{ model: Profile }] }, // Do we need profile?
    { model: Comment, include: [{ model: User }] }  // All comment users?
  ]
});

// ✅ Good: Only needed data
const posts = await Post.findAll({
  include: [
    { model: User, attributes: ['id', 'name'] }
  ]
});
```

### Connection Pooling

**Check For**:
- [ ] Connection pool configured
- [ ] Pool size appropriate
- [ ] Connections released
- [ ] Connection timeout set

```javascript
// ✅ Proper connection pooling
const pool = new Pool({
  host: 'localhost',
  database: 'myapp',
  max: 20, // Maximum connections
  min: 5,  // Minimum connections
  idle: 10000, // Idle timeout
  acquire: 30000, // Acquire timeout
  evict: 1000 // Eviction interval
});
```

## Caching Strategies

### When to Cache

**Good Candidates**:
- Expensive computations
- External API calls
- Database queries (read-heavy)
- Static content
- Session data

**Poor Candidates**:
- Frequently changing data
- User-specific data (unless user-keyed)
- Real-time data
- Small, fast queries

### Cache Layers

**Multi-level Caching**:
```javascript
// L1: Memory cache (fastest)
// L2: Redis cache (fast)
// L3: Database (slowest)

const getUser = async (userId) => {
  // L1: Check memory
  let user = memoryCache.get(`user:${userId}`);
  if (user) return user;

  // L2: Check Redis
  user = await redis.get(`user:${userId}`);
  if (user) {
    memoryCache.set(`user:${userId}`, user, { ttl: 60 });
    return JSON.parse(user);
  }

  // L3: Database
  user = await db.users.findById(userId);
  if (user) {
    redis.set(`user:${userId}`, JSON.stringify(user), 'EX', 300);
    memoryCache.set(`user:${userId}`, user, { ttl: 60 });
  }

  return user;
};
```

### Cache Invalidation

**Strategies**:

1. **Time-based (TTL)**:
```javascript
// ✅ Set expiration
cache.set('key', value, { ttl: 3600 }); // 1 hour
```

2. **Event-based**:
```javascript
// ✅ Invalidate on update
const updateUser = async (userId, data) => {
  await db.users.update(userId, data);
  cache.del(`user:${userId}`); // Invalidate cache
};
```

3. **Tag-based**:
```javascript
// ✅ Invalidate related caches
const updatePost = async (postId, data) => {
  await db.posts.update(postId, data);
  cache.delByTag(`post:${postId}`);
  cache.delByTag(`user:${data.authorId}:posts`);
};
```

### Cache Stampede Prevention

**Problem**: Cache expires, multiple requests hit database
**Solution**: Lock-based caching

```javascript
// ✅ Lock-based cache update
const locks = new Map();

const getCachedData = async (key, fetchFn) => {
  let data = await cache.get(key);
  if (data) return data;

  // Acquire lock
  if (locks.has(key)) {
    // Wait for lock to release
    await locks.get(key);
    return cache.get(key);
  }

  const lockPromise = (async () => {
    data = await fetchFn();
    await cache.set(key, data, { ttl: 300 });
    locks.delete(key);
    return data;
  })();

  locks.set(key, lockPromise);
  return lockPromise;
};
```

## Frontend Performance

### React Performance

**Unnecessary Re-renders**:
```javascript
// ❌ Bad: New function on every render
const UserList = ({ users }) => {
  return users.map(user => (
    <UserCard
      key={user.id}
      user={user}
      onClick={() => handleClick(user.id)} // New function every time!
    />
  ));
};

// ✅ Good: Memoized callback
const UserList = ({ users }) => {
  const handleClick = useCallback((userId) => {
    // Handle click
  }, []);

  return users.map(user => (
    <UserCard key={user.id} user={user} onClick={handleClick} />
  ));
};
```

**Expensive Calculations**:
```javascript
// ❌ Bad: Recalculates on every render
const Dashboard = ({ data }) => {
  const stats = calculateExpensiveStats(data); // Runs every render!
  return <StatsDisplay stats={stats} />;
};

// ✅ Good: Memoized
const Dashboard = ({ data }) => {
  const stats = useMemo(() => calculateExpensiveStats(data), [data]);
  return <StatsDisplay stats={stats} />;
};
```

**Component Memoization**:
```javascript
// ✅ Prevent re-render if props unchanged
const UserCard = React.memo(({ user, onClick }) => {
  return (
    <div onClick={() => onClick(user.id)}>
      {user.name}
    </div>
  );
}, (prevProps, nextProps) => {
  // Custom comparison
  return prevProps.user.id === nextProps.user.id;
});
```

### Virtual Scrolling

**Large Lists**:
```javascript
// ❌ Bad: Render 10,000 items
const UserList = ({ users }) => (
  <div>
    {users.map(user => <UserCard key={user.id} user={user} />)}
  </div>
);

// ✅ Good: Virtual scrolling
import { FixedSizeList } from 'react-window';

const UserList = ({ users }) => (
  <FixedSizeList
    height={600}
    itemCount={users.length}
    itemSize={50}
    width="100%"
  >
    {({ index, style }) => (
      <div style={style}>
        <UserCard user={users[index]} />
      </div>
    )}
  </FixedSizeList>
);
```

### Code Splitting

**Route-based Splitting**:
```javascript
// ✅ Lazy load routes
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./Dashboard'));
const Settings = lazy(() => import('./Settings'));

const App = () => (
  <Suspense fallback={<Loading />}>
    <Routes>
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/settings" element={<Settings />} />
    </Routes>
  </Suspense>
);
```

**Component-based Splitting**:
```javascript
// ✅ Lazy load heavy components
const Chart = lazy(() => import('./Chart'));

const Dashboard = () => (
  <Suspense fallback={<Skeleton />}>
    <Chart data={data} />
  </Suspense>
);
```

### Debouncing & Throttling

**Input Debouncing**:
```javascript
// ❌ Bad: API call on every keystroke
const SearchInput = () => {
  const [query, setQuery] = useState('');

  const handleChange = (e) => {
    setQuery(e.target.value);
    searchAPI(e.target.value); // Called on every keystroke!
  };

  return <input onChange={handleChange} />;
};

// ✅ Good: Debounced API call
import { debounce } from 'lodash';

const SearchInput = () => {
  const [query, setQuery] = useState('');

  const debouncedSearch = useMemo(
    () => debounce((value) => searchAPI(value), 500),
    []
  );

  const handleChange = (e) => {
    setQuery(e.target.value);
    debouncedSearch(e.target.value);
  };

  return <input value={query} onChange={handleChange} />;
};
```

**Scroll Throttling**:
```javascript
// ✅ Throttle scroll events
import { throttle } from 'lodash';

const ScrollTracker = () => {
  useEffect(() => {
    const handleScroll = throttle(() => {
      console.log('Scroll position:', window.scrollY);
    }, 200); // At most every 200ms

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);
};
```

## Asset Optimization

### Image Optimization

**Check For**:
- [ ] Appropriate image formats (WebP, AVIF)
- [ ] Responsive images (srcset)
- [ ] Lazy loading
- [ ] Compression
- [ ] CDN usage

```javascript
// ✅ Optimized images
import Image from 'next/image';

const UserAvatar = ({ src, alt }) => (
  <Image
    src={src}
    alt={alt}
    width={200}
    height={200}
    loading="lazy"
    placeholder="blur"
  />
);
```

### Bundle Size

**Check For**:
- [ ] Tree shaking enabled
- [ ] Unused dependencies removed
- [ ] Heavy libraries replaced (lodash → lodash-es)
- [ ] Code splitting used
- [ ] Compression enabled (gzip, brotli)

**Analyze Bundle**:
```bash
# Webpack Bundle Analyzer
npm install --save-dev webpack-bundle-analyzer

# Add to webpack config
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
plugins: [new BundleAnalyzerPlugin()]

# Run build and analyze
npm run build
```

**Reduce Bundle Size**:
```javascript
// ❌ Bad: Import entire library
import _ from 'lodash';

// ✅ Good: Import only what you need
import debounce from 'lodash/debounce';

// ✅ Even better: Use native methods
const unique = [...new Set(array)]; // Instead of _.uniq
```

## API Performance

### Response Compression

```javascript
// ✅ Enable compression
const compression = require('compression');
app.use(compression());
```

### Pagination

```javascript
// ❌ Bad: Return all results
app.get('/api/posts', async (req, res) => {
  const posts = await Post.findAll(); // Could be thousands!
  res.json(posts);
});

// ✅ Good: Paginated
app.get('/api/posts', async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const offset = (page - 1) * limit;

  const { count, rows } = await Post.findAndCountAll({
    limit,
    offset,
    order: [['createdAt', 'DESC']]
  });

  res.json({
    posts: rows,
    total: count,
    page,
    totalPages: Math.ceil(count / limit)
  });
});
```

### Field Selection

```javascript
// ✅ Allow clients to select fields
app.get('/api/users/:id', async (req, res) => {
  const fields = req.query.fields?.split(',') || ['id', 'name', 'email'];

  const user = await User.findById(req.params.id, {
    attributes: fields
  });

  res.json(user);
});

// Usage: /api/users/123?fields=id,name,email
```

### Response Caching

```javascript
// ✅ Cache-Control headers
app.get('/api/static-data', (req, res) => {
  res.set('Cache-Control', 'public, max-age=3600'); // 1 hour
  res.json(data);
});

app.get('/api/user-data', (req, res) => {
  res.set('Cache-Control', 'private, max-age=300'); // 5 minutes
  res.json(data);
});
```

## Memory Management

### Memory Leaks

**Common Causes**:
1. Event listeners not removed
2. Timers not cleared
3. Closures holding references
4. Large data structures not garbage collected

**Detection**:
```javascript
// ✅ Proper cleanup in React
useEffect(() => {
  const subscription = subscribe();
  const timer = setInterval(() => {}, 1000);

  return () => {
    subscription.unsubscribe(); // Clean up subscription
    clearInterval(timer); // Clear timer
  };
}, []);
```

**Node.js Memory Monitoring**:
```javascript
// Monitor memory usage
setInterval(() => {
  const usage = process.memoryUsage();
  console.log({
    rss: `${Math.round(usage.rss / 1024 / 1024)}MB`,
    heapUsed: `${Math.round(usage.heapUsed / 1024 / 1024)}MB`,
    heapTotal: `${Math.round(usage.heapTotal / 1024 / 1024)}MB`
  });
}, 60000);
```

### Stream Processing

**Large Files**:
```javascript
// ❌ Bad: Load entire file into memory
const fs = require('fs');
const data = fs.readFileSync('large-file.json'); // Memory spike!
const json = JSON.parse(data);

// ✅ Good: Stream processing
const fs = require('fs');
const readline = require('readline');

const stream = fs.createReadStream('large-file.jsonl');
const rl = readline.createInterface({ input: stream });

rl.on('line', (line) => {
  const record = JSON.parse(line);
  processRecord(record);
});
```

## Performance Monitoring

### Metrics to Track

**Backend**:
- Response time (p50, p95, p99)
- Request rate
- Error rate
- Database query time
- Cache hit rate
- Memory usage
- CPU usage

**Frontend**:
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Time to Interactive (TTI)
- Cumulative Layout Shift (CLS)
- First Input Delay (FID)

### Performance Budgets

**Set Limits**:
```json
{
  "budgets": [
    {
      "resourceSizes": [
        { "resourceType": "script", "budget": 300 },
        { "resourceType": "style", "budget": 100 },
        { "resourceType": "image", "budget": 500 }
      ],
      "resourceCounts": [
        { "resourceType": "script", "budget": 10 },
        { "resourceType": "third-party", "budget": 5 }
      ]
    }
  ]
}
```

### Profiling

**React DevTools Profiler**:
```javascript
import { Profiler } from 'react';

const onRenderCallback = (id, phase, actualDuration) => {
  console.log(`${id} (${phase}) took ${actualDuration}ms`);
};

<Profiler id="Dashboard" onRender={onRenderCallback}>
  <Dashboard />
</Profiler>
```

**Node.js Profiling**:
```bash
# CPU profiling
node --prof app.js
node --prof-process isolate-*.log > profile.txt

# Heap snapshot
node --inspect app.js
# Chrome DevTools > Memory > Take snapshot
```

## Performance Review Checklist

**Database**:
- [ ] No N+1 queries
- [ ] Indexes on frequently queried columns
- [ ] Pagination implemented
- [ ] Connection pooling configured
- [ ] Query results limited

**Caching**:
- [ ] Caching strategy appropriate
- [ ] Cache invalidation implemented
- [ ] TTL set appropriately
- [ ] Cache stampede prevented

**Frontend**:
- [ ] No unnecessary re-renders
- [ ] Expensive calculations memoized
- [ ] Code splitting used
- [ ] Images optimized
- [ ] Lazy loading implemented

**API**:
- [ ] Compression enabled
- [ ] Pagination available
- [ ] Response caching configured
- [ ] Field selection supported

**Memory**:
- [ ] No memory leaks
- [ ] Event listeners cleaned up
- [ ] Timers cleared
- [ ] Streams used for large data

## Performance Testing

**Load Testing**:
```bash
# Artillery
npm install -g artillery
artillery quick --count 100 --num 10 http://localhost:3000

# Apache Bench
ab -n 1000 -c 10 http://localhost:3000/api/users
```

**Lighthouse CI**:
```yaml
# .lighthouserc.json
{
  "ci": {
    "collect": {
      "numberOfRuns": 3
    },
    "assert": {
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.9}],
        "first-contentful-paint": ["error", {"maxNumericValue": 2000}],
        "interactive": ["error", {"maxNumericValue": 5000}]
      }
    }
  }
}
```

## References

- [Web Vitals](https://web.dev/vitals/)
- [React Performance](https://react.dev/learn/render-and-commit)
- [Database Performance Best Practices](https://use-the-index-luke.com/)
- [Frontend Performance Checklist](https://github.com/thedaviddias/Front-End-Performance-Checklist)
