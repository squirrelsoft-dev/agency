# Quality Gate: Security Scan (Quick)

**Gate Priority**: RECOMMENDED (Gate 6)
**Blocking**: PARTIAL - Critical vulnerabilities block, others warn
**Max Retry Attempts**: 2

## Purpose

Perform quick security scans to identify vulnerabilities in dependencies, detect secrets/credentials in code, and catch common security issues before deployment.

## Framework-Specific Commands

### JavaScript/TypeScript

```bash
# npm audit (built-in)
npm audit

# npm audit fix (auto-fix)
npm audit fix

# npm audit (production only)
npm audit --production

# npm audit (JSON format for parsing)
npm audit --json

# pnpm
pnpm audit

# yarn
yarn audit

# yarn audit fix
yarn audit fix
```

### Python

```bash
# pip-audit (modern, maintained)
pip-audit

# pip-audit with fix suggestions
pip-audit --fix

# Safety (dependency security scanner)
safety check

# Safety with detailed output
safety check --detailed-output

# Bandit (code security scanner)
bandit -r src/ -f json

# Bandit with severity threshold
bandit -r src/ -ll  # Only medium/high severity
```

### Rust

```bash
# cargo-audit
cargo audit

# cargo-audit with fix
cargo audit fix

# cargo-deny
cargo deny check advisories
```

### Go

```bash
# govulncheck (official tool)
govulncheck ./...

# nancy (dependency scanner)
nancy sleuth

# gosec (code security scanner)
gosec ./...
```

### Ruby

```bash
# bundler-audit
bundle audit

# bundler-audit with update
bundle audit --update

# brakeman (Rails security scanner)
brakeman
```

### Java/Kotlin

```bash
# OWASP Dependency Check (Maven)
mvn org.owasp:dependency-check-maven:check

# OWASP Dependency Check (Gradle)
./gradlew dependencyCheckAnalyze
```

## Secrets Detection

### General Purpose Tools

```bash
# gitleaks (secrets scanner)
gitleaks detect --source . --verbose

# trufflehog (secrets scanner)
trufflehog filesystem . --json

# detect-secrets
detect-secrets scan

# git-secrets
git secrets --scan

# Custom grep for common secrets
grep -r -E '(API_KEY|SECRET|PASSWORD|TOKEN).*=.*["\'][a-zA-Z0-9]{20,}' . --exclude-dir=node_modules --exclude-dir=.git
```

## Pass/Fail Criteria

### PASS Criteria
- No critical vulnerabilities
- No high-severity vulnerabilities in production dependencies
- No secrets/credentials detected in code
- All security warnings reviewed and documented

### WARN Criteria (NON-BLOCKING)
- Moderate severity vulnerabilities
- Vulnerabilities in dev dependencies only
- Vulnerabilities with no available fix
- Low-severity issues

### FAIL Criteria (BLOCKING)
- Critical vulnerabilities (CVSS ≥ 9.0)
- High severity vulnerabilities (CVSS ≥ 7.0) in production
- Secrets/credentials in code (API keys, passwords, tokens)
- Known malware in dependencies

## Vulnerability Severity Levels

### CRITICAL (CVSS 9.0-10.0)
- **Impact**: Remote code execution, privilege escalation, data breach
- **Action**: BLOCK deployment, fix immediately
- **Example**: RCE in core dependency, SQL injection vulnerability

### HIGH (CVSS 7.0-8.9)
- **Impact**: Significant security risk, potential data exposure
- **Action**: BLOCK deployment (production deps), fix before merge
- **Example**: XSS vulnerability, authentication bypass

### MODERATE (CVSS 4.0-6.9)
- **Impact**: Moderate security risk, limited exploit potential
- **Action**: WARN, fix in next sprint
- **Example**: Information disclosure, DoS vulnerability

### LOW (CVSS 0.1-3.9)
- **Impact**: Minimal security risk
- **Action**: WARN, fix when convenient
- **Example**: Minor information leak, low-impact DoS

## Execution Flow

1. **Detect Package Manager & Language**
   - Check for package.json, requirements.txt, Cargo.toml, etc.
   - Identify appropriate security scanning tools
   - Verify tools are installed

2. **Run Dependency Audit**
   - Execute audit command (npm audit, pip-audit, etc.)
   - Parse audit results
   - Categorize vulnerabilities by severity

3. **Run Secrets Detection**
   - Scan codebase for secrets
   - Check for common secret patterns
   - Verify .env files not committed
   - Check for credential files

4. **Analyze Results**
   - Count vulnerabilities by severity
   - Identify fixable vulnerabilities
   - Check for known exploits
   - Assess production vs dev dependency impact

5. **Generate Fix Recommendations**
   - Suggest version upgrades
   - Identify alternative packages
   - Recommend security patches
   - Provide mitigation strategies

## Security Issue Analysis

### Dependency Vulnerabilities

#### Critical/High in Production Dependencies
```
Pattern: Critical/High severity CVE in production dependency
Impact: CRITICAL - Blocks deployment
Action:
1. Run auto-fix: npm audit fix
2. If auto-fix unavailable, manually upgrade package
3. If no fix available, consider alternative package
4. Document workaround if fix not possible
5. Add to security exceptions with justification

Retry: After applying fixes
```

#### Moderate/Low Severity
```
Pattern: Moderate/Low severity vulnerabilities
Impact: WARN - Does not block
Action:
1. Document vulnerability in report
2. Plan fix in next sprint
3. Monitor for severity escalation
4. Apply fix when available

Retry: Not required, proceed with warning
```

#### Vulnerabilities in Dev Dependencies
```
Pattern: Vulnerabilities in devDependencies
Impact: LOW - Less critical than production
Action:
1. Assess if dev vulnerability affects CI/CD
2. Fix if trivial (auto-fix available)
3. Otherwise, document and plan fix
4. May proceed with warning

Retry: Optional, based on severity
```

### Secrets Detection

#### API Keys / Tokens
```
Pattern: Hard-coded API keys, tokens, or secrets
Examples:
- API_KEY = "sk_live_1234567890abcdef"
- const token = "ghp_AbCdEf1234567890"
- password = "MySecretP@ssw0rd"

Impact: CRITICAL - Blocks deployment
Action:
1. Remove secret from code immediately
2. Move to environment variables
3. Rotate/revoke exposed credential
4. Add .env to .gitignore
5. Use git filter-branch to remove from history (if committed)

Retry: After removing secrets
```

#### Private Keys / Certificates
```
Pattern: Private keys, certificates, or SSH keys in code
Examples:
- -----BEGIN RSA PRIVATE KEY-----
- -----BEGIN CERTIFICATE-----
- SSH private key files

Impact: CRITICAL - Blocks deployment
Action:
1. Remove from codebase immediately
2. Revoke and regenerate keys
3. Store in secure secret management system
4. Clean git history

Retry: After removing and revoking keys
```

#### Database Credentials
```
Pattern: Database connection strings with credentials
Examples:
- postgresql://user:password@localhost:5432/db
- mongodb://admin:secret@host:27017

Impact: CRITICAL - Blocks deployment
Action:
1. Remove connection string
2. Use environment variables
3. Rotate database credentials
4. Implement credential management

Retry: After removing credentials
```

## Auto-Fix Strategy

1. **Safe Auto-Fixes** (Automated)
   - Patch version updates (1.2.3 → 1.2.4)
   - Minor version updates with clear changelog
   - Dev dependency updates

2. **Review Required** (Manual)
   - Major version updates (1.x → 2.x)
   - Breaking changes possible
   - Multiple packages affected

3. **Cannot Auto-Fix** (Manual Investigation)
   - No fix available yet
   - Vulnerability in transitive dependency
   - Breaking changes in fix
   - Alternative package needed

## Retry Logic

```pseudo
attempt = 0
max_attempts = 2

while attempt < max_attempts:
    # Run dependency audit
    audit_result = run_dependency_audit()

    # Run secrets detection
    secrets_result = run_secrets_detection()

    # Analyze results
    critical_vulns = count_critical_vulnerabilities(audit_result)
    high_vulns = count_high_vulnerabilities(audit_result)
    secrets_found = count_secrets(secrets_result)

    # Check for blocking issues
    if critical_vulns == 0 and high_vulns == 0 and secrets_found == 0:
        report_success(audit_result, secrets_result)
        return PASS

    attempt += 1

    if attempt < max_attempts:
        if secrets_found > 0:
            report_secrets(secrets_result)
            prompt_user_to_remove_secrets()
            wait_for_user_confirmation()

        if critical_vulns > 0 or high_vulns > 0:
            # Try auto-fix
            auto_fix_result = run_audit_fix()

            if auto_fix_result.success:
                continue  # Retry scan after auto-fix
            else:
                report_unfixable_vulnerabilities()
                prompt_user_for_manual_fix()
                wait_for_user_confirmation()
    else:
        # Max attempts reached
        if secrets_found > 0:
            report_failure("Secrets still present in code")
            return FAIL

        if critical_vulns > 0:
            report_failure("Critical vulnerabilities unresolved")
            prompt_user_for_exception_or_rollback()
            return FAIL

        if high_vulns > 0:
            report_warning("High vulnerabilities remain")
            # May proceed with explicit user approval
            return WARN
```

## Blocking Behavior

**This gate is PARTIALLY BLOCKING**

- Runs only AFTER Gate 5 (Coverage Validation) completes
- **BLOCKS on**:
  - Critical vulnerabilities (CVSS ≥ 9.0)
  - High vulnerabilities (CVSS ≥ 7.0) in production dependencies
  - Secrets/credentials detected in code
- **WARNS on**:
  - Moderate/Low vulnerabilities
  - Vulnerabilities in dev dependencies
  - Vulnerabilities with no available fix
- User can override warnings with documented justification
- Secrets detection ALWAYS blocks (no override)

## Success Reporting

```markdown
### Security Scan: ✅ PASS

- Dependency Audit: npm audit / pip-audit / cargo audit
- Secrets Detection: gitleaks / trufflehog
- Dependencies Scanned: [count]
- Vulnerabilities Found: 0 critical, 0 high, [X] moderate, [Y] low
- Secrets Detected: 0
- Scan Time: [X.X seconds]

**Moderate/Low Vulnerabilities** (if any):
- [package-name] v[version]: [vulnerability description] (Severity: MODERATE/LOW)
  - CVSS Score: [score]
  - Fix Available: Yes/No
  - Recommended Action: [action]
```

## Warning Reporting

```markdown
### Security Scan: ⚠️ WARN

- Dependency Audit: npm audit / pip-audit / cargo audit
- Secrets Detection: gitleaks / trufflehog
- Dependencies Scanned: [count]
- **Vulnerabilities Found**: [X] moderate, [Y] low
- Secrets Detected: 0

**Moderate Severity Vulnerabilities** ([count]):
1. **[package-name]** v[version]
   - Vulnerability: [CVE-XXXX-XXXX] [description]
   - CVSS Score: [score]
   - Affected Versions: [range]
   - Fix Available: [version] or [No fix available]
   - Recommendation: Upgrade to [version] or [mitigation strategy]

2. **[package-name]** v[version]
   ...

**Low Severity Vulnerabilities** ([count]):
[Similar format as above]

**Recommended Actions**:
1. Plan fixes for moderate vulnerabilities in next sprint
2. Monitor for security updates
3. Consider alternative packages if no fix available

**Note**: Non-blocking. Proceed with deployment, but address vulnerabilities soon.
```

## Failure Reporting

```markdown
### Security Scan: ❌ FAIL

- Dependency Audit: npm audit / pip-audit / cargo audit
- Secrets Detection: gitleaks / trufflehog
- Attempt: [X/2]
- **Critical Vulnerabilities**: [count]
- **High Vulnerabilities**: [count]
- **Secrets Detected**: [count]
- **Status**: BLOCKING

**Critical Vulnerabilities** ([count]):
1. **[package-name]** v[version]
   - Vulnerability: [CVE-XXXX-XXXX] [description]
   - CVSS Score: [score] (CRITICAL)
   - Severity: Critical
   - Exploit Available: Yes/No
   - Affected Versions: [range]
   - Fix Available: [version] or [No fix available]
   - **Action Required**: IMMEDIATE FIX REQUIRED

**High Vulnerabilities** ([count]):
[Similar format as Critical]

**Secrets Detected** ([count]):
1. **[file path]**:[line]
   - Type: API Key / Private Key / Password / Token
   - Pattern: [matched pattern]
   - **Action Required**: REMOVE IMMEDIATELY and ROTATE CREDENTIAL

**Auto-Fix Attempted**: Yes/No
**Auto-Fix Success**: Yes/No

**Immediate Actions Required**:
1. Remove all secrets from code
2. Rotate/revoke exposed credentials
3. Upgrade vulnerable packages: npm audit fix
4. Manually upgrade packages without auto-fix
5. If no fix available, consider alternative packages or mitigation

**Next Steps**:
1. [Specific action for highest priority issue]
2. [Specific action for next issue]
3. Re-run security scan
4. DO NOT DEPLOY until resolved
```

## Integration with Quality Gate Sequence

This is **Gate 6** in the quality gate sequence:

```
Gate 1: Build Verification → BLOCKING ✅ (prerequisite)
Gate 2: Type Checking → BLOCKING ✅ (prerequisite)
Gate 3: Linting → HIGH PRIORITY ✅ (prerequisite)
Gate 4: Test Execution → BLOCKING ✅ (prerequisite)
Gate 5: Coverage Validation → RECOMMENDED ✅ (prerequisite)
Gate 6: Security Scan (Quick) (THIS GATE) → RECOMMENDED
```

**Sequential Execution**: Runs after Gate 5 completes, may block deployment based on findings.

## Special Considerations

### False Positives
- Some vulnerabilities may not apply to your use case
- Document false positives with justification
- Use audit ignore/exception mechanisms carefully
- Re-evaluate exceptions periodically

### Transitive Dependencies
- Vulnerabilities in dependencies of dependencies
- May require updating parent package
- Sometimes no fix available without major refactor
- Document and monitor

### Zero-Day Vulnerabilities
- Newly discovered vulnerabilities without fixes
- Implement workarounds/mitigations
- Monitor for security updates
- Consider alternative packages

### Security Exceptions
- Document exceptions in security policy
- Require approval for exceptions
- Set expiration date for exceptions
- Re-evaluate regularly

### Performance Considerations
- Dependency audits are generally fast (< 30s)
- Secrets scanning depends on codebase size
- Cache audit results when possible
- Run comprehensive scans in CI/CD, quick scans locally

### Monorepo Considerations
- Run security scans per package
- Aggregate vulnerabilities across packages
- Identify shared vulnerable dependencies
- Coordinate fixes across packages

### Production vs Development
- Prioritize production dependency vulnerabilities
- Dev dependency vulnerabilities less critical
- Test/build tools still important for supply chain security

## Related Quality Gates

- **Coverage Validation (Gate 5)**: Runs before security scan
- **Rollback on Failure (Gate 7)**: Triggered if critical security issues cannot be resolved
