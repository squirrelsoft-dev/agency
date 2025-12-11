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

### Work on a GitHub Issue

```bash
# Work on issue #123
/agency:work 123

# Work on next available issue
/agency:work next
```

### Implement an Entire Sprint

```bash
# Implement all issues in current sprint
/agency:gh-sprint

# Triage issues first
/agency:gh-triage
```

### Code Review & Quality

```bash
# Comprehensive code review
/agency:review

# Generate tests for current changes
/agency:test

# Security audit
/agency:security
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

### Core Workflow
- `/agency:work` - Work any issue (auto-detects GitHub/Jira)
- `/agency:plan` - Create implementation plan only
- `/agency:implement` - Implement from existing plan

### GitHub Workflows
- `/agency:gh-sprint` - Implement entire GitHub sprint
- `/agency:gh-triage` - Triage GitHub issues
- `/agency:gh-parallel` - Find parallelizable issues
- `/agency:gh-worktree` - Create worktree for issue

### Jira Workflows
- `/agency:jira-sprint` - Implement entire Jira sprint
- `/agency:jira-triage` - Triage Jira issues

### Quality & Review
- `/agency:review` - Comprehensive code review
- `/agency:test` - Generate comprehensive tests
- `/agency:security` - Security audit workflow

### Optimization
- `/agency:optimize` - Performance optimization
- `/agency:refactor` - Refactoring workflow

### Documentation
- `/agency:document` - Generate documentation
- `/agency:adr` - Create Architecture Decision Record

## Workflow Skills

The plugin includes specialized knowledge skills that agents can reference:

- **Agency Workflow Patterns**: Orchestration and multi-agent coordination
- **GitHub Workflow Best Practices**: Branching, PRs, and sprint management
- **Code Review Standards**: Security, quality, and performance criteria
- **Testing Strategy & Standards**: Test frameworks and coverage standards

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
