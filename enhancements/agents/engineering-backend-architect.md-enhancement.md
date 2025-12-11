# Agent Enhancement: Backend Architect

## Current State

**File**: `engineering/engineering-backend-architect.md`
**Name**: `Backend Architect`
**Description**: `Senior backend architect specializing in scalable system design, database architecture, API development, and cloud infrastructure. Builds robust, secure, performant server-side applications and microservices`

## Proposed Changes

### Better Name
**Proposed**: `engineering-backend-systems-architect`
**Rationale**: Adds "systems" to emphasize the architectural scope beyond just backend code.

### Better Description
**Proposed**: `Designs scalable backend systems, database architectures, and API strategies for high-performance applications. Specializes in microservices, data schema design, ETL pipelines, and cloud infrastructure with focus on security and reliability. Use when architecting backend systems, designing databases, or building scalable APIs.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Implements backend systems and API endpoints
- `/agency:plan` - Creates system architecture and database design docs
- `/agency:optimize` - Optimizes database queries and API performance
- `/agency:test` - Creates backend testing strategies and load tests
- `/agency:document` - Generates API documentation and architecture specs
- `/agency:review` - Reviews backend code for security and scalability
- `/agency:refactor` - Refactors backends for improved architecture

## Enhancement Recommendations

### Capability Enhancements
- **API design automation**: OpenAPI/Swagger spec generation
- **Database migration management**: Schema versioning and migration strategies
- **Performance profiling**: Query analysis and optimization recommendations
- **Security scanning**: Automated vulnerability detection (SQL injection, etc.)
- **Load testing automation**: Artillery, k6 test generation
- **Infrastructure as code**: Terraform, Pulumi for reproducible infrastructure
- **Event-driven architecture**: Message queue and event streaming patterns
- **Cache strategy optimization**: Redis, Memcached implementation patterns

### Skill References
Should reference these workflow skills when available:
- `prisma-latest-expert` - For modern ORM patterns
- `drizzle-0-expert` - For type-safe SQL
- `supabase-latest-expert` - For backend-as-a-service integration
- `nextjs-16-expert` - For Next.js API routes and server actions
- `api-design-patterns` - For RESTful and GraphQL best practices
- `database-optimization` - For query and schema optimization

### Tool Access
Current tools seem appropriate, but consider adding:
- **Database tools**: Direct database query and analysis capabilities
- **API testing tools**: Automated endpoint testing
- **Performance profiling tools**: Query and application profiling
- **Security scanning tools**: Automated vulnerability assessment
- **Load testing tools**: Performance testing under load

### Quality Improvements
- Add specific patterns for different data consistency requirements (eventual vs. strong)
- Include real-world scalability examples with numbers (requests/sec, data volume)
- Provide security checklist for different attack vectors
- Add database indexing strategies for different query patterns
- Include API versioning strategies and backwards compatibility guidelines
- Provide caching decision tree (when to cache, what layer, what strategy)
- Add microservices communication patterns (sync vs. async, REST vs. gRPC)
- Include database sharding and partitioning strategies
- Provide disaster recovery and backup automation patterns
- Add observability and monitoring best practices

## Implementation Priority
**Priority**: High
**Rationale**: Backend architecture is foundational for scalable applications. Critical for system reliability and performance. Should coordinate closely with frontend, DevOps, and database engineers.
