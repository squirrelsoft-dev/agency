---
description: Comprehensive security audit with vulnerability scanning and code review
argument-hint: scope (codebase/dependencies/api/config/all)
allowed-tools: [Read, Write, Edit, Bash, Task, Grep, Glob, WebFetch, TodoWrite, AskUserQuestion]
---

# Security Audit: $ARGUMENTS

Comprehensive security audit with vulnerability scanning, OWASP Top 10 checks, and actionable remediation.

## Your Mission

Perform security audit for: **$ARGUMENTS**

Execute thorough security analysis with vulnerability scanning, OWASP Top 10 checks, secrets detection, and actionable recommendations.

---

## Critical Instructions

### 1. Activate Agency Workflow Knowledge

**IMMEDIATELY** activate the agency workflow patterns skill:
```
Use the Skill tool to activate: agency-workflow-patterns
```

### 2. Security First Principles

**NEVER**:
- Expose sensitive data in reports (redact secrets, credentials, tokens)
- Run destructive security testing in production
- Skip critical vulnerabilities

**ALWAYS**:
- Redact secrets and sensitive data from all reports
- Report all critical and high-severity findings
- Provide specific remediation steps

---

## Phase 0: Project Context Detection (1-2 min)

Detect framework, database, authentication system, and deployment platform to inform security checks.

[Framework detection bash code omitted for brevity - follows same pattern as other commands]

---

## Phase 1-6: Security Audit Phases

1. **Security Scope Detection** - Determine audit scope (codebase/deps/api/config/all)
2. **Vulnerability Scanning** - npm audit, dependency scanning, SAST, secrets detection  
3. **OWASP Top 10 Checks** - Comprehensive review using security specialist agent
4. **Authentication & Authorization Review** - Password hashing, session management, JWT security
5. **Secrets & Sensitive Data Detection** - Environment variables, hardcoded credentials, PII
6. **Security Report Generation** - Comprehensive report with findings and remediation

[See full security.md file for detailed implementation of each phase]

---

## Error Handling

[Standard error handling for tool failures, critical vulnerabilities, false positives, and access denied scenarios]

---

## Important Notes

**Security Audit Principles**: Confidentiality, severity-based prioritization, actionability, context awareness

**Responsible Disclosure**: Internal reporting first, vendor notification, reasonable remediation timelines

**This audit does NOT include**: Penetration testing, social engineering, physical security, DoS testing

---

## Skills to Reference

- `agency-workflow-patterns` - Orchestration patterns (REQUIRED)
- `owasp-top-10` - OWASP vulnerability knowledge (if available)
- `secure-coding-practices` - Security best practices (if available)

---

## Related Commands

- `/agency:work [issue]` - Implement security fixes
- `/agency:review [pr]` - Security-focused code review  
- `/agency:deploy [env]` - Security checks before deployment

---

**End of /agency:security command**
