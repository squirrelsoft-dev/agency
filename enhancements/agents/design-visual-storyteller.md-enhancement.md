# Agent Enhancement: Visual Storyteller

## Current State

**File**: `design/design-visual-storyteller.md`
**Name**: `design-visual-storyteller`
**Description**: `Expert visual communication specialist focused on creating compelling visual narratives, multimedia content, and brand storytelling through design. Specializes in transforming complex information into engaging visual stories that connect with audiences and drive emotional engagement.`

## Proposed Changes

### Better Name
**Proposed**: `design-visual-content-storyteller`
**Rationale**: Adds "content" to clarify this agent creates actual content assets (videos, infographics, etc.) not just designs. Current name is good but could be more specific.

### Better Description
**Proposed**: `Creates compelling visual narratives and multimedia content including video storyboards, infographics, animations, and cross-platform visual stories. Transforms complex information into engaging visual content that drives emotional connection and platform-specific engagement. Use when creating visual content campaigns, data visualizations, or multimedia brand stories.`

### Command Awareness
This agent should be aware of and potentially reference these agency commands:
- `/agency:work` - Creates visual content and storytelling assets
- `/agency:plan` - Develops visual content strategies and campaigns
- `/agency:document` - Generates visual content guidelines and brand story frameworks
- `/agency:review` - Reviews visual content for narrative effectiveness and brand alignment

## Enhancement Recommendations

### Capability Enhancements
- **Platform-specific optimization**: Auto-format content for Instagram, TikTok, YouTube, LinkedIn
- **Data visualization generation**: Create charts, graphs, and infographics from data
- **Video storyboard templates**: Provide reusable templates for different content types
- **Animation specification**: Define motion graphics and micro-interactions
- **Accessibility for visual content**: Alt text, captions, and inclusive design
- **Content performance metrics**: Track engagement and effectiveness
- **Seasonal campaign templates**: Pre-built frameworks for recurring campaigns

### Skill References
Should reference these workflow skills when available:
- `social-media-platform-specs` - Platform-specific requirements and best practices
- `data-visualization-tools` - For creating engaging data stories
- `video-production-workflow` - For multimedia content creation
- `accessibility-multimedia` - For inclusive visual content

### Tool Access
Current tools seem appropriate, but consider adding:
- **Image generation tools**: AI-powered visual asset creation
- **Video editing templates**: Reusable motion graphics templates
- **Data visualization tools**: Chart and infographic generation
- **Platform API access**: For content optimization and posting

### Quality Improvements
- Add specific platform optimization guidelines (aspect ratios, lengths, formats)
- Include examples of effective visual narratives across different platforms
- Provide templates for common content types (explainer videos, product demos, etc.)
- Add metrics for measuring visual content effectiveness
- Include accessibility guidelines for all visual content types
- Provide storyboard templates for different narrative structures
- Add cultural sensitivity guidelines for global content
- Include examples of data storytelling best practices
- Provide content calendar templates for visual campaigns

## Implementation Priority
**Priority**: Medium
**Rationale**: Important for marketing and brand presence but typically used for campaigns and specific content creation rather than continuous development. Should integrate well with marketing agents.
