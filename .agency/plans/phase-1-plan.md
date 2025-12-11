# Implementation Plan: Priority 1 - Agency Plugin Critical Foundation

## Executive Summary

Implement all Priority 1 items from the Agency Plugin Enhancement Roadmap:
- **1.1**: Universal Agent Enhancement Framework (add 5 sections to all 52 agents)
- **1.2**: Agent Template & Naming Convention (create template + rename 38 agents)
- **1.3**: Core Command Implementation (implement 3 commands: implement, review, test)

**Approach**: Agent-based enhancement workflow with verification
**Timeline**: Incremental implementation with validation checkpoints
**Risk**: Medium (large refactor, many file changes, git history preservation required)

---

## Implementation Strategy

### Agent-Based Enhancement Workflow

Per user requirement: **Spawn 1 agent to perform edits, then spawn another agent to verify**

**Enhancement Agent Pattern**:
```
1. Spawn specialist agent (e.g., code-reviewer) to enhance batch of agents
2. Agent makes systematic changes following templates
3. Spawn verification agent to validate all criteria met
4. If verification fails: fix issues and re-verify
5. If verification passes: commit batch and move to next
```

**Verification Criteria** (per agent):
- ✅ 5 new sections present and complete
- ✅ YAML frontmatter includes tools field
- ✅ Content is agent-specific (not templated placeholders)
- ✅ Cross-references are accurate (commands, skills, other agents)
- ✅ Metrics are measurable and realistic

---

## Phase 1: Agent Template & Naming Foundation (Priority 1.2)

**Goal**: Establish template and clean naming convention for all agents

### Step 1.1: Create Agent Template

**File to Create**: `.agency/templates/agent-template.md`

**Template Structure** (13 sections):
```yaml
---
name: [role-only, kebab-case]  # NOT category-role
description: [Clear, actionable description]
color: [color]
tools:
  essential: [Read, Write, Edit, Bash, Grep, Glob]
  optional: [WebFetch, WebSearch]
  specialized: []
skills:
  - agency-workflow-patterns
  - [tech-stack-specific-skills]
---

# [Agent Name] Agent

## 🧠 Identity & Memory
[Role, personality, experience, memory]

## 🎯 Core Mission
[Primary and secondary capabilities]

## 🚨 Critical Rules
[Non-negotiable constraints and quality standards]

## 🔧 Command Integration ⭐ NEW
[Which commands this agent responds to, role in each, examples]

## 📚 Required Skills ⭐ NEW
[Core agency skills, tech skills, workflow skills]

## 🛠️ Tool Requirements ⭐ NEW
[Essential, optional, specialized tools with usage patterns]

## 🔄 Workflow Process
[Step-by-step execution phases]

## 🎯 Success Metrics ⭐ NEW
[Quantitative targets, qualitative assessment, improvement indicators]

## 🤝 Cross-Agent Collaboration ⭐ NEW
[Upstream, downstream, peer relationships]

## 💡 Examples & Templates
[Code examples and deliverable templates]

## 🗣️ Communication Style
[Tone, example quotes, interaction patterns]
```

**Reference Files**:
- Study: `/Users/sbeardsley/Developer/squirrelsoft-dev/agency/agents/specialized/agents-orchestrator.md` (best command integration)
- Study: `/Users/sbeardsley/Developer/squirrelsoft-dev/agency/agents/design/design-ui-designer.md` (best comprehensive structure)
- Study: `/Users/sbeardsley/Developer/squirrelsoft-dev/agency/agents/marketing/marketing-growth-hacker.md` (only one with tools in YAML)

**Action**: Manually create template synthesizing best practices from all three

---

### Step 1.2: Rename 38 Agents (Preserve Git History)

**Problem**: Redundant category prefixes in 38 agents
- Example: `engineering/engineering-ai-engineer.md` → `engineering/ai-engineer.md`
- Example: `marketing/marketing-content-creator.md` → `marketing/content-creator.md`

**Strategy**: Use `git mv` to preserve history + update YAML name field

**Categories Affected**:
- Design: 6/6 agents (100%)
- Engineering: 4/7 agents (57%)
- Marketing: 8/8 agents (100%)
- Product: 3/3 agents (100%)
- Project Management: 4/5 agents (80%)
- Support: 6/6 agents (100%)
- Testing: 7/7 agents (100%)
- Spatial Computing: 0/6 (already clean ✅)
- Specialized: 0/3 (already clean ✅)

**Batch Approach**:
```bash
# Category-by-category batch renaming
# Example for Design category:

# 1. Git rename (preserves history)
git mv agents/design/design-brand-guardian.md agents/design/brand-guardian.md
git mv agents/design/design-ui-designer.md agents/design/ui-designer.md
git mv agents/design/design-ux-architect.md agents/design/ux-architect.md
git mv agents/design/design-ux-researcher.md agents/design/ux-researcher.md
git mv agents/design/design-visual-storyteller.md agents/design/visual-storyteller.md
git mv agents/design/design-whimsy-injector.md agents/design/whimsy-injector.md

# 2. Update YAML name field in each renamed file
# Change: name: design-brand-guardian
# To: name: brand-guardian
```

**Agent-Based Execution**:
1. Spawn agent to rename ONE category at a time
2. Agent performs git mv + YAML name field updates
3. Spawn verification agent to check:
   - Git history preserved (`git log --follow`)
   - YAML name field updated correctly
   - No broken references in that category
4. Commit category batch
5. Repeat for next category

**Verification Script** (manual check after each batch):
```bash
# Check git history preserved
git log --follow agents/design/brand-guardian.md

# Check YAML name field
grep "^name:" agents/design/brand-guardian.md
# Expected: name: brand-guardian (NOT name: design-brand-guardian)

# Check no old patterns remain in category
grep -l "design-design" agents/design/*.md
# Expected: No results
```

**Total**: 38 agents renamed across 7 categories

---

### Step 1.3: Update References After Rename

**Files to Update**:

1. **Orchestrator** (`agents/specialized/agents-orchestrator.md`)
   - Lines 297-356: "Available Specialist Agents" section
   - Update 38 agent display names

2. **Commands** (`commands/work.md`, `commands/plan.md`)
   - Specialist selection tables
   - Agent spawn examples

3. **Documentation** (search all `.md` files)
   - Any references to old agent names

**Agent-Based Execution**:
1. Spawn agent to find and update all references
2. Spawn verification agent to check no broken references
3. Test commands manually to ensure agent spawning works

---

## Phase 2: Universal Agent Enhancement (Priority 1.1)

**Goal**: Add 5 new standard sections to all 52 agents

### Enhancement Approach

**New Sections to Add** (per agent):
1. **Command Integration** - Which commands, role, selection criteria, examples
2. **Required Skills** - Core agency skills + tech stack skills
3. **Tool Requirements** - Essential/optional/specialized tools
4. **Success Metrics** - Quantitative targets, qualitative assessment
5. **Cross-Agent Collaboration** - Upstream/downstream/peer relationships

**Agent-Based Workflow**:

#### Step 2.1: Enhancement Agent Spawning

**Batch Strategy**: Process by category (10 batches)

For each category:
```
1. Spawn enhancement agent (e.g., code-reviewer or senior-developer)
2. Provide agent with:
   - Template sections (from .agency/templates/agent-template.md)
   - Category-specific guidance
   - Mapping rules (commands, skills, tools, collaboration)
3. Agent enhances all agents in that category
4. Agent follows template but customizes for each agent's domain
```

**Example Agent Instructions**:
```
Task: Enhance all 7 Engineering agents with 5 new sections

For each agent in agents/engineering/:
1. Add YAML tools field (essential: Read/Write/Edit/Bash/Grep/Glob, optional: WebFetch/WebSearch)
2. Add "🔧 Command Integration" section after "Core Mission"
   - Map to /agency:work (implementation), /agency:plan (review), /agency:implement, /agency:review, /agency:test
   - Provide selection criteria (e.g., Backend Architect selected for "API", "database" keywords)
3. Add "📚 Required Skills" section
   - Core: agency-workflow-patterns, code-review-standards, testing-strategy
   - Tech: Based on agent specialty (e.g., AI Engineer → ai-5, mastra-latest, pixeltable-0)
4. Add "🛠️ Tool Requirements" section (expand on YAML tools)
5. Add "🎯 Success Metrics" section
   - Quantitative: Test coverage ≥80%, build success 100%, performance targets
   - Qualitative: Code excellence, collaboration quality
6. Add "🤝 Cross-Agent Collaboration" section
   - Upstream: Who provides input (e.g., PM Senior, ArchitectUX)
   - Downstream: Who receives output (e.g., Testing, QA)
   - Peers: Who works alongside (e.g., Frontend ↔ Backend)

Ensure content is specific to each agent, not generic template text.
```

**Category Processing Order**:
1. Engineering (7 agents) - Core specialists
2. Testing (7 agents) - QA critical
3. Design (6 agents) - UX critical
4. Project Management (5 agents) - Planning critical
5. Marketing (8 agents)
6. Product (3 agents)
7. Support (6 agents)
8. Spatial Computing (6 agents)
9. Specialized (3 agents)
10. Orchestrator (1 agent) - Last, most complex

---

#### Step 2.2: Verification Agent Spawning

After each category batch, spawn verification agent:

**Verification Agent Instructions**:
```
Task: Verify all agents in [category] meet enhancement criteria

For each agent, validate:

✅ YAML Frontmatter:
- Has `tools:` field with essential/optional/specialized categories
- Has `skills:` field with array of skill names

✅ Section Completeness:
- "🔧 Command Integration" section exists and has:
  * Lists applicable commands (/agency:work, /agency:plan, etc.)
  * Defines role in each command
  * Provides selection criteria
  * Includes usage example
- "📚 Required Skills" section exists and has:
  * Core agency skills listed
  * Tech stack skills appropriate to agent domain
  * Skill activation pattern or example
- "🛠️ Tool Requirements" section exists and has:
  * Essential/optional/specialized categorization
  * Usage patterns or workflow examples
- "🎯 Success Metrics" section exists and has:
  * Quantitative targets (measurable with numbers)
  * Qualitative assessment criteria
  * Continuous improvement indicators
- "🤝 Cross-Agent Collaboration" section exists and has:
  * Upstream dependencies documented
  * Downstream deliverables documented
  * Peer collaboration identified

✅ Content Quality:
- No placeholder text like [TODO], [TBD], [FILL IN]
- Content is agent-specific, not generic template
- Cross-references are accurate (commands exist, skills exist, agents exist)
- Metrics are realistic and achievable

For each agent, output:
PASS ✅ or FAIL ❌ with specific missing items

Summary:
- Total agents: X
- Passed: Y
- Failed: Z
- Pass rate: %
```

**If Verification Fails**:
1. Review failure report
2. Spawn correction agent to fix specific issues
3. Re-run verification
4. Iterate until 100% pass rate

**If Verification Passes**:
1. Commit category batch
2. Move to next category

---

### Mapping Rules for Enhancement Agents

**Command Mapping** (which commands each agent responds to):

| Agent Type | Primary Commands | Role |
|------------|------------------|------|
| Engineering | /agency:work, /agency:implement | Implementation specialist |
| Testing | /agency:work, /agency:test | QA validator, test generator |
| Design | /agency:plan | Plan reviewer, UX designer |
| PM/Product | /agency:plan | Plan reviewer, requirements |
| Orchestrator | ALL commands | Coordinator |

**Skill Mapping** (which skills each agent needs):

| Agent Type | Core Skills | Tech Skills |
|------------|-------------|-------------|
| Engineering | agency-workflow, code-review, testing-strategy | nextjs-16, typescript-5, tailwindcss-4, etc. |
| Testing | agency-workflow, testing-strategy, code-review | typescript-5 |
| Design | agency-workflow | tailwindcss-4, shadcn-latest |
| PM/Product | agency-workflow, github-workflow | acli-latest |
| Marketing | agency-workflow | (varies) |

**Tool Mapping** (which tools each agent needs):

| Agent Type | Essential | Optional |
|------------|-----------|----------|
| Engineering | Read, Write, Edit, Bash, Grep, Glob | WebFetch, WebSearch |
| Testing | Read, Bash, Grep, Glob | Write, Edit |
| Design | Read, Write, Edit, Bash, Grep, Glob | WebFetch, WebSearch |
| All Others | Read, Write, Edit, Bash | WebFetch, WebSearch |

---

## Phase 3: Core Command Implementation (Priority 1.3)

**Goal**: Implement 3 provider-agnostic commands

### Commands to Implement

1. **`/agency:implement [plan-file]`** - Execute from existing plan
2. **`/agency:review [pr-number | file-path]`** - Comprehensive code review
3. **`/agency:test [component]`** - Generate comprehensive tests

---

### Step 3.1: Implement `/agency:implement`

**File to Create**: `commands/implement.md`

**Structure** (6 phases, ~520-580 lines):

```yaml
---
description: Execute implementation from an existing plan file
argument-hint: plan-file path
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, TodoWrite, AskUserQuestion]
---

# Implement from Plan: $ARGUMENTS

Execute implementation from an existing plan file with specialist delegation and quality gates.

## Critical Instructions
Activate agency-workflow-patterns skill

## Phase 1: Plan Validation & Parsing (3-5 min)
- Read plan file from .agency/plans/
- Extract requirements, file changes, implementation steps
- Validate plan structure and completeness

## Phase 2: Specialist Selection (2-3 min)
- Analyze plan keywords (React/API/Mobile/AI)
- Select appropriate specialist (Frontend/Backend/AI/Senior)
- Get user approval for specialist selection

## Phase 3: Implementation Delegation (30-180 min)
- Spawn specialist with complete context
- Monitor progress via TodoWrite
- Handle interactive confirmations for destructive operations

## Phase 4: Verification & Quality Gates (5-10 min)
- Run build (must pass)
- Run type check (must pass)
- Run lint (warnings ok, errors fail)
- Run tests (must pass)
- Check coverage (target 80%+)

## Phase 5: Code Review (5-7 min)
- Spawn testing-reality-checker
- Review for plan compliance, quality, security
- Fix critical issues

## Phase 6: Completion (2-3 min)
- Save implementation summary to .agency/implementations/
- Report results with metrics
```

**Key Features**:
- Interactive mode for destructive operations (migrations, deletions)
- Auto-selects specialist based on plan analysis
- Quality gates block proceeding if build/tests fail
- Saves artifact to `.agency/implementations/impl-[feature]-[timestamp].md`

**Reference**: `/Users/sbeardsley/Developer/squirrelsoft-dev/agency/commands/work.md` (specialist selection pattern)

---

### Step 3.2: Implement `/agency:review`

**File to Create**: `commands/review.md`

**Structure** (5 phases, ~550-620 lines):

```yaml
---
description: Comprehensive multi-aspect code review (security, quality, performance, testing)
argument-hint: pr-number, URL, or file-path
allowed-tools: [Read, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion]
---

# Code Review: $ARGUMENTS

Multi-aspect code review with parallel specialist evaluation and aggregated recommendations.

## Critical Instructions
Activate code-review-standards skill

## Phase 1: Review Target Detection (2-3 min)
- Auto-detect: GitHub PR (#123), GitLab MR, Bitbucket PR, or local files
- Fetch PR details (gh/glab) or read local files
- Determine provider and extract changed files

## Phase 2: Changed Files Analysis (3-5 min)
- Categorize files (frontend/backend/config/tests)
- Calculate complexity (LoC changed, files affected)
- Determine review aspects needed

## Phase 3: Parallel Multi-Aspect Review (10-30 min)
- Spawn 3-5 review agents IN PARALLEL:
  * Security Review (Backend Architect) - OWASP Top 10, injection, auth
  * Quality Review (Reality Checker) - readability, maintainability, bugs
  * Performance Review (Performance Benchmarker) - if backend/DB changes
  * Testing Review (Test Analyzer) - if coverage < 80%
  * Architecture Review (Specialist) - if > 20 files changed
- Each agent outputs findings with severity (Critical/High/Medium/Low)

## Phase 4: Review Aggregation (5-7 min)
- Combine findings from all reviewers
- Categorize by severity and file
- Generate unified report

## Phase 5: Recommendations (2-3 min)
- Prioritize action items (critical first)
- Estimate fix time per issue
- Save review report to .agency/reviews/pr-$NUMBER-review-[timestamp].md
```

**Key Features**:
- Multi-provider support (GitHub, GitLab, Bitbucket, local)
- Parallel review (5x faster than sequential)
- Severity categorization (Critical → High → Medium → Low)
- Saves artifact to `.agency/reviews/pr-$NUMBER-review-[timestamp].md`

**Reference**: `/Users/sbeardsley/Developer/squirrelsoft-dev/agency/skills/code-review-standards/SKILL.md`

---

### Step 3.3: Implement `/agency:test`

**File to Create**: `commands/test.md`

**Structure** (6 phases, ~500-560 lines):

```yaml
---
description: Generate comprehensive tests (unit, integration, E2E) for a component
argument-hint: component file path
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, TodoWrite]
---

# Generate Tests: $ARGUMENTS

Generate comprehensive test suite with framework auto-detection and coverage validation.

## Critical Instructions
Activate testing-strategy skill

## Phase 1: Component Analysis (3-5 min)
- Locate component file
- Detect type (React component, API endpoint, utility function)
- Find test framework (Jest, Vitest, Mocha, Playwright, Cypress)
- Analyze existing tests

## Phase 2: Test Strategy (2-3 min)
- Determine test types needed (unit/integration/E2E)
- Identify test scenarios (28 unit, 12 integration, 5 E2E)
- Calculate coverage gaps

## Phase 3: Test Generation (10-30 min)
- Spawn testing specialist
- Generate unit tests (70% - fast, isolated)
- Generate integration tests (20% - API, services)
- Generate E2E tests (10% - critical flows)

## Phase 4: Validation (5-10 min)
- Run tests (must pass)
- Check coverage improvement
- Verify test quality

## Phase 5: Quality Review (3-5 min)
- Review test best practices
- Check for common anti-patterns
- Ensure proper assertions

## Phase 6: Completion (2-3 min)
- Save test documentation to .agency/tests/test-report-[component]-[timestamp].md
- Report coverage improvement metrics
```

**Key Features**:
- Framework auto-detection (Jest, Vitest, Mocha, Playwright, Cypress)
- Test pyramid distribution (70% unit, 20% integration, 10% E2E)
- Coverage target 80% (configurable)
- Saves artifacts: test files + `.agency/tests/test-report-[component]-[timestamp].md`

**Reference**: `/Users/sbeardsley/Developer/squirrelsoft-dev/agency/skills/testing-strategy/SKILL.md`

---

## Phase 4: Integration & Validation

### Step 4.1: Cross-Reference Validation

**Verify**:
1. Orchestrator agent references updated agent names
2. Commands reference correct agent names in specialist tables
3. Agents reference existing commands
4. Agents reference existing skills
5. No broken cross-references

**Method**: Spawn verification agent to check all references

---

### Step 4.2: Manual Testing

**Test Each Command**:
```bash
# Test implement command
/agency:implement .agency/plans/test-plan.md

# Test review command
/agency:review 123

# Test test command
/agency:test src/components/Button.tsx
```

**Test Agent Spawning**:
```bash
# Via /agency:work - verify specialist selection works with new names
/agency:work 123
```

---

## Critical Files Reference

### Templates
- **Create**: `.agency/templates/agent-template.md` (13 sections)

### Agents to Rename (38 total)
- **Design**: 6 agents in `agents/design/`
- **Engineering**: 4 agents in `agents/engineering/`
- **Marketing**: 8 agents in `agents/marketing/`
- **Product**: 3 agents in `agents/product/`
- **Project Management**: 4 agents in `agents/project-management/`
- **Support**: 6 agents in `agents/support/`
- **Testing**: 7 agents in `agents/testing/`

### Agents to Enhance (52 total)
- All agents across all 10 categories

### Commands to Create
- **Create**: `commands/implement.md`
- **Create**: `commands/review.md`
- **Create**: `commands/test.md`

### References to Update
- **Update**: `agents/specialized/agents-orchestrator.md` (lines 297-356)
- **Update**: `commands/work.md` (specialist table)
- **Update**: `commands/plan.md` (reviewer references)

---

## Implementation Sequence

### Week 1: Template & Naming Foundation
1. Create agent template (4 hours)
2. Rename Design category (6 agents) - test workflow (2 hours)
3. Rename Engineering category (4 agents) (1 hour)
4. Rename remaining 5 categories (28 agents) (3 hours)
5. Update references (orchestrator, commands) (2 hours)

**Deliverable**: Template created, 38 agents renamed, references updated

---

### Week 2-3: Universal Enhancement (Batch 1)
1. Enhance Engineering agents (7 agents) (6 hours)
2. Enhance Testing agents (7 agents) (6 hours)
3. Enhance Design agents (6 agents) (5 hours)
4. Enhance PM agents (5 agents) (4 hours)

**Deliverable**: 25 critical agents enhanced and verified

---

### Week 3-4: Universal Enhancement (Batch 2)
1. Enhance Marketing agents (8 agents) (5 hours)
2. Enhance Product agents (3 agents) (3 hours)
3. Enhance Support agents (6 agents) (5 hours)
4. Enhance Spatial Computing agents (6 agents) (4 hours)
5. Enhance Specialized agents (3 agents) (3 hours)
6. Enhance Orchestrator (1 agent) (4 hours)

**Deliverable**: All 52 agents enhanced and verified

---

### Week 5: Command Implementation
1. Implement /agency:implement command (8 hours)
2. Implement /agency:review command (8 hours)
3. Implement /agency:test command (8 hours)
4. Integration testing (4 hours)

**Deliverable**: 3 new commands implemented and tested

---

## Success Criteria

### Phase 1 Success (Template & Naming)
- ✅ Agent template exists at `.agency/templates/agent-template.md`
- ✅ 38 agents renamed with git history preserved
- ✅ 0 agents with redundant category prefix
- ✅ All references updated (orchestrator, commands, docs)
- ✅ Agent spawning works with new names

### Phase 2 Success (Universal Enhancement)
- ✅ All 52 agents have 5 new sections
- ✅ All agents have YAML tools and skills fields
- ✅ 100% verification pass rate per category
- ✅ No placeholder text in any agent
- ✅ All cross-references accurate

### Phase 3 Success (Commands)
- ✅ 3 new commands implemented
- ✅ All commands follow established pattern
- ✅ Commands tested and working
- ✅ Artifacts saved to correct directories
- ✅ Provider abstraction working

---

## Risk Mitigation

### Risk 1: Git History Loss During Rename
**Mitigation**: Use `git mv` exclusively, test on one agent first, verify `git log --follow`

### Risk 2: Broken Agent References After Rename
**Mitigation**: Update references immediately after each category, test agent spawning

### Risk 3: Enhancement Quality Inconsistency
**Mitigation**: Use verification agent after each batch, fix issues before proceeding

### Risk 4: Verification Agent Overwhelm
**Mitigation**: Process in small batches (category at a time), clear verification criteria

### Risk 5: Command Implementation Complexity
**Mitigation**: Follow existing command patterns (work.md, plan.md), test incrementally

---

## Next Steps

1. **Approve this plan** ✋
2. **Begin Phase 1**: Create template, rename Design category (test workflow)
3. **Validate approach**: Verify git history preserved, agent spawning works
4. **Proceed systematically**: Complete one phase before moving to next
5. **Track progress**: Use TodoWrite for phase tracking

---

**Plan Status**: Ready for execution
**Estimated Total Time**: 80-100 hours across 5 weeks
**Approach**: Agent-based enhancement with verification at each step
**Next Action**: User approval → Begin Phase 1 → Create agent template
