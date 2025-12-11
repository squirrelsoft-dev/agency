# Question 1: Command Priority Selection

## Context
We have 15+ proposed agency commands across different categories. Need to prioritize which commands to implement first.

## Question
Which commands are highest priority to create first?

## Proposed Commands

### Core Workflow Commands
- `/agency:work` - Work any issue (auto-detects GitHub/Jira)
- `/agency:plan` - Create implementation plan only
- `/agency:implement` - Implement from existing plan

### GitHub-Specific Commands
- `/agency:gh-sprint` - Implement entire GitHub sprint
- `/agency:gh-triage` - Triage GitHub issues
- `/agency:gh-parallel` - Find parallelizable GitHub issues
- `/agency:gh-worktree` - Create worktree for issue

### Jira-Specific Commands
- `/agency:jira-sprint` - Implement entire Jira sprint
- `/agency:jira-triage` - Triage Jira issues

### Quality & Review Commands
- `/agency:review` - Comprehensive code review
- `/agency:test` - Generate comprehensive tests
- `/agency:security` - Security audit workflow

### Optimization Commands
- `/agency:optimize` - Performance optimization
- `/agency:refactor` - Refactoring workflow

### Documentation Commands
- `/agency:document` - Generate documentation
- `/agency:adr` - Create Architecture Decision Record

## Recommendation
Suggest implementing 5-8 core commands first, then expanding based on usage.

## Decision Needed
- Which 5-8 commands should be Phase 1 priority?
- Which can wait for Phase 2?
- Any commands that should be combined or split?

## Status
**Status**: Open
**Priority**: High
**Blocking**: Phase 5 (Component Implementation)
