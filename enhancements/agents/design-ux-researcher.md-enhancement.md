# Agent Enhancement: UX Researcher

## Current State

**File**: `design/design-ux-researcher.md`
**Name**: `UX Researcher`
**Description**: `Expert user experience researcher specializing in user behavior analysis, usability testing, and data-driven design insights. Provides actionable research findings that improve product usability and user satisfaction`

## Proposed Changes

### Better Name
**Proposed**: `design-ux-research-analyst`
**Rationale**: Emphasizes both research and analysis capabilities, following the pattern of role specification.

### Better Description
**Proposed**: `Conducts user research, usability testing, and behavioral analysis to validate design decisions with data-driven insights. Creates user personas, journey maps, and actionable recommendations from empirical research. Use when validating product-market fit, testing usability, or understanding user behavior patterns.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Conducts research studies and analyzes findings
- `/agency:plan` - Creates research roadmaps and study protocols
- `/agency:document` - Generates research reports and persona documentation
- `/agency:test` - Designs and executes usability tests
- `/agency:review` - Reviews product features for UX issues and opportunities

## Enhancement Recommendations

### Capability Enhancements
- **Analytics integration**: Auto-analyze user behavior from Google Analytics, Mixpanel, etc.
- **Survey automation**: Generate and deploy user surveys with analysis
- **Heatmap analysis**: Integrate with Hotjar, Clarity for behavioral insights
- **A/B test analysis**: Statistical analysis of experiment results
- **Sentiment analysis**: Analyze user feedback and reviews for insights
- **Accessibility research**: User testing with assistive technologies
- **Competitive analysis**: Systematic UX competitor analysis frameworks

### Skill References
Should reference these workflow skills when available:
- `user-research-framework` - Methodology for different research types
- `statistical-analysis-tools` - For quantitative research analysis
- `persona-generator` - For creating data-driven user personas
- `journey-mapping-tools` - For comprehensive journey visualization

### Tool Access
Current tools seem appropriate, but consider adding:
- **Analytics API access**: To pull and analyze usage data
- **Survey tools**: Integration with Typeform, Google Forms, etc.
- **Session recording tools**: Access to user session recordings
- **Statistical analysis tools**: For quantitative research

### Quality Improvements
- Add specific research methodology selection guides (when to use what method)
- Include sample size calculators and statistical significance testing
- Provide templates for different research types (interviews, surveys, usability tests)
- Add remote research best practices and tools
- Include ethical research guidelines and consent templates
- Provide frameworks for international/cross-cultural research
- Add examples of research repositories and knowledge management
- Include stakeholder presentation templates for research findings
- Provide continuous research program frameworks (not just one-off studies)

## Implementation Priority
**Priority**: Medium
**Rationale**: Important for data-driven design decisions but typically used earlier in product lifecycle or periodically rather than continuously. Should integrate well with product and design agents.
