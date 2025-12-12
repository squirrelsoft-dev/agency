# Agency Plugin

> Comprehensive workflow automation toolkit for the complete software development lifecycle

## Overview

**Agency** is a powerful Claude Code plugin that provides an intelligent agent ecosystem and composable workflow commands for automating your entire development process—from requirements gathering through deployment.

### Key Features

- 🤖 **51+ Specialized Agents**: Domain experts organized by category (engineering, design, testing, marketing, product, project management, spatial computing, support)
- 🎯 **Intelligent Orchestration**: Meta-orchestrator that coordinates multiple agents for complex workflows
- ⚡ **Composable Commands**: Workflow automation for GitHub/Jira issues, sprints, code review, testing, and more
- 📚 **Workflow Skills**: Best practices and patterns for effective development workflows
- 🔧 **Quality Automation**: Hooks for auto-formatting, linting, and quality gates

## Installation

### From Squirrelsoft Marketplace

```bash
# Install from marketplace
cc install agency

# Or install latest from GitHub
cc install https://github.com/squirrelsoft-dev/squirrelsoft-marketplace/tree/main/plugins/agency
```

### Manual Installation

```bash
# Clone and link
git clone https://github.com/squirrelsoft-dev/squirrelsoft-marketplace.git
cd squirrelsoft-marketplace/plugins/agency
cc plugin link .
```

## Quick Start

### Work on a Single Issue

```bash
# Work on issue #123 (GitHub or Jira)
/agency:work 123

# Work on Jira issue
/agency:work PROJ-456

# Work on next available issue
/agency:work next
```

### Implement an Entire Sprint ✨ NEW

```bash
# Implement entire sprint with dependency resolution
/agency:sprint milestone-name        # GitHub milestone
/agency:sprint PROJ-Sprint-12        # Jira sprint
/agency:sprint 2024-Q4-Sprint-3      # Linear cycle

# Features:
# - Auto-detects provider (GitHub/Jira/Linear)
# - Resolves issue dependencies
# - Parallel execution (max 3 concurrent)
# - Integration testing across PRs
# - Comprehensive sprint report
```

### Refactor Code Safely ✨ NEW

```bash
# Refactor specific file
/agency:refactor src/components/Button.tsx

# Refactor directory
/agency:refactor src/lib/auth

# Refactor by component name
/agency:refactor UserProfile

# Refactor by pattern
/agency:refactor "*.service.ts"

# Features:
# - Code quality analysis (complexity, duplication)
# - Incremental execution with git checkpoints
# - Automatic rollback on test failures
# - Before/after metrics comparison
```

### Optimize Performance ✨ NEW

```bash
# Optimize bundle size
/agency:optimize bundle

# Optimize database queries
/agency:optimize database

# Optimize rendering performance
/agency:optimize rendering

# Optimize API performance
/agency:optimize api

# Auto-detect optimization targets
/agency:optimize auto

# Features:
# - Profiling and baseline measurement
# - Incremental optimization with benchmarking
# - Before/after metrics comparison
# - Rollback if no improvement
```

### Generate Documentation ✨ NEW

```bash
# Generate API documentation
/agency:document api

# Create Architecture Decision Record
/agency:document architecture

# Document React components
/agency:document component

# Document feature with user guide
/agency:document authentication

# Generate inline code docs (JSDoc/TypeDoc)
/agency:document code

# Features:
# - Template-based generation
# - Code example validation
# - Link checking
# - Quality review
```

### Code Review & Testing

```bash
# Comprehensive code review
/agency:review PR-123

# Generate tests for component
/agency:test src/components/Button.tsx

# Help with commands
/agency:help sprint
```

## Agent Categories

### Engineering (7 agents)
- **AI Engineer**: ML/AI implementation and model integration
- **Backend Architect**: APIs, databases, and system design
- **DevOps Automator**: CI/CD, infrastructure, and deployment
- **Frontend Developer**: React, UI components, and modern web
- **Mobile App Builder**: iOS, Android, and cross-platform apps
- **Rapid Prototyper**: Fast MVPs and proof-of-concepts
- **Senior Developer**: Complex implementation and core logic

### Design (6 agents)
- **Brand Guardian**: Brand identity and consistency
- **UI Designer**: Visual design and component libraries
- **UX Architect**: Information architecture and user flows
- **UX Researcher**: User research and usability testing
- **Visual Storyteller**: Visual communication and narratives
- **Whimsy Injector**: Personality and delightful experiences

### Testing (7 agents)
- **API Tester**: API validation and contract testing
- **Evidence Collector**: Screenshot-based QA
- **Performance Benchmarker**: Load testing and optimization
- **Reality Checker**: Quality assurance and bug finding
- **Test Results Analyzer**: Test analysis and insights
- **Tool Evaluator**: Testing tool assessment
- **Workflow Optimizer**: Process improvement

### Product (3 agents)
- **Feedback Synthesizer**: User feedback analysis
- **Sprint Prioritizer**: Sprint planning and prioritization
- **Trend Researcher**: Market intelligence and trends

### Project Management (5 agents)
- **Experiment Tracker**: A/B testing and experiments
- **Project Shepherd**: Cross-functional coordination
- **Senior Project Manager**: Complex project planning
- **Studio Operations**: Day-to-day efficiency
- **Studio Producer**: Strategic orchestration

### Marketing (8 agents)
- **App Store Optimizer**: ASO and app discoverability
- **Content Creator**: Multi-platform content campaigns
- **Growth Hacker**: Rapid user acquisition
- **Instagram Curator**: Visual storytelling on Instagram
- **Reddit Community Builder**: Community engagement
- **Social Media Strategist**: Multi-platform strategy
- **TikTok Strategist**: Viral content creation
- **Twitter Engager**: Real-time engagement

### Spatial Computing (6 agents)
- **macOS Spatial/Metal Engineer**: Native spatial computing
- **Terminal Integration Specialist**: Terminal and editor integration
- **VisionOS Spatial Engineer**: visionOS development
- **XR Cockpit Interaction**: Cockpit-based control systems
- **XR Immersive Developer**: WebXR and browser AR/VR
- **XR Interface Architect**: Spatial interaction design

### Support (6 agents)
- **Analytics Reporter**: Data analysis and insights
- **Executive Summary Generator**: C-suite communication
- **Finance Tracker**: Financial planning and analysis
- **Infrastructure Maintainer**: System reliability
- **Legal Compliance Checker**: Compliance verification
- **Support Responder**: Customer service excellence

### Specialized (3 agents)
- **Agents Orchestrator**: Multi-agent coordination
- **Data Analytics Reporter**: Business intelligence
- **LSP/Index Engineer**: Code intelligence systems

## Available Commands

### Phase 1: Core Workflow (Provider-Agnostic)
- `/agency:work [issue]` - Work any issue end-to-end (auto-detects GitHub/Jira)
- `/agency:plan [issue]` - Create implementation plan without execution
- `/agency:implement [plan-file]` - Execute from existing plan file
- `/agency:review [pr]` - Comprehensive multi-aspect code review
- `/agency:test [component]` - Generate comprehensive test suite
- `/agency:help [command|agent]` - Get help for commands and agents

### Phase 2: Advanced Workflows ✨ NEW
- **`/agency:sprint [sprint-id]`** - Implement entire sprint with dependency resolution and parallel execution (GitHub milestones, Jira sprints, Linear cycles)
- **`/agency:refactor [scope]`** - Safe refactoring with code analysis, incremental execution, and test preservation
- **`/agency:optimize [target]`** - Performance optimization with profiling, benchmarking, and measurable improvements (bundle/database/rendering/api/memory)
- **`/agency:document [topic]`** - Generate comprehensive documentation with templates and validation (api/architecture/component/feature/code)
- **`/agency:security [scope]`** - Comprehensive security audit with vulnerability scanning, OWASP Top 10 checks, and remediation guidance
- **`/agency:adr [decision]`** - Create Architecture Decision Records documenting technical decisions with context, alternatives, and consequences
- **`/agency:deploy [environment]`** - Provider-agnostic deployment with pre-flight checks, health verification, and rollback capability

---

## Phase 2 Commands Deep Dive

### `/agency:sprint [sprint-id]` - Sprint Automation

Execute entire sprints with intelligent dependency resolution and parallel batch execution.

**Features**:
- ✅ **Provider-Agnostic**: Works with GitHub milestones, Jira sprints, Linear cycles
- ✅ **Dependency Resolution**: Builds dependency graph from issue links, executes in correct order
- ✅ **Parallel Execution**: Runs up to 3 issues concurrently when no dependencies
- ✅ **Integration Testing**: Creates integration branch to test all PRs together
- ✅ **Quality Verification**: Ensures all PRs pass tests, build, and security checks
- ✅ **Sprint Reporting**: Comprehensive completion report with metrics and learnings

**Example Workflows**:
```bash
# GitHub: Implement all issues in milestone "v2.0"
/agency:sprint v2.0

# Jira: Implement all issues in sprint "PROJ-Sprint-12"
/agency:sprint PROJ-Sprint-12

# Linear: Implement all issues in cycle "2024-Q4-Sprint-3"
/agency:sprint 2024-Q4-Sprint-3
```

**Phases** (8 total):
1. **Sprint Detection & Fetching**: Auto-detect provider, fetch all issues
2. **Dependency Analysis**: Build dependency graph, calculate execution batches
3. **Project Context Detection**: Detect framework/language for agent selection
4. **Batch Execution**: Execute issues in parallel batches (max 3 concurrent)
5. **Quality Verification**: Verify all PRs pass quality gates
6. **Integration Testing**: Merge all PRs to integration branch and test
7. **PR Review & Merging**: User selects merge strategy, automated merging
8. **Sprint Report**: Generate comprehensive completion report

**Outputs**:
- Sprint completion report: `.agency/sprints/sprint-[ID]-report-[date].md`
- Execution tracking: `.agency/sprints/sprint-[ID]-tracking.json`

---

### `/agency:refactor [scope]` - Safe Refactoring

Guided refactoring with safety verification, test preservation, and metrics comparison.

**Features**:
- ✅ **Code Quality Analysis**: Complexity, duplication, type coverage metrics
- ✅ **Incremental Execution**: Git checkpoints before each step, rollback on failure
- ✅ **Test Preservation**: Coverage must not decrease, tests run after each step
- ✅ **Automatic Rollback**: Immediate rollback if tests fail or coverage decreases
- ✅ **Before/After Metrics**: Quantifiable improvements in code quality
- ✅ **Refactoring Report**: Detailed report with metrics comparison

**Example Workflows**:
```bash
# Refactor specific file
/agency:refactor src/components/UserProfile.tsx

# Refactor entire directory
/agency:refactor src/lib/database

# Refactor by component name (searches codebase)
/agency:refactor AuthProvider

# Refactor files matching pattern
/agency:refactor "*.service.ts"
```

**Phases** (6 total):
1. **Scope Detection & Analysis**: Parse scope, analyze code quality
2. **Project Context Detection**: Detect language/framework for analysis tools
3. **Refactoring Plan Creation**: Incremental steps with before/after examples
4. **Incremental Execution**: Execute step-by-step with git checkpoints
5. **Safety Verification**: All tests pass, coverage ≥ baseline
6. **Refactoring Report**: Before/after metrics, changes made, git history

**Outputs**:
- Refactoring report: `.agency/refactorings/refactor-[scope]-[date].md`
- Git commits: One per successful refactoring step

---

### `/agency:optimize [target]` - Performance Optimization

Performance optimization with profiling, benchmarking, and measurable improvements.

**Features**:
- ✅ **Profiling & Baseline**: Establish baseline metrics before optimization
- ✅ **Target Detection**: Bundle, database, rendering, API, memory, or auto-detect
- ✅ **Incremental Optimization**: Benchmark after each optimization
- ✅ **Automatic Rollback**: Rollback if no improvement or tests fail
- ✅ **Before/After Metrics**: Quantifiable performance improvements
- ✅ **Performance Report**: Comprehensive report with optimization results

**Example Workflows**:
```bash
# Optimize bundle size (code splitting, tree shaking)
/agency:optimize bundle

# Optimize database queries (indexes, query optimization)
/agency:optimize database

# Optimize rendering performance (React.memo, virtual scrolling)
/agency:optimize rendering

# Optimize API performance (caching, batching)
/agency:optimize api

# Optimize memory usage (leak detection, GC tuning)
/agency:optimize memory

# Auto-detect optimization targets
/agency:optimize auto
```

**Phases** (7 total):
1. **Optimization Target Detection**: Parse target, get user confirmation
2. **Project Context Detection**: Detect framework/tools for profiling
3. **Performance Profiling & Baseline**: Run profiling tools, capture baseline
4. **Optimization Plan Creation**: Prioritize optimizations by impact
5. **Optimization Implementation**: Execute incrementally with benchmarking
6. **Verification & Regression Testing**: All tests pass, no regressions
7. **Performance Report**: Before/after metrics, recommendations

**Profiling Tools**:
- Bundle: webpack-bundle-analyzer, @next/bundle-analyzer
- Database: EXPLAIN ANALYZE, pg_stat_statements
- Rendering: Lighthouse, React DevTools Profiler
- API: autocannon, k6
- Memory: Chrome DevTools, heapdump, clinic.js

**Outputs**:
- Performance report: `.agency/optimizations/optimize-[target]-[date].md`
- Baseline data: `.agency/optimizations/baseline/`
- Benchmark data: `.agency/optimizations/benchmarks/`

---

### `/agency:document [topic]` - Documentation Generation

Generate comprehensive documentation with templates, validation, and quality review.

**Features**:
- ✅ **Template-Based Generation**: API, Architecture (ADR), Component, Feature, Code
- ✅ **Code Example Validation**: Verify all code examples compile and work
- ✅ **Link Validation**: Check all internal and external links
- ✅ **Quality Review**: Specialist agent reviews for accuracy and completeness
- ✅ **Auto-Publishing**: Save to appropriate docs directory with index updates
- ✅ **Documentation Report**: Generation log and quality metrics

**Example Workflows**:
```bash
# Generate API documentation (endpoints, request/response, examples)
/agency:document api

# Create Architecture Decision Record (ADR)
/agency:document architecture

# Document React/Vue components (props, usage, examples)
/agency:document component

# Document feature with user guide
/agency:document authentication

# Generate inline code docs (JSDoc/TypeDoc/Docstrings)
/agency:document code

# Auto-detect documentation type
/agency:document auto
```

**Phases** (5 total):
1. **Documentation Scope Detection**: Parse topic, analyze scope
2. **Project Context Detection**: Detect framework/doc system
3. **Documentation Generation**: Use templates, extract code examples
4. **Documentation Review**: Quality review, validate examples and links
5. **Validation & Publishing**: Validate, publish to docs directory

**Documentation Templates**:
- **API**: Endpoints, authentication, request/response, rate limiting, examples
- **Architecture (ADR)**: Context, decision, consequences, alternatives
- **Component**: Props, variants, states, accessibility, examples, tests
- **Feature**: User guide, implementation, API reference, configuration, troubleshooting
- **Code**: JSDoc/TypeDoc/Docstrings (inline documentation)

**Outputs**:
- Documentation files: `docs/api/`, `docs/components/`, `docs/architecture/`, etc.
- Documentation report: `.agency/documentation/doc-[topic]-[date].md`

---

## Workflow Skills

The plugin includes specialized knowledge skills that agents can reference:

- **Agency Workflow Patterns**: Orchestration and multi-agent coordination
- **GitHub Workflow Best Practices**: Branching, PRs, and sprint management
- **Code Review Standards**: Security, quality, and performance criteria
- **Testing Strategy & Standards**: Test frameworks and coverage standards

### Prompt Component System

The plugin uses a modular prompt component system located in `prompts/` that provides reusable workflow patterns for agents:

- **Context Detection** (`context/`) - Framework, testing tools, database, build tool detection
- **Specialist Selection** (`specialist-selection/`) - Keyword analysis, dependency detection, routing
- **Quality Gates** (`quality-gates/`) - Build verification, type checking, linting, testing, coverage
- **Git Operations** (`git/`) - Branch creation, commit formatting, PR creation, status validation
- **Issue Management** (`issue-management/`) - GitHub/Jira issue fetching, metadata extraction
- **Error Handling** (`error-handling/`) - Scope detection failures, tool errors, retry logic
- **Progress Tracking** (`progress/`) - Todo initialization, phase tracking, completion reporting
- **Reporting** (`reporting/`) - Summary templates, metrics comparison, artifact listing

These components enable consistent, high-quality execution across all commands and agents.

## Configuration

Create `.claude/agency.local.md` in your project for custom configuration:

```markdown
# Agency Plugin Configuration

## Default Models
- **Orchestrator**: sonnet
- **Planning Agents**: sonnet
- **Implementation Agents**: haiku
- **Review Agents**: opus

## GitHub Configuration
- **Default Branch**: main
- **Branch Prefix**: feature/
- **Auto-Create PR**: true

## Workflow Preferences
- **Auto-Approve Simple Plans**: false
- **Parallel Execution**: true
- **Auto-Run Tests**: true
- **Auto-Format**: true

## Quality Gates
- **Require Tests**: true
- **Min Coverage**: 80%
- **Require Build Pass**: true
```

## How It Works

### Orchestration Pattern

```
User Command → Orchestrator Agent → Specialist Agent(s) → Skills (Knowledge)
                     ↓
                 Hooks (Automation)
```

1. **User invokes command** (`/agency:work 123`)
2. **Orchestrator analyzes** request and creates execution plan
3. **Specialist agents** are spawned for specific tasks
4. **Skills provide** domain expertise and best practices
5. **Hooks automate** quality checks and formatting
6. **Results synthesized** and delivered to user

### Example Workflow

```bash
# User runs command
/agency:work 123

# Orchestrator creates plan
→ Fetch issue from GitHub
→ Create feature branch
→ Plan implementation (with Plan agent)
→ Review plan (with specialist reviewer)
→ Implement (with specialist coder)
→ Run tests (automated)
→ Code review (with review agent)
→ Commit and create PR

# All automated, user approves at key checkpoints
```

## Advanced Features

### Parallel Execution

```bash
# Find issues that can be worked in parallel
/agency:gh-parallel

# Create worktrees for parallel work
/agency:gh-worktree 123
/agency:gh-worktree 124
/agency:gh-worktree 125

# Multiple Claude instances can work simultaneously
```

### Hooks & Automation

Optional hooks for automated quality checks:
- **Auto-format on edit**: Prettier/ESLint integration
- **Auto-lint**: Linting on file changes
- **Pre-commit validation**: Tests before commits
- **Build verification**: Type checking

## Requirements

- Claude Code CLI
- Git (for GitHub/Jira workflows)
- GitHub CLI (`gh`) for GitHub integration
- Node.js/Python/etc. (depending on project type)

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](../../LICENSE)

## Support

- **Issues**: [GitHub Issues](https://github.com/squirrelsoft-dev/squirrelsoft-marketplace/issues)
- **Marketplace**: [Squirrelsoft Marketplace](https://github.com/squirrelsoft-dev/squirrelsoft-marketplace)

## Changelog

### 0.1.0 (Initial Release)
- 51+ specialized agents across 8 categories
- Core workflow commands
- GitHub and Jira integration
- Intelligent orchestration
- Workflow skills and best practices
- Quality automation hooks

---

**Built with ❤️ by Squirrelsoft Dev Tools**
