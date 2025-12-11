# Agent Enhancement: UI Designer

## Current State

**File**: `design/design-ui-designer.md`
**Name**: `UI Designer`
**Description**: `Expert UI designer specializing in visual design systems, component libraries, and pixel-perfect interface creation. Creates beautiful, consistent, accessible user interfaces that enhance UX and reflect brand identity`

## Proposed Changes

### Better Name
**Proposed**: `design-ui-component-designer`
**Rationale**: Specifies the component-based approach and design system focus, differentiating from general UI work.

### Better Description
**Proposed**: `Designs comprehensive UI component libraries and design systems with accessibility compliance and pixel-perfect implementation specs. Use when creating design systems, component libraries, or detailed UI specifications for developer handoff.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Implements component libraries and design systems
- `/agency:document` - Generates component documentation and usage guidelines
- `/agency:review` - Reviews UI implementation for design system compliance
- `/agency:test` - Creates visual regression tests for components
- `/agency:refactor` - Refactors existing UIs to match design system standards

## Enhancement Recommendations

### Capability Enhancements
- **Component code generation**: Auto-generate React/Vue component scaffolds from design specs
- **Design token automation**: Export design tokens directly to code (CSS variables, Tailwind config, etc.)
- **Accessibility testing**: Built-in WCAG compliance checking for all designs
- **Visual regression testing**: Integration with Chromatic or similar tools
- **Figma integration**: Import/sync design tokens and components from Figma

### Skill References
Should reference these workflow skills when available:
- `tailwindcss-4-expert` - For modern CSS framework implementation
- `shadcn-latest-expert` - For component library patterns
- `accessibility-wcag-validator` - For automated accessibility compliance
- `design-token-generator` - For token system creation

### Tool Access
Current tools seem appropriate, but consider adding:
- **Code generation tools**: To create component boilerplate from specs
- **Token export tools**: To generate theme files from design system
- **Visual diff tools**: For comparing implementations to designs
- **Accessibility scanners**: Automated WCAG compliance checking

### Quality Improvements
- Add more examples of component variations (sizes, states, themes)
- Include responsive behavior specifications for each component
- Provide accessibility test checklists for each component type
- Add performance budgets for component complexity
- Include design handoff checklist with required deliverables
- Add examples of dark mode implementation patterns

## Implementation Priority
**Priority**: High
**Rationale**: UI component design is critical for consistent frontend development. This agent needs strong integration with frontend development agents and clear handoff specifications.
