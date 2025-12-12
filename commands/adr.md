---
description: Create Architecture Decision Records (ADR) documenting technical decisions
argument-hint: decision topic or title
allowed-tools: Read, Write, Edit, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion
---

# Create Architecture Decision Record: $ARGUMENTS

Document architectural decisions with context, rationale, consequences, and alternatives.

## Your Mission

Create ADR for: **$ARGUMENTS**

Generate comprehensive Architecture Decision Record:
- Context and problem statement
- Decision made and rationale
- Consequences (positive, negative, neutral)
- Alternatives considered
- Implementation guidance

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

<!-- Component: prompts/specialist-selection/skill-activation.md -->

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

This skill contains critical orchestration patterns, agent selection guidelines, and workflow strategies you MUST follow.

Also activate the ADR writing skill if available:
```
Use the Skill tool to activate: adr-writing
```

**Note**: See `prompts/specialist-selection/skill-activation.md` for detailed skill activation patterns and technology detection rules.

### 2. ADR Writing Principles

**ALWAYS**:
- Focus on "why" not "what" (decision rationale is key)
- Document alternatives considered (shows thoughtful analysis)
- Be honest about trade-offs (both benefits and costs)
- Keep it concise (1-2 pages ideal)
- Use clear, jargon-free language

**NEVER**:
- Skip the alternatives section (critical for decision quality)
- Make decisions in isolation (involve stakeholders)
- Hide negative consequences (transparency is crucial)
- Include implementation details (separate from architecture decision)

### 3. Use TodoWrite Throughout

Track ADR creation progress with TodoWrite for transparency.

---

## Phase 0: Project Context Detection (1-2 min)

<!-- Component: prompts/context/framework-detection.md -->
<!-- Component: prompts/context/database-detection.md -->

Quickly gather project context to inform the ADR.

### Detect Framework/Architecture

Use the framework detection algorithm from `prompts/context/framework-detection.md`:

```bash
# Execute detection in order, return first match
if test -f next.config.js || test -f next.config.mjs || test -f next.config.ts; then
  FRAMEWORK="Next.js"
elif test -f manage.py; then
  FRAMEWORK="Django"
elif grep -q "fastapi" requirements.txt 2>/dev/null; then
  FRAMEWORK="FastAPI"
elif grep -q "flask" requirements.txt 2>/dev/null; then
  FRAMEWORK="Flask"
# ... (see prompts/context/framework-detection.md for complete algorithm)
fi
```

### Detect Current Architecture

Use the database detection algorithm from `prompts/context/database-detection.md`:

```bash
# Check for ORM/database tools
if grep -q '"@prisma/client"' package.json 2>/dev/null; then
  ORM="Prisma"
  DB=$(grep 'provider =' prisma/schema.prisma | awk '{print $3}' | tr -d '"')
elif grep -q '"drizzle-orm"' package.json 2>/dev/null; then
  ORM="Drizzle ORM"
elif grep -q '"@supabase/supabase-js"' package.json 2>/dev/null; then
  ORM="Supabase Client"
  DB="PostgreSQL"
# ... (see prompts/context/database-detection.md for complete algorithm)
fi
```

**Authentication, State Management, Deployment**: Use similar detection patterns from context components.

**Use this context to**:
- Understand existing architecture patterns
- Identify related decisions
- Suggest appropriate alternatives
- Tailor recommendations to stack

**See**: `prompts/context/framework-detection.md`, `prompts/context/database-detection.md` for comprehensive detection algorithms.

---

## Phase 1: Decision Context Analysis (3-5 min)

### Parse Decision Topic

Analyze `$ARGUMENTS` to understand what decision needs documentation:

**Common Decision Types**:
- **Database Choice**: PostgreSQL, MongoDB, MySQL, Supabase
- **Authentication Strategy**: NextAuth, Clerk, Auth0, custom
- **State Management**: Redux, Zustand, Context, Jotai
- **API Design**: REST, GraphQL, tRPC, gRPC
- **Deployment Architecture**: Serverless, containers, traditional hosting
- **Frontend Framework**: React, Vue, Svelte, solid
- **Styling Approach**: Tailwind, CSS Modules, Styled Components
- **Testing Strategy**: Jest, Vitest, Playwright, Cypress
- **Monorepo Strategy**: Turborepo, Nx, Lerna
- **Package Manager**: npm, pnpm, yarn

### Create Todo List for ADR Creation

<!-- Component: prompts/progress/todo-initialization.md -->

Use TodoWrite to create tracking (see `prompts/progress/todo-initialization.md` for format guidelines):

```javascript
TodoWrite({
  todos: [
    {
      content: "Analyze decision context and problem",
      status: "in_progress",
      activeForm: "Analyzing decision context and problem"
    },
    {
      content: "Research current architecture",
      status: "pending",
      activeForm: "Researching current architecture"
    },
    {
      content: "Identify alternatives",
      status: "pending",
      activeForm: "Identifying alternatives"
    },
    {
      content: "Draft ADR with specialist input",
      status: "pending",
      activeForm: "Drafting ADR with specialist input"
    },
    {
      content: "Review and refine ADR",
      status: "pending",
      activeForm: "Reviewing and refining ADR"
    },
    {
      content: "Publish ADR",
      status: "pending",
      activeForm: "Publishing ADR"
    }
  ]
});
```

### Check for Existing ADRs

```bash
# Check if ADR directory exists
if [ -d "docs/adr" ] || [ -d "docs/architecture/decisions" ]; then
  ADR_DIR=$([ -d "docs/adr" ] && echo "docs/adr" || echo "docs/architecture/decisions")
  echo "Found existing ADR directory: $ADR_DIR"

  # Count existing ADRs
  ADR_COUNT=$(find "$ADR_DIR" -name "*.md" | wc -l)
  echo "Existing ADRs: $ADR_COUNT"

  # Get next ADR number
  NEXT_NUMBER=$(printf "%04d" $((ADR_COUNT + 1)))
else
  # Create ADR directory
  mkdir -p docs/adr
  ADR_DIR="docs/adr"
  NEXT_NUMBER="0001"
fi

echo "Next ADR number: $NEXT_NUMBER"
```

### Get Decision Details from User

Use AskUserQuestion to gather key information:

```
Question: "What is the main problem or need driving this architectural decision?"
Options:
  - "Performance issues need to be addressed"
  - "New feature requires architectural changes"
  - "Technical debt needs to be resolved"
  - "Scaling requirements have changed"
  - "Team productivity needs improvement"
```

```
Question: "Has a decision already been made, or are we evaluating options?"
Options:
  - "Decision made - document the rationale"
  - "Evaluating options - need analysis and recommendation"
```

```
Question: "Who are the key stakeholders for this decision?"
Options:
  - "Engineering team"
  - "Product and engineering"
  - "Full leadership team"
  - "Engineering + DevOps"
```

Mark todo #1 as completed.

---

## Phase 2: Research Current Architecture (5-10 min)

Mark todo #2 as in_progress.

### Analyze Existing Implementation

**Find relevant files**:
```bash
# Based on decision topic, find related files
case "$ARGUMENTS" in
  *database*|*db*|*data*)
    find . -name "*schema*" -o -name "*model*" -o -name "*migration*" | \
      grep -v "node_modules" > .agency/adr/related-files.txt
    ;;
  *auth*|*login*)
    find . -name "*auth*" -o -name "*login*" -o -name "*session*" | \
      grep -v "node_modules" > .agency/adr/related-files.txt
    ;;
  *api*|*endpoint*)
    find . -name "*api*" -o -name "*route*" -o -name "*controller*" | \
      grep -v "node_modules" > .agency/adr/related-files.txt
    ;;
  *state*|*store*)
    find . -name "*store*" -o -name "*state*" -o -name "*context*" | \
      grep -v "node_modules" > .agency/adr/related-files.txt
    ;;
esac
```

### Understand Current Pain Points

```bash
# Search for relevant issues/comments in code
grep -r "TODO\|FIXME\|XXX\|HACK" --include="*.ts" --include="*.js" . | \
  grep -i "$ARGUMENTS" | \
  grep -v "node_modules" > .agency/adr/pain-points.txt || true

# Check git history for related changes
git log --all --oneline --grep="$ARGUMENTS" | head -20 > .agency/adr/git-history.txt || true
```

Mark todo #2 as completed.

---

## Phase 3: Identify Alternatives (10-15 min)

Mark todo #3 as in_progress.

### Research Available Options

Spawn a research agent to identify alternatives:

```
Task: Research architectural alternatives

Agent: Backend Architect or Senior Developer

Context:
- Decision topic: $ARGUMENTS
- Current architecture: [detected stack]
- Problem statement: [from user input]

Instructions:
Research and document 3-4 viable alternatives for this architectural decision.

For each alternative, provide:

1. **Name**: Clear name of the approach/technology
2. **Description**: What it is and how it works (2-3 sentences)
3. **Pros**:
   - Benefit 1 (specific and measurable)
   - Benefit 2
   - Benefit 3
4. **Cons**:
   - Drawback 1 (specific and measurable)
   - Drawback 2
   - Drawback 3
5. **Fit for Our Use Case**: How well it addresses our specific needs (1-2 sentences)
6. **Migration Effort**: LOW/MEDIUM/HIGH (with justification)
7. **Team Expertise**: Do we have experience with this? (YES/NO/PARTIAL)
8. **Community/Support**: Maturity, documentation, ecosystem
9. **Cost**: Licensing, hosting, operational costs

Examples of alternatives to consider:

**For Database Decision**:
- PostgreSQL (relational, ACID compliance, mature)
- MongoDB (document store, flexible schema)
- Supabase (PostgreSQL + real-time + auth)
- PlanetScale (serverless MySQL, branching)

**For Authentication**:
- NextAuth.js (open source, flexible)
- Clerk (managed, great DX)
- Auth0 (enterprise, comprehensive)
- Supabase Auth (integrated with database)

**For State Management**:
- Zustand (minimal, simple)
- Redux Toolkit (powerful, ecosystem)
- Jotai (atomic, React Suspense)
- TanStack Query (server state focus)

**For API Design**:
- REST (standard, widely understood)
- GraphQL (flexible, over/under-fetching)
- tRPC (type-safe, end-to-end)
- gRPC (high performance, binary)

Save research to .agency/adr/alternatives-research.md
```

**Wait for research to complete.**

### Compare Alternatives in Matrix

Create comparison matrix:

```markdown
# Alternatives Comparison

| Criteria | Alternative 1 | Alternative 2 | Alternative 3 | Alternative 4 |
|----------|--------------|---------------|---------------|---------------|
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Developer Experience** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Scalability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Cost** | $ | $$$ | $$ | $ |
| **Migration Effort** | HIGH | LOW | MEDIUM | MEDIUM |
| **Team Expertise** | YES | NO | PARTIAL | YES |
| **Community Support** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Maintenance** | LOW | MEDIUM | LOW | MEDIUM |
| **Vendor Lock-in** | NONE | HIGH | LOW | MEDIUM |
```

Mark todo #3 as completed.

---

## Phase 4: Draft ADR (15-20 min)

Mark todo #4 as in_progress.

### Determine ADR Number and Slug

```bash
# Create slug from decision title
SLUG=$(echo "$ARGUMENTS" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

# Full ADR filename
ADR_FILE="$ADR_DIR/ADR-${NEXT_NUMBER}-${SLUG}.md"

echo "Creating ADR: $ADR_FILE"
```

### Generate ADR Content

Spawn an architecture specialist to draft the ADR:

```
Task: Draft Architecture Decision Record

Agent: Backend Architect or ArchitectUX

Context:
- Decision topic: $ARGUMENTS
- ADR number: $NEXT_NUMBER
- Current architecture: [detected stack]
- Alternatives researched: [from Phase 3]
- User input: [problem statement, stakeholders]

Instructions:
Create a comprehensive ADR following this template:

# ADR-[NUMBER]: [Title]

**Date**: [YYYY-MM-DD]
**Status**: [Proposed / Accepted / Deprecated / Superseded by ADR-XXX]
**Deciders**: [List of people involved in this decision]
**Technical Story**: [Link to GitHub issue, Jira ticket, or description]

---

## Context and Problem Statement

[Describe the context and problem statement]

**Questions we're trying to answer**:
- [Question 1]
- [Question 2]
- [Question 3]

**Forces at play**:
- [Force 1: Technical consideration]
- [Force 2: Business requirement]
- [Force 3: Team constraint]
- [Force 4: Time/resource limitation]

**Success Criteria**:
- [Measurable criterion 1]
- [Measurable criterion 2]
- [Measurable criterion 3]

---

## Decision

[Clear, concise statement of the decision made]

**We have decided to [DECISION] because [PRIMARY REASON].**

### Why This Decision?

[Elaborate on the rationale - 2-3 paragraphs]

### Key Drivers

1. **[Driver 1]**: [Why this mattered]
2. **[Driver 2]**: [Why this mattered]
3. **[Driver 3]**: [Why this mattered]

---

## Consequences

### Positive Consequences

✅ **[Benefit 1]**: [Description with impact]

✅ **[Benefit 2]**: [Description with impact]

✅ **[Benefit 3]**: [Description with impact]

### Negative Consequences

❌ **[Drawback 1]**: [Description with mitigation strategy]

❌ **[Drawback 2]**: [Description with mitigation strategy]

### Neutral Consequences

➖ **[Implication 1]**: [Description of side effect]

➖ **[Implication 2]**: [Description of side effect]

### Risks and Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | MEDIUM | HIGH | [How to mitigate] |
| [Risk 2] | LOW | MEDIUM | [How to mitigate] |

---

## Alternatives Considered

### Alternative 1: [Name]

**Description**: [What it is]

**Pros**:
- [Pro 1]
- [Pro 2]
- [Pro 3]

**Cons**:
- [Con 1]
- [Con 2]
- [Con 3]

**Why Rejected**: [Specific reason this wasn't chosen]

---

### Alternative 2: [Name]

[Same structure as Alternative 1]

---

### Alternative 3: [Name]

[Same structure as Alternative 1]

---

## Comparison Matrix

| Criterion | Selected Option | Alternative 1 | Alternative 2 | Alternative 3 |
|-----------|----------------|---------------|---------------|---------------|
| Performance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| DX | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Cost | $ | $$$ | $$ | $ |
| Migration | MEDIUM | HIGH | LOW | MEDIUM |
| Expertise | YES | NO | PARTIAL | YES |

---

## Implementation Notes

### Prerequisites

- [Prerequisite 1]
- [Prerequisite 2]

### Implementation Steps

1. **[Phase 1]**: [Description]
   - Task 1
   - Task 2

2. **[Phase 2]**: [Description]
   - Task 1
   - Task 2

3. **[Phase 3]**: [Description]
   - Task 1
   - Task 2

### Migration Path (if applicable)

[For decisions that require migrating from existing approach]

```typescript
// Example migration code or pseudocode
```

### Configuration

[Any configuration changes needed]

```yaml
# Example configuration
```

### Testing Strategy

- [How to verify the decision is working]
- [What tests need to be added]

---

## Related Decisions

- [ADR-XXX]: [Related decision 1]
- [ADR-YYY]: [Related decision 2]

**Supersedes**: [ADR-ZZZ if this replaces a previous decision]

**Superseded by**: [ADR-AAA if this decision has been replaced]

---

## References

- [Link to documentation]
- [Link to research/article]
- [Link to benchmark/comparison]
- [Link to related discussion]

---

## Notes

[Any additional notes, future considerations, or open questions]

### Future Considerations

- [Thing to revisit in 6 months]
- [Potential improvement after adoption]

### Open Questions

- [Question that needs answering later]
- [Uncertainty to monitor]

---

**Review Date**: [Date to review this decision, typically 6-12 months]

**Last Updated**: [YYYY-MM-DD]

Save ADR to: $ADR_FILE
```

**Wait for the ADR to be drafted.**

Mark todo #4 as completed.

---

## Phase 5: Review and Refine ADR (5-10 min)

Mark todo #5 as in_progress.

### Spawn Review Agent

```
Task: Review Architecture Decision Record

Agent: Backend Architect or Senior Developer

Context:
- ADR file: $ADR_FILE
- Decision topic: $ARGUMENTS

Instructions:
Review the ADR for:

1. **Clarity**:
   - Is the problem statement clear?
   - Is the decision stated concisely?
   - Are the consequences well explained?

2. **Completeness**:
   - Are all major alternatives documented?
   - Are trade-offs honestly represented?
   - Are implementation notes sufficient?

3. **Accuracy**:
   - Is technical information correct?
   - Are the pros/cons realistic?
   - Are the migration steps feasible?

4. **Usefulness**:
   - Will this help future developers understand the decision?
   - Is there enough context for someone unfamiliar with the project?
   - Are references helpful and accessible?

Provide specific feedback on:
- Missing information
- Unclear sections
- Technical inaccuracies
- Suggestions for improvement

Save feedback to .agency/adr/review-feedback.md
```

**Wait for review to complete.**

### Incorporate Feedback

Based on reviewer feedback, update the ADR:

```bash
# Read the ADR
Read "$ADR_FILE"

# Make necessary updates using Edit tool
# Fix any issues identified in review
```

### Final User Review

Present the ADR to the user for approval:

```
AskUserQuestion:
  Question: "ADR draft is complete. Would you like to review before publishing?"
  Options:
    - "Approve and publish"
    - "Request changes"
    - "Review the draft first"
```

Mark todo #5 as completed.

---

## Phase 6: Publish ADR (2-3 min)

Mark todo #6 as in_progress.

### Update ADR Index

```bash
# Create or update ADR index
INDEX_FILE="$ADR_DIR/README.md"

if [ ! -f "$INDEX_FILE" ]; then
  cat > "$INDEX_FILE" <<EOF
# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) documenting significant architectural decisions made in this project.

## What is an ADR?

An ADR is a document that captures an important architectural decision made along with its context and consequences.

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
EOF
fi

# Add new ADR to index
ADR_TITLE=$(grep "^# ADR-" "$ADR_FILE" | head -1 | sed 's/^# ADR-[0-9]*: //')
ADR_STATUS=$(grep "^\*\*Status\*\*:" "$ADR_FILE" | sed 's/.*: //' | sed 's/\[//' | sed 's/\].*//')
ADR_DATE=$(grep "^\*\*Date\*\*:" "$ADR_FILE" | sed 's/.*: //')

echo "| [ADR-$NEXT_NUMBER](./ADR-${NEXT_NUMBER}-${SLUG}.md) | $ADR_TITLE | $ADR_STATUS | $ADR_DATE |" >> "$INDEX_FILE"

echo "Updated ADR index: $INDEX_FILE"
```

### Commit ADR

<!-- Component: prompts/git/commit-formatting.md -->

Stage and commit ADR files following conventional commit format (see `prompts/git/commit-formatting.md`):

```bash
# Stage ADR files
git add "$ADR_FILE" "$INDEX_FILE"

# Create commit using HEREDOC for proper formatting
git commit -m "$(cat <<'EOF'
docs(adr): add ADR-$NEXT_NUMBER - $ADR_TITLE

Architecture decision record documenting $ARGUMENTS

Decision: [brief summary of decision]

Status: $ADR_STATUS
EOF
)"

echo "ADR committed to git"
```

**Commit Type**: `docs` (documentation-only changes)
**Scope**: `adr` (ADR-specific)
**Format**: See `prompts/git/commit-formatting.md` for detailed commit message guidelines.

### Generate ADR Report

<!-- Component: prompts/reporting/summary-template.md -->
<!-- Component: prompts/reporting/artifact-listing.md -->
<!-- Component: prompts/reporting/next-steps-template.md -->

Create summary report using templates from `prompts/reporting/`:

```markdown
# ADR Creation Report: $ADR_TITLE

**Date**: [YYYY-MM-DD HH:MM:SS]
**ADR Number**: ADR-$NEXT_NUMBER
**Title**: $ADR_TITLE
**Status**: [Proposed/Accepted]
**Duration**: [Approximate time taken]

---

## Objective

Created Architecture Decision Record documenting: **$ARGUMENTS**

**Decision**: [Brief summary of the decision made]

---

## ADR Details

**File**: `$ADR_FILE`

**Key Decision Drivers**:
1. [Driver 1]
2. [Driver 2]
3. [Driver 3]

**Main Benefits**:
- [Benefit 1]
- [Benefit 2]

**Main Trade-offs**:
- [Trade-off 1]
- [Trade-off 2]

**Alternatives Considered**: [Count]

---

## Artifacts Generated

<!-- From prompts/reporting/artifact-listing.md -->

### Documentation Files

- `$ADR_FILE` - Architecture Decision Record ([size])
- `$INDEX_FILE` - Updated ADR index ([size])
- `.agency/adr/adr-creation-report-[date].md` - This report

**Total**: 3 files

---

## Next Steps

<!-- From prompts/reporting/next-steps-template.md -->

### ✅ ADR Published

**Immediate Actions**:

1. **Communicate Decision**
   - Share ADR with team
   - Add to team meeting agenda
   - Update stakeholders

2. **Update Documentation**
   - [ ] Update architecture diagrams if needed
   - [ ] Update developer documentation
   - [ ] Add to onboarding materials

3. **Track for Review**
   - **Review Date**: [6-12 months from now]
   - **Review Triggers**: [Conditions that would prompt early review]

**Implementation**:
- If implementation needed, create implementation plan
- Link to related issues/epics
- Schedule implementation work

---

**Status**: ✅ ADR Published
**Commit**: [commit hash]
**Generated**: [timestamp]
**Decision**: $ARGUMENTS
```

Save to `.agency/adr/adr-creation-report-[date].md`

**See**:
- `prompts/reporting/summary-template.md` for detailed summary structure
- `prompts/reporting/artifact-listing.md` for artifact tracking patterns
- `prompts/reporting/next-steps-template.md` for contextual next steps

Mark todo #6 as completed.

---

## Error Handling

### If Decision Unclear

**Ambiguous Topic**:
- Use AskUserQuestion to clarify
- Provide examples of similar decisions
- Ask user to specify scope

**Insufficient Context**:
- Ask user for more background
- Research current codebase
- Identify stakeholders to consult

### If Research Fails

**Agent Error**:
- Fall back to manual research
- Use web search for alternatives
- Ask user for known options

**No Clear Alternatives**:
- Document the single option thoroughly
- Explain why no alternatives exist
- Focus on "do we build this or not"

### If User Disagrees with Draft

**Requested Changes**:
- Make specific updates
- Re-run review cycle
- Get approval before publishing

**Major Revisions Needed**:
- Ask user for guidance
- Consider restarting with clearer requirements
- May need stakeholder meeting

### If ADR Directory Doesn't Exist

**Create Structure**:
```bash
mkdir -p docs/adr
cat > docs/adr/README.md <<EOF
# Architecture Decision Records

ADRs document significant architectural decisions.
EOF
```

---

## Important Notes

### ADR Best Practices

1. **Write When Decision Is Made**: Don't retroactively create ADRs (loses context)
2. **Focus on Why**: The "what" is in the code, ADR explains "why"
3. **Be Honest About Trade-offs**: Both good and bad consequences
4. **Keep It Concise**: 1-2 pages ideal, max 4 pages
5. **Review Regularly**: Revisit decisions every 6-12 months

### ADR Lifecycle

**Proposed** → **Accepted** → **Deprecated** → **Superseded**

- **Proposed**: Under consideration, not yet final
- **Accepted**: Decision is made and implemented
- **Deprecated**: No longer recommended but still in use
- **Superseded**: Replaced by a new decision (link to new ADR)

### Common ADR Mistakes

❌ **Too much implementation detail**: ADRs are about decisions, not code
❌ **Missing alternatives**: Shows lack of thorough analysis
❌ **Hiding negatives**: Damages trust and future decision-making
❌ **Too abstract**: Needs concrete examples and specifics
❌ **No update**: ADRs should be living documents

### When to Create an ADR

**Do create an ADR for**:
- Technology selection (database, framework, platform)
- Architectural patterns (monolith vs microservices)
- Security approach (auth, encryption)
- Deployment strategy (serverless, containers)
- Third-party service selection

**Don't create an ADR for**:
- Minor implementation details
- Obvious or standard choices
- Temporary decisions
- Personal preferences without impact

---

## Skills to Reference

Activate and reference these skills as needed:

**Required**:
- `agency-workflow-patterns` - Orchestration patterns (ACTIVATE IMMEDIATELY)

**ADR-Specific** (if available):
- `adr-writing` - ADR templates and best practices
- `architecture-patterns` - Common architectural patterns

**Technology-Specific** (activate based on decision):
- `nextjs-16-expert` - If decision involves Next.js
- `database-architecture` - If decision involves databases
- `cloud-architecture` - If decision involves deployment

---

## Related Commands

- `/agency:work [issue]` - Implement the decision from ADR
- `/agency:document architecture` - Generate broader architecture docs
- `/agency:review [pr]` - Review implementation of ADR
- `/agency:refactor [scope]` - May trigger new ADR for refactoring approach

---

## ADR Template Reference

```markdown
# ADR-XXXX: [Title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded
**Deciders**: [Names]

## Context and Problem Statement
[Why we need to make this decision]

## Decision
[What we decided to do]

## Consequences
### Positive
### Negative
### Neutral

## Alternatives Considered
### Alternative 1
### Alternative 2

## Implementation Notes
[How to implement]

## Related Decisions
[Links to related ADRs]

## References
[External links]
```

---

**Remember**:

- **Document decisions, not requirements**: Focus on why and how, not what
- **Be honest about trade-offs**: Every decision has pros and cons
- **Make it useful**: Future you will thank you for context
- **Keep it updated**: ADRs should reflect current reality
- **Link decisions**: Show how decisions relate to each other

Good architecture decisions are informed, documented, and communicated.

---

**End of /agency:adr command**
