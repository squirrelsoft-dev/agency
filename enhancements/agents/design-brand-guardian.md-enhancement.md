# Agent Enhancement: Brand Guardian

## Current State

**File**: `design/design-brand-guardian.md`
**Name**: `Brand Guardian`
**Description**: `Expert brand strategist and guardian specializing in brand identity development, consistency maintenance, and strategic brand positioning`

## Proposed Changes

### Better Name
**Proposed**: `design-brand-strategy-guardian`
**Rationale**: More descriptive and follows the pattern of category-specialty-role. Clarifies that this is both strategic and protective in nature.

### Better Description
**Proposed**: `Creates and protects comprehensive brand identities through strategic brand development, visual identity systems, and consistency enforcement. Use when defining brand foundations, developing brand guidelines, or ensuring brand compliance across projects.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:document` - Generates brand guidelines and style documentation
- `/agency:work` - Implements brand systems and identity frameworks
- `/agency:review` - Reviews brand implementation for consistency compliance
- `/agency:plan` - Creates strategic brand development roadmaps

## Enhancement Recommendations

### Capability Enhancements
- **Integration with design systems**: Should collaborate with `design-ui-designer` for brand token implementation
- **Brand audit automation**: Add capability to scan codebases for brand consistency violations
- **Multi-brand management**: Extend to handle sub-brands and white-label scenarios
- **Brand evolution tracking**: Add version control for brand guidelines with migration paths

### Skill References
Should reference these workflow skills when available:
- `design-system-generator` - For implementing brand tokens in code
- `documentation-generator` - For creating comprehensive brand guides
- `style-guide-validator` - For automated brand compliance checking

### Tool Access
Current tools seem appropriate, but consider adding:
- **File analysis tools**: To audit brand usage across projects
- **Image generation tools**: For brand asset creation and variations
- **Documentation tools**: Enhanced markdown/PDF generation for brand guides

### Quality Improvements
- Add examples of brand audit reports and compliance scorecards
- Include templates for brand evolution proposals and refresh strategies
- Provide frameworks for measuring brand equity and recognition
- Add guidelines for brand crisis management and reputation recovery
- Include cross-cultural brand adaptation strategies

## Implementation Priority
**Priority**: High
**Rationale**: Brand strategy is foundational to all design work. This agent needs strong integration with other design agents and clear workflows for brand implementation and enforcement.
