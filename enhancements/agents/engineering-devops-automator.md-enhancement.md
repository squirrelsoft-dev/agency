# Agent Enhancement: DevOps Automator

## Current State

**File**: `engineering/engineering-devops-automator.md`
**Name**: `DevOps Automator`
**Description**: `Expert DevOps engineer specializing in infrastructure automation, CI/CD pipeline development, and cloud operations`

## Proposed Changes

### Better Name
**Proposed**: `engineering-devops-automation-engineer`
**Rationale**: More professional naming while maintaining the automation focus. "Automator" is less standard than "Engineer" in titles.

### Better Description
**Proposed**: `Automates infrastructure deployment, CI/CD pipelines, and cloud operations for reliable, scalable systems. Implements Infrastructure as Code, zero-downtime deployments, monitoring, and security automation. Use when setting up CI/CD, automating infrastructure, or implementing deployment strategies.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Implements infrastructure and pipelines
- `/agency:plan` - Creates infrastructure and deployment roadmaps
- `/agency:optimize` - Optimizes infrastructure costs and performance
- `/agency:test` - Creates infrastructure testing and validation
- `/agency:document` - Generates infrastructure documentation and runbooks
- `/agency:review` - Reviews infrastructure code and security configurations

## Enhancement Recommendations

### Capability Enhancements
- **Multi-cloud support**: AWS, GCP, Azure infrastructure patterns
- **GitOps automation**: ArgoCD, Flux for declarative deployments
- **Secrets management**: Vault, AWS Secrets Manager automation
- **Cost optimization**: Automated resource right-sizing and spot instance usage
- **Compliance automation**: CIS benchmarks, PCI-DSS compliance checking
- **Disaster recovery testing**: Automated DR drill execution
- **Infrastructure testing**: Terratest, InSpec for infrastructure validation
- **Container security**: Trivy, Clair for image scanning

### Skill References
Should reference these workflow skills when available:
- `docker-kubernetes-expert` - For container orchestration
- `terraform-iac-patterns` - For infrastructure as code
- `github-actions-expert` - For CI/CD automation
- `monitoring-observability` - For system monitoring
- `security-scanning-tools` - For automated security

### Tool Access
Current tools seem appropriate, but consider adding:
- **Cloud CLI tools**: AWS CLI, gcloud, az for cloud management
- **Container tools**: Docker, kubectl for container operations
- **Monitoring tools**: Prometheus queries, log aggregation
- **Security tools**: Vulnerability scanning and compliance checking
- **Infrastructure testing tools**: Validation and testing frameworks

### Quality Improvements
- Add specific examples for different cloud providers (not just AWS)
- Include Kubernetes patterns and best practices (StatefulSets, operators, etc.)
- Provide cost optimization strategies with real examples
- Add security hardening checklists for different environments
- Include disaster recovery runbooks and testing procedures
- Provide monitoring and alerting templates for different service types
- Add examples of successful zero-downtime deployment strategies
- Include infrastructure testing examples (unit, integration, end-to-end)
- Provide secrets rotation automation examples
- Add compliance automation for different standards (SOC2, HIPAA, etc.)

## Implementation Priority
**Priority**: High
**Rationale**: DevOps automation is critical for modern development workflows and system reliability. Affects entire engineering team productivity. Should integrate closely with all engineering agents.
