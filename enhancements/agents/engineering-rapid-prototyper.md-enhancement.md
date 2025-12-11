# Agent Enhancement: Rapid Prototyper

## Current State

**File**: `engineering/engineering-rapid-prototyper.md`
**Name**: `Rapid Prototyper`
**Description**: `Specialized in ultra-fast proof-of-concept development and MVP creation using efficient tools and frameworks`

## Proposed Changes

### Better Name
**Proposed**: `engineering-mvp-rapid-developer`
**Rationale**: Emphasizes MVP creation which is more business-relevant than "prototyper". Makes the speed focus clear.

### Better Description
**Proposed**: `Rapidly builds functional MVPs and proof-of-concepts in days using modern rapid development stacks. Focuses on validating core hypotheses with minimal features, built-in analytics, and user feedback collection. Use when validating ideas quickly, building MVPs, or testing product-market fit.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Implements MVP features and prototypes
- `/agency:plan` - Creates rapid development plans and hypothesis validation
- `/agency:test` - Implements A/B testing and user validation
- `/agency:document` - Creates lightweight prototype documentation
- `/agency:optimize` - Optimizes prototypes for production transition

## Enhancement Recommendations

### Capability Enhancements
- **Template library**: Pre-built templates for common MVP types (SaaS, marketplace, etc.)
- **Rapid stack generator**: Auto-configure optimal tech stack for use case
- **Analytics auto-setup**: Automatic GA4, Mixpanel, PostHog integration
- **User feedback collection**: Built-in feedback widgets and survey tools
- **A/B testing framework**: Simple experimentation setup
- **Payment integration**: Rapid Stripe, Paddle integration for validation
- **No-code integration**: Zapier, Make integration for backend automation
- **Prototype-to-production**: Migration guides and refactoring paths

### Skill References
Should reference these workflow skills when available:
- `nextjs-16-expert` - For rapid full-stack development
- `supabase-latest-expert` - For instant backend setup
- `shadcn-latest-expert` - For rapid UI component development
- `prisma-latest-expert` - For quick database setup
- `fastmcp-2-expert` - For rapid API development

### Tool Access
Current tools seem appropriate, but consider adding:
- **Deployment tools**: One-command deployment to Vercel, Netlify
- **Analytics tools**: Quick setup for tracking and metrics
- **Survey tools**: User feedback and testing integration
- **Payment tools**: Rapid payment processing setup
- **No-code tools**: Integration with automation platforms

### Quality Improvements
- Add decision trees for tech stack selection based on requirements
- Include templates for different MVP types with example timelines
- Provide hypothesis validation frameworks and metrics
- Add examples of successful MVP-to-product transitions
- Include technical debt management strategies for fast-moving projects
- Provide guidelines for when to use no-code vs. code
- Add user testing frameworks for rapid validation
- Include cost optimization for prototype infrastructure
- Provide examples of 3-day MVP builds with specific features
- Add templates for investor demos and user testing sessions

## Implementation Priority
**Priority**: Medium
**Rationale**: Valuable for early-stage product development and validation. Not needed for established products. Should coordinate with product managers and UX researchers for validation strategies.
