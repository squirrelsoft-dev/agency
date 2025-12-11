# Agent Enhancement: ArchitectUX

## Current State

**File**: `design/design-ux-architect.md`
**Name**: `ArchitectUX`
**Description**: `Technical architecture and UX specialist who provides developers with solid foundations, CSS systems, and clear implementation guidance`

## Proposed Changes

### Better Name
**Proposed**: `design-technical-ux-architect`
**Rationale**: Clarifies the technical bridge role between design and development. Current name "ArchitectUX" is less clear than following the standard pattern.

### Better Description
**Proposed**: `Bridges design and development by creating CSS architecture, layout systems, and UX structure specifications. Provides developers with ready-to-implement foundations including design tokens, responsive frameworks, and component hierarchies. Use when establishing technical design foundations or creating developer-ready specifications.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Implements CSS architecture and layout frameworks
- `/agency:plan` - Creates technical UX implementation roadmaps
- `/agency:document` - Generates CSS architecture documentation
- `/agency:refactor` - Refactors existing CSS to modern architecture patterns
- `/agency:optimize` - Optimizes CSS performance and bundle size

## Enhancement Recommendations

### Capability Enhancements
- **Automated CSS generation**: Generate complete CSS design system from specifications
- **Framework integration**: Provide Tailwind config, CSS modules, or styled-components output
- **Layout generator**: Create responsive layout templates with Grid/Flexbox
- **Theme system automation**: Auto-generate light/dark/system theme implementations
- **CSS performance analysis**: Analyze and optimize CSS for production builds
- **Component naming conventions**: Establish and enforce BEM, SMACSS, or similar methodologies

### Skill References
Should reference these workflow skills when available:
- `tailwindcss-4-expert` - For modern CSS framework architecture
- `nextjs-16-expert` - For Next.js-specific CSS integration patterns
- `accessibility-wcag-validator` - For CSS accessibility compliance
- `css-performance-optimizer` - For production CSS optimization

### Tool Access
Current tools seem appropriate, but consider adding:
- **CSS generation tools**: Automated design token to CSS conversion
- **Layout generator tools**: Create responsive layout templates
- **CSS analysis tools**: Bundle size and performance analysis
- **Theme generator tools**: Multi-theme system creation

### Quality Improvements
- Add more comprehensive CSS architecture examples (BEM, SMACSS, OOCSS)
- Include CSS-in-JS alternatives (styled-components, emotion, vanilla-extract)
- Provide mobile-first responsive patterns with specific breakpoint strategies
- Add CSS performance optimization guidelines and budgets
- Include examples of CSS custom property (variable) organization
- Add integration examples for popular CSS frameworks (Tailwind, UnoCSS, etc.)
- Provide CSS module naming and organization best practices
- Include animation performance guidelines (GPU acceleration, will-change usage)

## Implementation Priority
**Priority**: High
**Rationale**: This agent is critical for developer productivity and design-to-code handoff quality. Strong integration with engineering agents needed, especially frontend developers.
