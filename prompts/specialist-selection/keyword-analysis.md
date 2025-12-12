# Specialist Selection: Keyword Analysis

Scan the plan/issue for technology keywords to determine the best specialist(s):

## Frontend Specialist (`frontend-developer`)

**Keywords**:
- React, Vue, Angular, Svelte
- Next.js, Remix, Gatsby
- TypeScript, JavaScript, JSX, TSX
- Tailwind, CSS, styled-components
- shadcn, Radix UI, Headless UI
- Component, UI, UX, design system
- Form, button, layout, modal
- Animation, transition, responsive

**Scoring**: +0.5 per keyword match (Score > 2.0 → Specialist needed)

---

## Backend Specialist (`backend-architect`)

**Keywords**:
- API, REST, GraphQL, tRPC
- Database, SQL, PostgreSQL, MySQL, MongoDB
- Prisma, Drizzle, TypeORM
- Authentication, authorization, JWT
- Microservices, serverless
- Node.js server, Express, Fastify
- Middleware, endpoint, route
- Schema, migration, query

**Scoring**: +0.5 per keyword match (Score > 2.0 → Specialist needed)

---

## Mobile Specialist (`mobile-app-builder`)

**Keywords**:
- React Native, Expo
- iOS, Android, mobile
- SwiftUI, Kotlin, Flutter
- Mobile app, native
- Touch, gesture, navigation
- Push notification, deep linking

**Scoring**: +0.5 per keyword match (Score > 2.0 → Specialist needed)

---

## AI/ML Specialist (`ai-engineer`)

**Keywords**:
- Machine learning, ML, AI
- LLM, embeddings, vector database
- TensorFlow, PyTorch, scikit-learn
- Mastra, Pixeltable, AI SDK
- Model training, inference, RAG
- Prompt engineering, completion
- Semantic search, similarity

**Scoring**: +0.5 per keyword match (Score > 2.0 → Specialist needed)

---

## DevOps Specialist (`devops-automator`)

**Keywords**:
- Docker, container, Kubernetes
- CI/CD, pipeline, GitHub Actions
- Deployment, infrastructure
- AWS, GCP, Azure, cloud
- Terraform, Ansible, automation
- Monitoring, logging, metrics

**Scoring**: +0.5 per keyword match (Score > 2.0 → Specialist needed)

---

## Senior Developer (`senior-developer`)

**Default Specialist**: Use when:
- Laravel, Livewire, FluxUI mentioned
- Advanced CSS, Three.js mentioned
- Complex integrations needed
- OR if no clear specialty matches (total score < 2.0 for all specialists)
- OR if multiple specialties have similar scores (within 1.0 of each other)

---

## Multi-Specialist Detection

**When multiple specialists score > 2.0**:
1. List all specialists with scores
2. Check for dependencies (see dependency-detection.md)
3. Recommend execution strategy (sequential vs parallel)
4. Get user confirmation
