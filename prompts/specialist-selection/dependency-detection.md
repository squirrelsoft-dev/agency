# Specialist Selection: Dependency Detection

When multiple specialists are needed, determine execution strategy.

## Sequential Indicators

Execute specialists **sequentially** (one after another) if the plan mentions:

**Frontend depends on Backend**:
- "frontend needs backend API"
- "UI calls authentication endpoint"
- "component fetches data from API"
- "form submits to server"
- "dashboard displays database data"

**Mobile depends on Backend**:
- "mobile app consumes API"
- "native app calls GraphQL"
- "app syncs with server"

**Frontend/Mobile depends on AI**:
- "UI uses ML model predictions"
- "app displays AI recommendations"

**Any specialist depends on DevOps**:
- "requires deployment before testing"
- "needs infrastructure setup first"

## Parallel Indicators

Execute specialists **in parallel** (simultaneously) if the plan mentions:

**Independent Components**:
- "separate admin dashboard"
- "independent API changes"
- "standalone service"
- "isolated feature"

**No Data Flow**:
- "no shared interfaces"
- "different codebases"
- "separate repositories"

**Background Processing**:
- "background job"
- "async worker"
- "scheduled task"

## Execution Strategy Decision

```
IF sequential indicators found:
  Strategy: Sequential
  Order: Based on dependency chain
  Reason: [Specific dependency mentioned]

ELSE IF parallel indicators found:
  Strategy: Parallel
  Reason: [Independent work mentioned]
  Warning: Ensure no hidden dependencies

ELSE:
  Strategy: Sequential (safer default)
  Reason: Dependencies unclear, executing sequentially to avoid integration issues
```

## Dependency Chain Detection

**Typical chains**:
1. DevOps → Backend → Frontend/Mobile
2. Backend → AI (if AI needs data)
3. AI → Backend → Frontend (if backend integrates AI model)

**Analysis**:
- Scan plan for data flow diagrams
- Look for "after", "requires", "needs", "depends on" keywords
- Check for API contract definitions
- Identify shared interfaces
