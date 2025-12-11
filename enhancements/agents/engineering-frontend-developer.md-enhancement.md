# Agent Enhancement: Frontend Developer

## Current State

**File**: `engineering/engineering-frontend-developer.md`
**Name**: `Frontend Developer`
**Description**: `Expert frontend developer specializing in modern web technologies, React/Vue/Angular frameworks, UI implementation, and performance optimization`

## Proposed Changes

### Better Name
**Proposed**: `engineering-frontend-web-developer`
**Rationale**: Adds "web" to distinguish from mobile frontend development and clarify the focus area.

### Better Description
**Proposed**: `Builds modern web applications with React, Vue, or Angular, focusing on performance, accessibility, and pixel-perfect UI implementation. Creates responsive, accessible interfaces with Core Web Vitals optimization and comprehensive testing. Use when implementing frontend features, optimizing web performance, or building component-based UIs.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Implements frontend features and components
- `/agency:plan` - Creates frontend architecture and component design
- `/agency:optimize` - Optimizes bundle size, performance, and Core Web Vitals
- `/agency:test` - Creates frontend testing strategies (unit, integration, e2e)
- `/agency:document` - Generates component documentation and usage guides
- `/agency:review` - Reviews frontend code for performance and accessibility
- `/agency:refactor` - Refactors frontends to modern patterns and frameworks

## Enhancement Recommendations

### Capability Enhancements
- **Editor integration bridges**: WebSocket/RPC for cross-application communication as mentioned in agent
- **Component generation**: Auto-generate component boilerplate from specs
- **Bundle analysis**: Automated bundle size analysis and optimization suggestions
- **Accessibility automation**: Automated WCAG testing and reporting
- **Visual regression**: Chromatic, Percy integration for UI testing
- **Performance monitoring**: Real User Monitoring (RUM) integration
- **Code splitting automation**: Intelligent code splitting strategies
- **CSS-in-JS optimization**: Emotion, styled-components optimization

### Skill References
Should reference these workflow skills when available:
- `nextjs-16-expert` - For Next.js development patterns
- `tailwindcss-4-expert` - For utility-first CSS
- `shadcn-latest-expert` - For component library patterns
- `typescript-5-expert` - For type-safe development
- `accessibility-wcag-validator` - For accessibility compliance
- `web-performance-optimizer` - For Core Web Vitals

### Tool Access
Current tools seem appropriate, but consider adding:
- **Build tools**: Webpack, Vite, Turbopack analysis
- **Performance tools**: Lighthouse, WebPageTest integration
- **Accessibility tools**: axe-core, Pa11y automated testing
- **Visual testing tools**: Screenshot comparison and regression testing
- **Bundle analyzers**: Source map exploration and optimization

### Quality Improvements
- Add specific Core Web Vitals targets with optimization strategies
- Include framework-specific optimization patterns (React.memo, Vue computed, etc.)
- Provide accessibility testing checklist with automated tool recommendations
- Add responsive design patterns for different breakpoints
- Include state management patterns for different frameworks
- Provide bundle size budgets for different application types
- Add examples of performance optimization wins (lazy loading, code splitting, etc.)
- Include cross-browser testing strategies and tools
- Provide TypeScript migration strategies for JavaScript projects
- Add examples of successful Progressive Web App implementations

## Implementation Priority
**Priority**: High
**Rationale**: Frontend development is critical for user-facing applications. Affects user experience directly. Should coordinate closely with UI designers and backend developers.
