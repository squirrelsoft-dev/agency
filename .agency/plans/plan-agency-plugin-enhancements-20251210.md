# Implementation Plan: Agency Plugin Enhancement Roadmap

## Summary

This plan prioritizes and organizes all identified enhancements for the Agency plugin based on comprehensive review of 52 agents, 12 outstanding questions, and current plugin architecture. The enhancements are organized into 7 priority tiers spanning agent improvements, command development, skill creation, hook implementation, and settings configuration.

## Scope

### In Scope
- Agent naming, description, and capability enhancements (52 agents)
- Command implementation and design decisions (15+ commands)
- Skill creation and content development (6 workflow skills)
- Hook design and default configuration (5 quality hooks)
- Settings architecture and default values
- Documentation and standardization
- Universal enhancement patterns

### Out of Scope
- Complete rewrite of existing agents
- Breaking changes to current API
- Third-party service integrations (external APIs)
- Performance optimization (separate initiative)
- Agent versioning system (Phase 2 consideration)

---

## Key Architectural Decision: Provider Abstraction

**Critical Design Pattern**: Commands are **provider-agnostic**, configuration determines **provider**, skills provide **implementation**.

### The Problem
Original approach had provider-specific commands:
- `/agency:gh-sprint` (GitHub)
- `/agency:jira-sprint` (Jira)
- `/agency:gh-worktree` (GitHub)
- More providers → More commands → User confusion

### The Solution
**Single command, multiple providers**:
- `/agency:sprint [sprint-id]` works with ANY issue tracker
- Configuration file specifies provider: `providers.issue_tracker = "github"`
- Skills provide provider-specific implementation: `github-integration`, `jira-integration`

### How It Works
```
User: /agency:sprint current

Step 1: Read config
  providers.issue_tracker = "github"

Step 2: Activate skill
  Skill: github-integration
  Provides: gh CLI commands, API patterns

Step 3: Execute
  Agent uses: gh project list, gh issue list, etc.
  Works with GitHub-specific tools and APIs

---

User: /agency:sprint SPRINT-123

Step 1: Read config
  providers.issue_tracker = "jira"

Step 2: Activate skill
  Skill: jira-integration
  Provides: acli commands, Jira API patterns

Step 3: Execute
  Agent uses: acli sprint get, acli issue list, etc.
  Works with Jira-specific tools and APIs
```

### Benefits
✅ **Fewer Commands**: 12 total instead of 20+ (no per-provider duplicates)
✅ **Easier to Learn**: One command works everywhere
✅ **Extensible**: Add new providers without new commands
✅ **Clean Separation**: Commands (interface) vs Config (behavior) vs Skills (implementation)
✅ **User Choice**: Switch providers by changing config, not commands

### Architecture Layers
```
┌─────────────────────────────────────┐
│  Commands (User Interface)          │  /agency:work, /agency:sprint
│  - Provider-agnostic                │  /agency:review, /agency:test
│  - User-facing interface            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Configuration (Behavior Control)   │  providers:
│  - Provider selection                │    issue_tracker: github
│  - Provider-specific settings       │    git_provider: github
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Skills (Implementation)            │  github-integration
│  - Provider-specific tools          │  jira-integration
│  - API patterns and CLI usage       │  linear-integration
└─────────────────────────────────────┘
```

### Supported Providers

**Phase 1** (Must support):
- **GitHub**: Issue tracking, PRs, Projects (via `gh` CLI)
- **Jira**: Issue tracking, Sprints, Boards (via `acli`)

**Phase 2** (Add based on demand):
- **Linear**: Issues, Cycles, Teams (via Linear API)
- **GitLab**: Issues, MRs, Boards (via `glab` CLI)

**Phase 3+** (Future):
- Shortcut, Azure DevOps, Bitbucket, etc.

This architectural decision appears throughout the plan in:
- Priority 1.3: Command design
- Priority 3.1: Provider integration skills
- Priority 4.2: Provider configuration settings

---

## Prioritized Enhancement List

### Priority 1: Critical Foundation (Do Immediately)

**Impact**: Unblocks all other work, establishes standards
**Estimated Effort**: 2-3 weeks
**Dependencies**: None

#### 1.1 Universal Agent Enhancement Framework
**Description**: Apply standard enhancements to all 52 agents to establish consistency

**Enhancements**:
- ✅ **Command Integration Section**: Add `/agency:*` command references to every agent
  - Documents which commands the agent responds to
  - Provides command usage examples
  - Explains agent's role in command workflows

- ✅ **Skill Reference Section**: Document required Claude Code skills
  - Technical skills (framework expertise)
  - Workflow skills (automation patterns)
  - Quality skills (testing, review standards)

- ✅ **Tool Requirements Section**: Standardize tool access definitions
  - Essential tools (Read, Write, Edit, Bash, Grep, Glob)
  - Optional tools (WebFetch, WebSearch, MCP)
  - Tool usage patterns specific to agent role

- ✅ **Success Metrics Standardization**: Make all metrics measurable
  - Quantitative metrics with targets
  - Qualitative assessment criteria
  - Continuous improvement indicators

- ✅ **Cross-Agent Collaboration**: Document integration patterns
  - Upstream dependencies (receives input from)
  - Downstream deliverables (provides output to)
  - Peer collaboration (works alongside)

**Why Priority 1**: Every other enhancement builds on these foundations. Without standardization, agent quality will continue to drift.

#### 1.2 Create Standard Agent Template & Naming Convention
**Description**: Establish canonical template and clean naming convention for all agents

**Naming Convention**: ⭐ UPDATED - No Category Redundancy

The folder structure provides namespace automatically:
```
Folder: agents/engineering/
File: senior-developer.md (NOT engineering-senior-developer.md)
Name field: senior-developer (NOT engineering-senior-developer)
Result: agent-agency:engineering:senior-developer ✅
```

**Current Problem** (redundancy):
```
❌ agent-agency:engineering:engineering-ai-engineer
❌ agent-agency:marketing:marketing-content-creator
❌ agent-agency:design:design-visual-storyteller
```

**Clean Solution**:
```
✅ agent-agency:engineering:ai-engineer
✅ agent-agency:marketing:content-creator
✅ agent-agency:design:visual-storyteller
✅ agent-agency:orchestrator (no category folder)
```

**Naming Rules**:
1. **With category folder**: `agents/{category}/{role}.md`
   - Filename: Just the role (e.g., `ai-engineer.md`)
   - Name field: Just the role (e.g., `ai-engineer`)
   - Full name: `agent-agency:{category}:{role}`

2. **Without category folder**: `agents/{role}.md`
   - Filename: Just the role (e.g., `orchestrator.md`)
   - Name field: Just the role (e.g., `orchestrator`)
   - Full name: `agent-agency:{role}`

**Template Structure**:
```markdown
---
name: [role-only]  # NOT category-role
description: [Clear, actionable description]
color: [color]
tools: [Explicit tool list]
skills: [Required Claude Code skills]
---

# [Agent Name] Agent

## Role Definition
## Core Capabilities
## Agency Command Integration
## Skill Dependencies
## Tool Requirements
## Workflow Processes
## Success Metrics
## Agent Collaboration
## Examples & Templates
```

**Deliverable**: Single template file used for all new agents + naming convention guide

**Why Priority 1**: Prevents future inconsistency, establishes quality bar, eliminates redundancy

#### 1.3 Core Command Priority Selection & Design
**Description**: Answer Q1 - Select 5-8 core commands for Phase 1 implementation

**Architecture Principle**: Provider-Agnostic Commands
- Commands are NOT coupled to specific services (no `/agency:gh-sprint` or `/agency:jira-sprint`)
- Configuration determines provider (GitHub, Jira, Linear, GitLab, etc.)
- Skills provide provider-specific implementation guidance
- Single command works across all providers

**Phase 1 Commands** (Must implement first):

1. **`/agency:work [issue]`** ⭐⭐⭐
   - Auto-detects provider from config or context
   - Full workflow: plan → implement → test → review → PR
   - **Interactive by default** (confirms plan before implementing)
   - **Providers**: GitHub, Jira, Linear (via config)

2. **`/agency:plan [issue/description]`** ⭐⭐⭐
   - Create implementation plan only
   - No execution
   - **Fully automated** (presents plan for approval)
   - **Provider-agnostic**: Works with any issue tracker

3. **`/agency:implement [plan-file]`** ⭐⭐
   - Execute from existing plan
   - **Interactive for critical decisions** (confirms destructive operations)
   - **Provider-agnostic**: Implementation is same regardless of issue source

4. **`/agency:review [pr-number | file-path]`** ⭐⭐⭐
   - Comprehensive code review
   - Security, quality, performance, tests
   - **Fully automated** (generates review report)
   - **Providers**: GitHub PR, GitLab MR, Bitbucket PR (via config)

5. **`/agency:test [component]`** ⭐⭐
   - Generate comprehensive tests
   - Unit, integration, E2E based on component type
   - **Fully automated** (creates test files)
   - **Provider-agnostic**: Testing is same regardless of source

**Phase 2 Commands** (After Phase 1 proven):

6. **`/agency:sprint [sprint-id]`** ⭐⭐
   - Implement entire sprint (all issues in sprint)
   - Auto-detects provider from config
   - **Providers**: GitHub Projects, Jira Sprints, Linear Cycles
   - Activates provider-specific skill for API interactions

7. **`/agency:refactor [scope]`** ⭐
   - Refactoring workflow
   - **Provider-agnostic**

8. **`/agency:document [topic]`** ⭐
   - Generate documentation
   - **Provider-agnostic**

**Phase 3+ Commands** (Future):

9. **`/agency:optimize [target]`** - Performance optimization
10. **`/agency:security [scope]`** - Security audit
11. **`/agency:adr [decision]`** - Create Architecture Decision Record
12. **`/agency:deploy [environment]`** - Deployment workflow (provider: AWS, GCP, Vercel, etc.)

**Provider Abstraction Pattern**:
```yaml
# .claude/agency.local.md
providers:
  issue_tracker: github      # or jira, linear, shortcut
  git_provider: github       # or gitlab, bitbucket
  ci_cd: github_actions      # or gitlab_ci, jenkins, circleci
  deploy: vercel             # or aws, gcp, netlify

  # Provider-specific config
  github:
    default_branch: main
    auto_create_pr: true

  jira:
    project_key: PROJ
    board_id: 123
```

**Skill-Based Provider Integration**:
- `github-integration-skill` - Activates when provider is GitHub
- `jira-integration-skill` - Activates when provider is Jira
- `linear-integration-skill` - Activates when provider is Linear
- `gitlab-integration-skill` - Activates when provider is GitLab

**Benefits**:
- ✅ Fewer commands (no provider-specific duplicates)
- ✅ Easier to learn (one command, works everywhere)
- ✅ Adding new providers doesn't require new commands
- ✅ Configuration controls behavior (separation of concerns)
- ✅ Skills provide provider-specific implementation details

**Rationale**:
- Focus on 80/20 - most common workflows first
- `work`, `plan`, `review`, `test` cover majority of use cases
- Provider abstraction makes commands universally applicable
- Validate approach before building specialized commands
- Can expand based on user feedback

**Why Priority 1**: Commands are core user interface - must establish command architecture before building out

---

### Priority 2: High-Impact Agent Enhancements (Week 2-3)

**Impact**: Improves quality of most-used agents
**Estimated Effort**: 2 weeks
**Dependencies**: Priority 1.1, 1.2 completed

#### 2.1 Critical Product & Testing Agents (15 agents)

**Agents to Enhance**:
- Product Agents (3): feedback-synthesizer, sprint-prioritizer, trend-researcher
- Testing Agents (7): api-tester, evidence-collector, performance-benchmarker, reality-checker, results-analyzer, tool-evaluator, workflow-optimizer
- Project Management Agents (5): experiment-tracker, project-shepherd, studio-operations, studio-producer, senior-pm

**Enhancement Pattern** (Same for all):
1. **Rename files & name fields**: Remove category prefix (folder provides namespace)
2. Add command integration section
3. Add skill reference section
4. Standardize tool requirements
5. Make metrics measurable
6. Add collaboration patterns

**Example - Product Sprint Prioritizer**:
```markdown
**Current File**: agents/product/product-sprint-prioritizer.md
**Current Name**: product-sprint-prioritizer
**Full Name**: agent-agency:product:product-sprint-prioritizer ❌ (redundant)

**New File**: agents/product/sprint-prioritizer.md
**New Name**: sprint-prioritizer
**Full Name**: agent-agency:product:sprint-prioritizer ✅ (clean)

**Command Integration**:
- `/agency:work` - Execute sprint planning and prioritization
- `/agency:plan` - Create sprint roadmap
- `/agency:document` - Generate sprint documentation
- `/agency:review` - Review sprint performance

**Skills Required**:
- prioritization-frameworks (RICE, MoSCoW)
- capacity-planning-tools
- roadmap-visualization
- product-analytics-tools

**Collaboration**:
- Receives from: feedback-synthesizer (user insights)
- Provides to: senior-pm (sprint backlog)
- Works with: backend-architect, frontend-developer (capacity estimates)
```

**Why Priority 2**: These agents are critical for workflow orchestration and quality assurance - high usage, high impact

#### 2.2 Orchestrator Agent Enhancement ⭐ CRITICAL

**Description**: Update master orchestrator with improved patterns

**Enhancements**:
1. **Update Agent Catalog**: Use new agent names from Priority 1
2. **Command Integration**: Reference `/agency:*` commands when spawning agents
3. **Improved Agent Selection**: Categorize agents for better selection
4. **Parallel Execution**: Add parallel task support where possible
5. **Quality Gates**: Implement consistent gates across workflows

**Example Improvement**:
```markdown
**Before**: "Spawning Backend Architect to design API"
**After**: "Using `/agency:plan` with engineering-backend-architect to design API architecture"
```

**Why Priority 2**: Orchestrator is the hub - improvements here multiply across all workflows

---

### Priority 3: Essential Skills & Documentation (Week 3-4)

**Impact**: Enables better agent performance and user understanding
**Estimated Effort**: 1.5 weeks
**Dependencies**: Commands from Priority 1.3 must be designed

#### 3.1 Create Workflow & Provider Integration Skills

**Core Workflow Skills** (Phase 1 - Answer to Q4):

1. **`agency-workflow-patterns`** ⭐⭐⭐
   - Orchestrator usage patterns
   - Multi-agent coordination
   - Parallel vs sequential execution
   - Context management strategies
   - Common workflow patterns
   - Provider abstraction patterns

2. **`git-workflow-best-practices`** ⭐⭐⭐ (Provider-agnostic)
   - Branch naming conventions
   - PR/MR creation and review
   - Commit message standards
   - Git worktree usage
   - Merge strategies
   - Conflict resolution

3. **`code-review-standards`** ⭐⭐⭐
   - Security review checklist
   - Code quality criteria
   - Performance considerations
   - Testing requirements
   - Documentation expectations

4. **`testing-strategy-standards`** ⭐⭐⭐
   - Test pyramid
   - Framework selection
   - Coverage thresholds
   - Test organization
   - Mocking strategies
   - CI/CD integration

**Provider Integration Skills** (Phase 1 - Critical for Commands):

5. **`github-integration`** ⭐⭐⭐
   - Using `gh` CLI for issues, PRs, projects
   - GitHub API patterns
   - GitHub Actions workflow syntax
   - Issue triage with labels/milestones
   - Sprint planning with GitHub Projects
   - Auto-linking issues to PRs

6. **`jira-integration`** ⭐⭐
   - Using `acli` for Jira operations
   - Jira REST API patterns
   - Issue creation and transitions
   - Sprint management
   - JQL for issue queries
   - Comment formatting (ADF)

**Provider Integration Skills** (Phase 2 - Add as needed):

7. **`linear-integration`** ⭐
   - Using Linear CLI/API
   - Issue and cycle management
   - Team and project operations

8. **`gitlab-integration`** ⭐
   - Using `glab` CLI
   - GitLab API patterns
   - Merge request operations

**Defer to Phase 2**:
- `documentation-standards` (Medium priority)
- `development-workflow-automation` (May be redundant with hooks)
- Additional provider integrations: BitBucket, Azure DevOps, etc.

**Skill Activation Pattern**:
```markdown
# How Commands Activate Skills

When `/agency:work 123` is invoked:
1. Read config: `providers.issue_tracker = "github"`
2. Activate skill: `github-integration`
3. Skill provides: gh CLI commands, API patterns, workflow guidance
4. Agent executes: Using provider-specific tools and patterns

This pattern allows adding new providers without changing commands:
- Add provider config
- Create provider integration skill
- Commands automatically work with new provider
```

**Why Priority 3**: Agents reference these skills - having them available improves agent quality and consistency. Provider skills enable commands to work across different platforms.

#### 3.2 Agent Capability Matrix

**Description**: Create searchable matrix of agent capabilities

**Format**: Markdown table or JSON

**Columns**:
- Agent Name
- Category
- Primary Use Cases
- Commands Supported
- Skills Required
- Tool Requirements
- Collaboration Partners

**Use Cases**:
- Agent discovery ("Which agent handles API testing?")
- Workflow planning ("What agents needed for feature implementation?")
- Gap analysis ("Missing agent for X capability?")

**Deliverable**: `.agency/agent-capability-matrix.md`

**Why Priority 3**: Improves agent discoverability and selection

---

### Priority 4: Quality Hooks & Settings (Week 4-5)

**Impact**: Automates quality checks, improves developer experience
**Estimated Effort**: 1 week
**Dependencies**: Priority 1.3 (commands designed)

#### 4.1 Hook Design & Defaults (Answer to Q7)

**Enabled by Default** (2 hooks):
1. **Auto-Format on Edit**
   - Runs prettier/eslint on every edit
   - Fast (< 1 second)
   - High value
   - Non-intrusive

2. **Pre-Commit Validation**
   - Runs tests and linting before commits
   - Slower (10+ seconds) but worth it
   - Critical quality gate
   - Users can override with --no-verify

**Opt-In** (Disabled by default - 3 hooks):
3. **Auto-Lint Verification**
   - Can be noisy
   - May interrupt flow
   - Better as user choice

4. **Build Verification**
   - Too slow for every edit (5-30 seconds)
   - Better to run manually or in CI

5. **Test Auto-Run**
   - Very slow
   - Better for TDD enthusiasts
   - Offer "watch mode" alternative

**Rationale**: Enable fast, high-value hooks by default. Slow or noisy hooks are opt-in.

**Why Priority 4**: Quality gates prevent issues from reaching production

#### 4.2 Settings Architecture (Answer to Q10)

**Decision**: All settings OPTIONAL with smart defaults

**Settings Categories**:

1. **Default Models**
   ```yaml
   models:
     orchestrator: sonnet  # balance
     planning: sonnet      # strategic
     implementation: haiku # fast (can override to sonnet)
     review: sonnet        # thorough (can override to opus)
   ```

2. **Provider Configuration** ⭐ NEW - Critical for Provider Abstraction
   ```yaml
   providers:
     # Primary provider selection
     issue_tracker: github      # github, jira, linear, shortcut, azure_devops
     git_provider: github       # github, gitlab, bitbucket
     ci_cd: github_actions      # github_actions, gitlab_ci, jenkins, circleci
     deploy: vercel             # vercel, aws, gcp, netlify, railway

     # GitHub provider settings
     github:
       default_branch: main              # auto-detect from repo
       branch_prefix: feature/           # default prefix for new branches
       auto_create_pr: true              # create PR after implementation
       pr_template: .github/pull_request_template.md  # auto-detect
       label_prefix: agency/             # prefix for auto-created labels
       enable_projects: true             # use GitHub Projects for sprints

     # Jira provider settings
     jira:
       base_url: https://yourcompany.atlassian.net
       project_key: PROJ                 # default project
       board_id: 123                     # default board
       auto_transition: true             # auto-transition issues
       comment_on_pr: true               # link PR in Jira comments

     # Linear provider settings (Phase 2)
     linear:
       team_key: ENG                     # default team
       auto_create_cycles: true          # create cycles for sprints

     # GitLab provider settings (Phase 2)
     gitlab:
       default_branch: main
       merge_request_prefix: Draft:      # prefix for MRs
       auto_squash: false
   ```

3. **Workflow Preferences**
   ```yaml
   workflow:
     auto_approve_simple_plans: false  # safety first
     parallel_execution: true          # when possible
     auto_run_tests: true              # quality gate
     auto_format: true                 # enabled by default
     auto_lint: false                  # opt-in (noisy)
   ```

4. **Quality Gates**
   ```yaml
   quality:
     require_tests: true        # enforce quality
     min_coverage: 80           # percentage
     require_build_pass: true   # must compile
     require_lint_pass: false   # warnings ok
   ```

5. **Notification Preferences**
   ```yaml
   notifications:
     desktop: false              # non-intrusive
     progress_updates: true      # for long tasks
   ```

**Default Cascade**:
1. Check `.claude/agency.local.md` (project settings)
2. Check `~/.claude/agency.local.md` (user settings)
3. Use built-in defaults

**Why Priority 4**: Good defaults = great out-of-box experience

---

### Priority 5: Remaining Agent Categories (Week 5-7)

**Impact**: Completes agent enhancement coverage
**Estimated Effort**: 2-3 weeks
**Dependencies**: Priority 1.1, 1.2 (template and patterns established)

#### 5.1 Marketing Agents (8 agents)

**Agents**: app-store-optimizer, content-creator, growth-hacker, instagram-curator, reddit-community-builder, social-media-strategist, tiktok-strategist, twitter-engager

**Common Enhancements**:
- **Rename**: Remove `marketing-` prefix from files/names (folder provides namespace)
  - Example: `marketing-content-creator.md` → `content-creator.md`
  - Result: `agent-agency:marketing:content-creator` ✅
- Add command integration (work, plan, document, review, optimize)
- Add skills: social-media-analytics, content-calendar-automation, ab-testing
- Add tool requirements: Social media APIs, analytics tools

**Why Priority 5**: Important for growth but not core development workflows

#### 5.2 Support Agents (6 agents)

**Agents**: analytics-reporter, executive-summary-generator, finance-tracker, infrastructure-maintainer, legal-compliance-checker, support-responder

**Common Enhancements**:
- **Rename**: Remove `support-` prefix from files/names (folder provides namespace)
  - Example: `support-analytics-reporter.md` → `analytics-reporter.md`
  - Result: `agent-agency:support:analytics-reporter` ✅
- Add command integration (work, document, review, optimize)
- Add skills: analytics-dashboards, compliance-frameworks, automation
- Add tool requirements: Monitoring, reporting, compliance tools

**Why Priority 5**: Support infrastructure, not core feature development

#### 5.3 Spatial Computing Agents (6 agents)

**Agents**: macos-metal-engineer, terminal-integration-specialist, visionos-engineer, xr-cockpit-interaction, xr-immersive-developer, xr-interface-architect

**Common Enhancements**:
- **Rename**: Remove redundant prefixes (folder already says `spatial/`)
  - Example: `macos-spatial-metal-engineer.md` → `macos-metal-engineer.md`
  - Result: `agent-agency:spatial:macos-metal-engineer` ✅
- Add command integration (work, plan, optimize, test, document)
- Add skills: swift-metal-expert, webxr-api, 3d-spatial-design
- Add tool requirements: Metal, WebXR, RealityKit

**Why Priority 5**: Specialized for spatial computing projects only

#### 5.4 Specialized Agents (3 agents)

**Agents**: data-analytics-reporter, lsp-index-engineer

**Enhancements**:
- **Rename**: Remove `specialized-` prefix (folder provides namespace)
  - Example: `specialized-data-analytics.md` → `data-analytics.md`
  - Result: `agent-agency:specialized:data-analytics` ✅
- Add command integration
- Add specialized skills
- Document unique capabilities

**Why Priority 5**: Niche use cases, lower priority than core agents

---

### Priority 6: Advanced Features (Week 8+)

**Impact**: Nice-to-have improvements
**Estimated Effort**: 2-3 weeks
**Dependencies**: Priority 1-5 complete

#### 6.1 Phase 2 Commands (Provider-Agnostic)

Implement additional commands based on Phase 1 feedback:
- `/agency:sprint [sprint-id]` - Sprint automation (already in Phase 2)
- `/agency:refactor [scope]` - Refactoring workflows (already in Phase 2)
- `/agency:document [topic]` - Documentation generation (already in Phase 2)
- `/agency:optimize [target]` - Performance optimization
- `/agency:security [scope]` - Security audit
- `/agency:adr [decision]` - Create Architecture Decision Record
- `/agency:deploy [environment]` - Deployment workflow (provider-agnostic)

**No provider-specific commands needed** - all commands use provider config

**Example**: `/agency:sprint current`
- If `providers.issue_tracker = "github"`: Uses GitHub Projects API
- If `providers.issue_tracker = "jira"`: Uses Jira Sprint API
- If `providers.issue_tracker = "linear"`: Uses Linear Cycles API

**Why Priority 6**: Validate core commands first before expanding. Provider abstraction proven in Phase 1.

#### 6.2 Smart Defaults & Project Detection

**Features**:
- Auto-detect project type (React, Vue, Laravel, etc.)
- Enable appropriate hooks based on project size
- Suggest relevant agents for project type
- Customize settings based on framework

**Example**:
```
Detected: Next.js 15 project
Suggested agents: engineering-frontend-developer, design-ui-designer
Enabled hooks: auto-format, pre-commit
Suggested skills: nextjs-16-expert, react-18-best-practices
```

**Why Priority 6**: Improves UX but not essential for functionality

#### 6.3 Agent Performance Metrics

**Metrics to Track**:
- Agent usage frequency
- Success rates per agent
- Average task completion times
- Quality of agent outputs
- User satisfaction scores

**Implementation**:
- Log agent invocations
- Track task outcomes
- Collect user feedback
- Generate analytics dashboard

**Why Priority 6**: Data-driven improvements come after baseline established

---

### Priority 7: Future Considerations (Phase 2+)

**Impact**: Long-term improvements
**Estimated Effort**: TBD
**Dependencies**: User feedback from Phase 1

#### 7.1 Agent Versioning System

**Features**:
- Track agent versions
- Document capability changes
- Maintain backward compatibility
- Provide migration guides

**Why Priority 7**: Only needed once agents stabilize

#### 7.2 Additional Workflow Skills

Create Phase 2 skills:
- `documentation-standards`
- `development-workflow-automation`
- Framework-specific workflows
- Domain-specific patterns

**Why Priority 7**: Core skills sufficient for Phase 1

#### 7.3 Advanced Orchestration

**Features**:
- Learning from previous pipeline runs
- Predictive completion estimates
- Intelligent agent selection based on historical data
- Multi-project context awareness

**Why Priority 7**: Advanced features after core proven

---

## Technical Approach

### Architecture

**Component Structure**:
```
agency/
├── agents/              # 52 specialized agents
│   ├── design/         # 6 design agents
│   ├── engineering/    # 7 engineering agents
│   ├── marketing/      # 8 marketing agents
│   ├── product/        # 3 product agents
│   ├── pm/             # 5 PM agents
│   ├── spatial/        # 6 spatial agents
│   ├── specialized/    # 3 specialized
│   ├── support/        # 6 support agents
│   ├── testing/        # 7 testing agents
│   └── orchestrator.md # Master orchestrator
├── commands/           # Slash commands
│   ├── work.md
│   ├── plan.md
│   ├── implement.md
│   ├── review.md
│   └── test.md
├── skills/             # Workflow skills
│   ├── agency-workflow-patterns.md
│   ├── github-workflow-best-practices.md
│   ├── code-review-standards.md
│   └── testing-strategy-standards.md
├── hooks/              # Quality hooks
│   ├── auto-format-on-edit.sh
│   └── pre-commit-validation.sh
└── settings/
    ├── settings.schema.json
    └── defaults.yaml
```

**Data Flow**:
1. User invokes `/agency:work 123`
2. Command handler parses issue (GitHub/Jira)
3. Orchestrator spawns Planning agent
4. Planning agent creates implementation plan
5. User approves plan
6. Orchestrator spawns Implementation agents (parallel when possible)
7. Implementation agents execute tasks
8. Testing agents validate work
9. Review agents assess quality
10. Orchestrator creates PR

**Technology Stack**:
- **Commands**: Markdown files with YAML frontmatter
- **Agents**: Markdown files with YAML frontmatter
- **Skills**: Markdown documentation
- **Hooks**: Shell scripts
- **Settings**: YAML with JSON schema validation

---

## File Changes

### New Files (Priority 1-3)

**Agent Template**:
- `.agency/templates/agent-template.md`

**Commands** (5 files):
- `commands/work.md`
- `commands/plan.md`
- `commands/implement.md`
- `commands/review.md`
- `commands/test.md`

**Skills** (4 files):
- `skills/agency-workflow-patterns.md`
- `skills/github-workflow-best-practices.md`
- `skills/code-review-standards.md`
- `skills/testing-strategy-standards.md`

**Documentation**:
- `.agency/agent-capability-matrix.md`

**Hooks** (2 files):
- `hooks/auto-format-on-edit.sh`
- `hooks/pre-commit-validation.sh`

**Settings**:
- `settings/settings.schema.json`
- `settings/defaults.yaml`

**Total New Files**: ~18 files

### Modified Files (Priority 1-5)

**All 52 Agents** (renamed + enhanced):
- **RENAME**: Remove category prefix from filename and name field
  - Example: `engineering/engineering-ai-engineer.md` → `engineering/ai-engineer.md`
  - Example: `marketing/marketing-content-creator.md` → `marketing/content-creator.md`
  - Eliminates redundancy in agent names
- Add command integration section
- Add skill reference section
- Standardize tool requirements
- Make metrics measurable
- Add collaboration patterns

**Orchestrator**:
- Update agent catalog with new clean names
- Add command integration
- Improve agent selection
- Add parallel execution

**Plugin Manifest**:
- Register new commands
- Register new skills
- Configure hooks

**Total Modified/Renamed Files**: ~54 files (52 agents + orchestrator + manifest)

**Estimated Total Changes**: 72 files, ~3500-6000 LOC (includes renaming + enhancements)

---

## Implementation Phases

### Phase 1: Foundation (Weeks 1-3)
**Goal**: Establish standards and core commands

**Tasks**:
1. Create standard agent template
2. Apply universal enhancements to all agents (parallel work)
3. Design and implement 5 core commands
4. Update orchestrator agent

**Deliverables**:
- ✅ Agent template
- ✅ 52 agents updated with standard sections
- ✅ 5 commands implemented (work, plan, implement, review, test)
- ✅ Updated orchestrator

**Success Metrics**:
- All agents have command integration sections
- All agents have measurable success metrics
- 5 commands functional and tested
- Orchestrator references new command patterns

### Phase 2: Quality & Documentation (Weeks 3-5)
**Goal**: Enable better agent performance and quality

**Tasks**:
1. Create 4 core workflow skills
2. Build agent capability matrix
3. Implement 2 default-enabled hooks
4. Design 3 opt-in hooks
5. Configure settings with smart defaults

**Deliverables**:
- ✅ 4 skills created
- ✅ Capability matrix published
- ✅ 5 hooks implemented (2 enabled, 3 opt-in)
- ✅ Settings architecture with defaults

**Success Metrics**:
- Agents can reference workflow skills
- Agent discovery improved via capability matrix
- Auto-format and pre-commit hooks working
- Plugin works out-of-box with zero configuration

### Phase 3: Category Completion (Weeks 5-7)
**Goal**: Complete remaining agent enhancements

**Tasks**:
1. Enhance Marketing agents (8)
2. Enhance Support agents (6)
3. Enhance Spatial Computing agents (6)
4. Enhance Specialized agents (3)

**Deliverables**:
- ✅ 23 additional agents enhanced
- ✅ All 52 agents at consistent quality level

**Success Metrics**:
- 100% agent coverage for universal enhancements
- All agents follow naming convention
- All agents have command integration

### Phase 4: Advanced Features (Weeks 8+)
**Goal**: Add nice-to-have improvements

**Tasks**:
1. Implement Phase 2 commands (7 additional)
2. Add smart defaults and project detection
3. Build agent performance metrics

**Deliverables**:
- ✅ 7 additional commands
- ✅ Smart defaults system
- ✅ Metrics dashboard

**Success Metrics**:
- 12 total commands available
- Project type auto-detection working
- Usage metrics being collected

---

## Testing Strategy

### Unit Tests (70% of effort)

**Agent Template Validation**:
- YAML frontmatter parsing
- Required sections present
- Valid tool references
- Valid skill references

**Command Tests**:
- Argument parsing
- GitHub/Jira detection
- Plan generation
- PR creation

**Settings Tests**:
- Default value cascade
- Schema validation
- Override behavior

### Integration Tests (20% of effort)

**End-to-End Workflows**:
- `/agency:work` full workflow
- Plan → Implement → Test → Review → PR
- Multi-agent coordination
- Parallel execution

**Hook Integration**:
- Auto-format triggers on edit
- Pre-commit validation blocks bad commits
- Opt-in hooks can be enabled

### E2E Tests (10% of effort)

**Critical User Journeys**:
- User runs `/agency:work 123` on fresh project
- User approves plan, code implemented, tests pass, PR created
- User runs `/agency:review` on PR, gets quality feedback
- User runs `/agency:test` on component, tests generated

**Test Coverage Target**: 85%+

---

## Risks & Mitigation

### Risk 1: Agent Enhancement Effort Underestimated
**Impact**: High
**Probability**: Medium
**Mitigation**:
- Use batch scripts for universal enhancements
- Parallelize agent updates across team members
- Focus on top 20 most-used agents first if time-constrained

### Risk 2: Command Design Decisions Create Rework
**Impact**: High
**Probability**: Medium
**Mitigation**:
- User testing with 5 core commands before expanding
- Gather feedback early and iterate
- Keep command architecture flexible for changes

### Risk 3: Hook Performance Issues
**Impact**: Medium
**Probability**: Medium
**Mitigation**:
- Performance test hooks on large projects
- Make all hooks opt-in if performance problems
- Provide granular hook configuration

### Risk 4: Settings Complexity Overwhelms Users
**Impact**: Medium
**Probability**: Low
**Mitigation**:
- All settings optional with smart defaults
- Progressive disclosure (advanced settings hidden)
- Provide settings wizard for guided setup

### Risk 5: Agent Collaboration Patterns Not Clear
**Impact**: Medium
**Probability**: Medium
**Mitigation**:
- Document collaboration in capability matrix
- Provide workflow examples in skills
- Test multi-agent coordination early

### Risk 6: Scope Creep from Outstanding Questions
**Impact**: Low
**Probability**: High
**Mitigation**:
- Answer questions in priority order
- Defer non-critical questions to Phase 2
- Focus on 80/20 - most impactful decisions first

---

## Outstanding Questions Resolution

### Critical (Answer Now)

**Q1: Command Priority Selection** ✅ RESOLVED
- **Answer**: Implement 5 core commands in Phase 1 (work, plan, implement, review, test)
- **Rationale**: Covers 80% of use cases, validates approach before expanding

**Q2: Interactive vs Automated Commands** ✅ RESOLVED
- **Answer**:
  - `work`: Interactive (confirms plan)
  - `plan`: Automated (presents plan)
  - `implement`: Interactive (confirms destructive operations)
  - `review`: Automated (generates report)
  - `test`: Automated (creates tests)
- **Rationale**: Safety for high-impact commands, speed for low-risk

**Q4: Skill Priority Selection** ✅ RESOLVED
- **Answer**: Create 4 core skills in Phase 1 (agency-workflow, github-workflow, code-review, testing-strategy)
- **Rationale**: Most referenced by agents, highest value

**Q7: Hook Default Enablement** ✅ RESOLVED
- **Answer**: Enable 2 hooks by default (auto-format, pre-commit), 3 opt-in
- **Rationale**: Fast, high-value hooks enabled; slow/noisy hooks opt-in

**Q10: Settings Required vs Optional** ✅ RESOLVED
- **Answer**: All settings optional with smart defaults
- **Rationale**: Zero-config out-of-box experience

### Deferred (Answer in Phase 2)

**Q3: Command Argument Patterns**
- Defer to Phase 1 implementation - will emerge from usage

**Q5: Skill Detail Level**
- Defer to skill creation - adjust based on agent needs

**Q6: Skill Examples Approach**
- Defer to skill creation - iterate based on usage

**Q8: Hook Performance Strategy**
- Defer to hook implementation - test and optimize

**Q9: Hook Project Detection**
- Defer to Phase 4 (Smart Defaults)

**Q11: Settings Override Levels**
- Defer to settings implementation - keep simple initially

**Q12: Settings Validation Strategy**
- Defer to settings implementation - use JSON schema

---

## Success Metrics

### Quantitative Metrics

**Phase 1 (Foundation)**:
- **Agent Standardization**: 100% of agents have command integration sections
  - Target: 52/52 agents
  - Measurement: Automated script validation
  - Frequency: Weekly

- **Command Completion**: 5 core commands functional
  - Target: 100% (5/5 commands)
  - Measurement: Integration test pass rate
  - Frequency: Per release

**Phase 2 (Quality)**:
- **Skill Creation**: 4 workflow skills available
  - Target: 4/4 skills
  - Measurement: Skill content completeness
  - Frequency: End of Phase 2

- **Hook Performance**: Auto-format < 1 second
  - Target: 95th percentile < 1s
  - Measurement: Performance profiling
  - Frequency: Per release

**Phase 3 (Category Completion)**:
- **Agent Coverage**: 100% of agents enhanced
  - Target: 52/52 agents
  - Measurement: Enhancement checklist completion
  - Frequency: End of Phase 3

### Qualitative Metrics

**Quality**: Agent enhancement quality assessed by peer review
- Review checklist: Standard sections present, examples clear, metrics measurable

**User Satisfaction**: Feedback from command usage
- Survey after using `/agency:work` 5 times
- Net Promoter Score (NPS) target: 8+

**Team Velocity**: Impact on development speed
- Time to implement feature: Before vs After
- Code review feedback cycles: Reduction target 30%

### Continuous Improvement

**Learning Indicators**:
- Command usage patterns (which commands used most)
- Agent selection frequency (which agents most useful)
- Hook opt-in rates (which quality checks valuable)

**Optimization Targets**:
- Reduce average task completion time 20%
- Increase agent coordination success rate to 95%
- Improve first-time command success rate to 90%

---

## Next Steps

1. **Get User Approval** ✋
   - Review this prioritized enhancement plan
   - Confirm priority order makes sense
   - Adjust scope if needed

2. **Begin Phase 1 Implementation**
   - Week 1: Create agent template, start universal enhancements
   - Week 2: Design and implement 5 core commands
   - Week 3: Update orchestrator, complete agent standardization

3. **Track Progress**
   - Use `.agency/progress/` to track enhancement completion
   - Weekly status updates on agent standardization
   - Bi-weekly demos of new commands

4. **Gather Feedback**
   - User testing after Phase 1
   - Iterate on command design based on feedback
   - Adjust Phase 2-4 based on learnings

---

## Summary Statistics

- **Total Agents**: 52 (51 specialists + orchestrator)
- **Total Enhancement Documents Reviewed**: 13 detailed + 39 systematic recommendations
- **Total Outstanding Questions**: 12 (5 critical resolved, 7 deferred)
- **Total Commands Proposed**: 12 provider-agnostic commands (5 Phase 1, 3 Phase 2, 4 Phase 3+)
  - **Architecture Win**: No provider-specific command duplicates (eliminated `/agency:gh-*`, `/agency:jira-*`)
  - **Provider Support**: GitHub, Jira (Phase 1), Linear, GitLab (Phase 2+)
- **Total Skills Planned**: 8 (6 Phase 1: 4 workflow + 2 provider integration, 2 Phase 2)
- **Total Hooks Designed**: 5 (2 enabled, 3 opt-in)
- **Total Files to Create**: ~20 files (commands, skills, hooks, templates)
- **Total Files to Modify**: ~54 files (all agents + orchestrator)
- **Estimated Timeline**: 8+ weeks for Phases 1-4
- **Estimated LOC**: 3500-6000 lines (increased for provider abstraction layer)

---

## Conclusion

This enhancement roadmap provides a clear, prioritized path to improving the Agency plugin. By focusing on:

1. **Universal agent standardization** (Priority 1)
2. **High-impact agent enhancements** (Priority 2)
3. **Essential skills and documentation** (Priority 3)
4. **Quality hooks and settings** (Priority 4)
5. **Category completion** (Priority 5)
6. **Advanced features** (Priority 6)
7. **Future considerations** (Priority 7)

We ensure that the most valuable improvements are delivered first, while maintaining a long-term vision for the plugin's evolution.

### Key Architectural Wins

**Provider Abstraction**:
- 12 clean commands instead of 20+ provider-specific ones
- Configuration controls behavior, skills provide implementation
- Easy to add new providers (Linear, GitLab) without new commands

**Clean Naming Convention**:
- Eliminates redundancy: `agent-agency:engineering:ai-engineer` not `agent-agency:engineering:engineering-ai-engineer`
- Folder structure provides namespace automatically
- Shorter, clearer agent references throughout codebase

**Quality by Default**:
- 2 hooks enabled out-of-box (auto-format, pre-commit)
- All settings optional with smart defaults
- Zero configuration required to start

The agent ecosystem is already strong with clear roles and capabilities. These enhancements will make it more cohesive, efficient, and measurable - delivering higher quality results with better coordination and a cleaner, more intuitive interface.

---

**Plan Status**: Ready for Review and Approval
**Created**: 2025-12-10
**Next Action**: User approval → Phase 1 implementation
