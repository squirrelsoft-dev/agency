# Specialist Selection: Skill Activation

Activate appropriate technical skills based on detected technologies in the plan.

## Purpose

Skills provide deep technical expertise for specific technologies, frameworks, and patterns. Activate relevant skills to enhance specialist capabilities.

---

## When to Activate Skills

**ALWAYS check** for skill activation opportunities after specialist selection but before implementation.

**Timing**:
1. Parse plan for technology keywords
2. Select specialists based on keyword analysis
3. **Activate relevant skills** before spawning specialists
4. Specialists then have enhanced technical knowledge

---

## Skill Detection Algorithm

### 1. Scan Plan for Technology Keywords

**Frontend Technology Skills**:

**Next.js Skill** (`nextjs-16-expert`):
- Keywords: "Next.js", "Next", "App Router", "Server Components", "Server Actions"
- Version indicators: "Next.js 14", "Next.js 15", "Next.js 16"
- Patterns: "use client", "use server", "getServerSideProps"
- **Activate if**: 2+ Next.js-specific keywords found

**React Skill** (`react-expert`):
- Keywords: "React", "JSX", "hooks", "useState", "useEffect", "Context"
- Patterns: "React component", "React hooks", "React context"
- **Activate if**: 3+ React keywords found AND no Next.js keywords

**TypeScript Skill** (`typescript-5-expert`):
- Keywords: "TypeScript", "type", "interface", "generic", "enum"
- Version indicators: "TypeScript 5", "TS 5.x"
- Patterns: "type safety", "type inference", "type guards"
- **Activate if**: 2+ TypeScript keywords found OR project uses TypeScript

**Tailwind Skill** (`tailwind-expert`):
- Keywords: "Tailwind", "Tailwind CSS", "utility classes", "responsive design"
- Patterns: "className=", "dark mode", "responsive breakpoints"
- **Activate if**: 2+ Tailwind keywords found

**Backend Technology Skills**:

**API Design Skill** (`api-design-expert`):
- Keywords: "REST API", "GraphQL", "API design", "endpoint", "route"
- Patterns: "API contract", "OpenAPI", "API versioning"
- **Activate if**: 3+ API keywords found

**Database Skill** (`database-expert`):
- Keywords: "database", "SQL", "PostgreSQL", "MySQL", "MongoDB", "Prisma", "Drizzle"
- Patterns: "schema", "migration", "query optimization", "indexing"
- **Activate if**: 3+ database keywords found

**Authentication Skill** (`auth-expert`):
- Keywords: "authentication", "authorization", "JWT", "OAuth", "session"
- Patterns: "login", "register", "password", "token", "permissions"
- **Activate if**: 2+ auth keywords found

**Testing & Quality Skills**:

**Testing Skill** (`testing-expert`):
- Keywords: "test", "unit test", "integration test", "e2e", "Jest", "Vitest"
- Patterns: "test coverage", "TDD", "test suite"
- **Activate if**: 3+ testing keywords found OR coverage requirements mentioned

**Performance Skill** (`performance-expert`):
- Keywords: "performance", "optimization", "caching", "lazy loading", "bundle size"
- Patterns: "Core Web Vitals", "LCP", "FCP", "TTI"
- **Activate if**: 2+ performance keywords found OR performance targets mentioned

**DevOps & Infrastructure Skills**:

**Docker Skill** (`docker-expert`):
- Keywords: "Docker", "container", "Dockerfile", "docker-compose"
- Patterns: "containerization", "image", "volume"
- **Activate if**: 2+ Docker keywords found

**CI/CD Skill** (`cicd-expert`):
- Keywords: "CI/CD", "pipeline", "GitHub Actions", "deployment"
- Patterns: "continuous integration", "continuous deployment"
- **Activate if**: 2+ CI/CD keywords found

---

## Skill Activation Decision Matrix

### Frontend Developer Specialist

**Default Skills** (always active):
- Core JavaScript/TypeScript patterns
- Component architecture
- State management fundamentals

**Conditional Skills**:

| Detected Technology | Activate Skill | Priority |
|-------------------|---------------|----------|
| Next.js mentioned | `nextjs-16-expert` | HIGH |
| React (no Next.js) | `react-expert` | HIGH |
| TypeScript project | `typescript-5-expert` | HIGH |
| Tailwind CSS | `tailwind-expert` | MEDIUM |
| Performance targets | `performance-expert` | MEDIUM |
| Testing requirements | `testing-expert` | LOW |

**Example**:
```
Plan mentions: "Next.js 15", "Server Components", "TypeScript"

Activate for frontend-developer:
- ✅ nextjs-16-expert (HIGH - Next.js detected)
- ✅ typescript-5-expert (HIGH - TypeScript project)
- ❌ react-expert (Skip - Next.js already covers React)
```

### Backend Architect Specialist

**Default Skills**:
- Server architecture patterns
- Security fundamentals
- Error handling

**Conditional Skills**:

| Detected Technology | Activate Skill | Priority |
|-------------------|---------------|----------|
| REST/GraphQL API | `api-design-expert` | HIGH |
| Database work | `database-expert` | HIGH |
| Auth/AuthZ | `auth-expert` | HIGH |
| TypeScript backend | `typescript-5-expert` | MEDIUM |
| Testing | `testing-expert` | LOW |

**Example**:
```
Plan mentions: "REST API", "PostgreSQL", "Prisma", "JWT authentication"

Activate for backend-architect:
- ✅ api-design-expert (HIGH - REST API)
- ✅ database-expert (HIGH - PostgreSQL + Prisma)
- ✅ auth-expert (HIGH - JWT authentication)
- ✅ typescript-5-expert (MEDIUM - if backend uses TypeScript)
```

### DevOps Automator Specialist

**Default Skills**:
- Infrastructure as code
- Deployment strategies
- Monitoring basics

**Conditional Skills**:

| Detected Technology | Activate Skill | Priority |
|-------------------|---------------|----------|
| Docker/containers | `docker-expert` | HIGH |
| CI/CD pipeline | `cicd-expert` | HIGH |
| Cloud platform | `cloud-expert` | MEDIUM |
| Kubernetes | `kubernetes-expert` | MEDIUM |

**Example**:
```
Plan mentions: "Docker", "GitHub Actions", "deployment pipeline"

Activate for devops-automator:
- ✅ docker-expert (HIGH - Docker mentioned)
- ✅ cicd-expert (HIGH - GitHub Actions + pipeline)
```

### Mobile App Builder Specialist

**Default Skills**:
- Mobile UI/UX patterns
- Platform-specific patterns
- Performance for mobile

**Conditional Skills**:

| Detected Technology | Activate Skill | Priority |
|-------------------|---------------|----------|
| React Native | `react-native-expert` | HIGH |
| Expo | `expo-expert` | HIGH |
| TypeScript | `typescript-5-expert` | MEDIUM |
| Native modules | `native-modules-expert` | MEDIUM |

### AI Engineer Specialist

**Default Skills**:
- LLM integration patterns
- Prompt engineering
- AI SDK usage

**Conditional Skills**:

| Detected Technology | Activate Skill | Priority |
|-------------------|---------------|----------|
| Specific AI SDK | `ai-sdk-expert` | HIGH |
| Vector databases | `vector-db-expert` | MEDIUM |
| RAG patterns | `rag-expert` | MEDIUM |

---

## Skill Activation Syntax

Use the Skill tool to activate:

```bash
# Single skill activation
Skill tool with:
- skill_name: "nextjs-16-expert"
- reason: "Plan mentions Next.js 15 with Server Components and App Router"

# Multiple skills (separate calls in same message)
Skill tool with:
- skill_name: "nextjs-16-expert"
- reason: "Plan mentions Next.js 15"

Skill tool with:
- skill_name: "typescript-5-expert"
- reason: "Project uses TypeScript 5.x"

Skill tool with:
- skill_name: "tailwind-expert"
- reason: "Plan mentions Tailwind CSS for styling"
```

**Best Practice**: Activate all relevant skills in a single message (multiple Skill tool calls).

---

## Skill Activation Workflow

### Step 1: Parse Plan for Technologies

```
Scan plan for:
- Framework mentions (Next.js, React, etc.)
- Language versions (TypeScript 5, etc.)
- Libraries (Prisma, Tailwind, etc.)
- Patterns (Server Components, REST API, etc.)
- Tools (Docker, Jest, etc.)
```

### Step 2: Map Technologies to Skills

```
For each detected technology:
  Check skill detection matrix
  If threshold met → Add to activation list
  Prioritize: HIGH > MEDIUM > LOW
```

### Step 3: Activate Skills Before Specialist Spawn

```
BEFORE spawning specialist:
  Activate all HIGH priority skills
  Activate MEDIUM priority skills if relevant
  Skip LOW priority unless explicitly needed

THEN spawn specialist with context:
  "Skills activated: [list]
   These provide deep expertise for [technologies]
   Leverage these skills during implementation"
```

### Step 4: Document Activated Skills

```
In execution-state.json or plan:
  "skills_activated": [
    {
      "skill": "nextjs-16-expert",
      "priority": "HIGH",
      "reason": "Plan mentions Next.js 15 Server Components"
    },
    {
      "skill": "typescript-5-expert",
      "priority": "HIGH",
      "reason": "Project uses TypeScript 5.x"
    }
  ]
```

---

## Multi-Specialist Skill Activation

**When multiple specialists involved**, activate skills per specialist:

```
Backend Architect:
  Activate:
  - api-design-expert (API endpoints)
  - database-expert (PostgreSQL + Prisma)
  - auth-expert (JWT authentication)

Frontend Developer:
  Activate:
  - nextjs-16-expert (Next.js 15)
  - typescript-5-expert (TypeScript 5.x)
  - tailwind-expert (Tailwind CSS)

DevOps Automator:
  Activate:
  - docker-expert (containerization)
  - cicd-expert (GitHub Actions)
```

**Activation Timing**:
- Activate backend skills → Spawn backend-architect
- After backend completes → Activate frontend skills → Spawn frontend-developer
- After frontend completes → Activate devops skills → Spawn devops-automator

---

## Skill Combination Patterns

### Common Combinations

**Full-Stack Next.js Application**:
```
Frontend:
- nextjs-16-expert
- typescript-5-expert
- tailwind-expert

Backend:
- api-design-expert
- database-expert
- auth-expert
- typescript-5-expert (shared)
```

**React + REST API**:
```
Frontend:
- react-expert
- typescript-5-expert

Backend:
- api-design-expert
- database-expert
```

**Mobile + Backend**:
```
Mobile:
- react-native-expert
- expo-expert
- typescript-5-expert

Backend:
- api-design-expert
- auth-expert
```

**AI Integration**:
```
AI:
- ai-sdk-expert
- rag-expert

Backend:
- api-design-expert
- vector-db-expert

Frontend:
- react-expert
- typescript-5-expert
```

---

## Skill Priority Guidelines

### HIGH Priority (Always Activate)

Activate if:
- Core technology for the implementation
- Mentioned explicitly in plan
- Critical to success
- 2+ strong keyword matches

**Examples**:
- Next.js for a Next.js project
- Database skill for schema design
- Auth skill for authentication features

### MEDIUM Priority (Activate if Relevant)

Activate if:
- Supporting technology
- Enhances quality
- Mentioned in plan
- Improves implementation

**Examples**:
- Performance skill for optimization work
- Testing skill for test requirements
- Tailwind for styling work

### LOW Priority (Optional)

Activate if:
- Nice to have
- User explicitly requests
- Time permits
- Not critical to core functionality

**Examples**:
- Testing skill for basic implementation (not test-focused)
- Performance skill when no performance targets

---

## Avoiding Skill Overload

**Don't activate too many skills**:
- Maximum 3-4 skills per specialist
- Focus on HIGH priority
- Avoid redundant skills
- Skills should complement, not overlap

**Bad Example** (too many):
```
Activate for frontend-developer:
- nextjs-16-expert
- react-expert (REDUNDANT - Next.js includes React)
- typescript-5-expert
- tailwind-expert
- performance-expert
- testing-expert
(6 skills - too many, includes redundancy)
```

**Good Example**:
```
Activate for frontend-developer:
- nextjs-16-expert (core framework)
- typescript-5-expert (language)
- tailwind-expert (styling approach)
(3 skills - focused and complementary)
```

---

## Skill Activation Validation

Before activating, verify:

- ✅ Skill matches detected technology
- ✅ Technology actually used in plan
- ✅ Skill is appropriate for selected specialist
- ✅ Priority is HIGH or MEDIUM
- ✅ Not redundant with other skills
- ✅ Total skills per specialist ≤ 4

---

## Skill Activation Examples

### Example 1: Next.js Full-Stack App

**Plan excerpt**:
```
Build a user authentication system using Next.js 15 with Server Components,
TypeScript, Tailwind CSS, and PostgreSQL with Prisma.
```

**Technology Detection**:
- Next.js 15: ✅ nextjs-16-expert (HIGH)
- TypeScript: ✅ typescript-5-expert (HIGH)
- Tailwind CSS: ✅ tailwind-expert (MEDIUM)
- PostgreSQL + Prisma: ✅ database-expert (HIGH)
- Authentication: ✅ auth-expert (HIGH)

**Specialist Selection**:
- frontend-developer (Next.js, UI)
- backend-architect (PostgreSQL, auth)

**Skill Activation**:
```
Frontend Developer:
- Activate nextjs-16-expert (Next.js 15)
- Activate typescript-5-expert (TypeScript)
- Activate tailwind-expert (Tailwind CSS)

Backend Architect:
- Activate database-expert (PostgreSQL + Prisma)
- Activate auth-expert (authentication system)
- Activate typescript-5-expert (TypeScript backend)
```

### Example 2: Mobile App with API

**Plan excerpt**:
```
Create a React Native mobile app using Expo that consumes a REST API
for user data and authentication.
```

**Technology Detection**:
- React Native: ✅ react-native-expert (HIGH)
- Expo: ✅ expo-expert (HIGH)
- REST API: ✅ api-design-expert (HIGH)
- Authentication: ✅ auth-expert (MEDIUM)

**Specialist Selection**:
- mobile-app-builder (React Native app)
- backend-architect (REST API)

**Skill Activation**:
```
Mobile App Builder:
- Activate react-native-expert (React Native)
- Activate expo-expert (Expo framework)

Backend Architect:
- Activate api-design-expert (REST API)
- Activate auth-expert (authentication)
```

### Example 3: AI Feature Integration

**Plan excerpt**:
```
Add AI-powered recommendations using LLM embeddings and vector search,
integrate with existing Next.js frontend.
```

**Technology Detection**:
- LLM/AI: ✅ ai-sdk-expert (HIGH)
- Vector search: ✅ vector-db-expert (MEDIUM)
- Next.js: ✅ nextjs-16-expert (HIGH)

**Specialist Selection**:
- ai-engineer (AI integration)
- backend-architect (API for AI)
- frontend-developer (UI for recommendations)

**Skill Activation**:
```
AI Engineer:
- Activate ai-sdk-expert (LLM integration)
- Activate vector-db-expert (vector search)

Backend Architect:
- Activate api-design-expert (AI API endpoints)

Frontend Developer:
- Activate nextjs-16-expert (Next.js)
```

---

## Common Skill Combinations by Specialist

### frontend-developer
```
Common: nextjs-16-expert + typescript-5-expert + tailwind-expert
Alternative: react-expert + typescript-5-expert
With Performance: + performance-expert
```

### backend-architect
```
Common: api-design-expert + database-expert + auth-expert
TypeScript: + typescript-5-expert
With Testing: + testing-expert
```

### mobile-app-builder
```
Common: react-native-expert + expo-expert
With TypeScript: + typescript-5-expert
```

### devops-automator
```
Common: docker-expert + cicd-expert
With Cloud: + cloud-expert
With K8s: + kubernetes-expert
```

### ai-engineer
```
Common: ai-sdk-expert
With RAG: + rag-expert + vector-db-expert
With Backend: + api-design-expert
```

---

## Troubleshooting

### Skill Not Available

```
If skill detected but not available:
  Document in plan: "Note: [TECHNOLOGY] expertise would be beneficial"
  Proceed with specialist's default knowledge
  Consider adding skill in future
```

### Conflicting Skills

```
If skills conflict (e.g., react-expert + nextjs-16-expert):
  Choose more specific skill (nextjs-16-expert)
  Deactivate redundant skill (react-expert)
  Reason: Next.js includes React expertise
```

### Uncertain Technology

```
If technology mentioned but unclear:
  Ask user: "Plan mentions [TECHNOLOGY]. Is this used in implementation?"
  If yes → Activate skill
  If no → Skip activation
```

---

## Best Practices

1. **Activate Early**: Before spawning specialist, not during
2. **Be Selective**: 3-4 skills maximum per specialist
3. **Prioritize**: HIGH priority first, MEDIUM if relevant, skip LOW
4. **Avoid Redundancy**: Don't activate overlapping skills
5. **Document**: Record which skills activated and why
6. **Verify**: Check that technology is actually used in plan
7. **Specialist-Specific**: Only activate skills relevant to specialist's domain
