#!/usr/bin/env python3
"""
Extract metadata from all agent files and build agent-capabilities.json
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Any

def extract_frontmatter(content: str) -> Dict[str, Any]:
    """Extract YAML frontmatter from markdown"""
    match = re.search(r'^---\n(.*?)\n---', content, re.DOTALL | re.MULTILINE)
    if not match:
        return {}

    frontmatter = {}
    yaml_content = match.group(1)

    # Extract name
    name_match = re.search(r'^name:\s*(.+)$', yaml_content, re.MULTILINE)
    if name_match:
        frontmatter['name'] = name_match.group(1).strip()

    # Extract description
    desc_match = re.search(r'^description:\s*(.+)$', yaml_content, re.MULTILINE)
    if desc_match:
        frontmatter['description'] = desc_match.group(1).strip()

    # Extract color
    color_match = re.search(r'^color:\s*(.+)$', yaml_content, re.MULTILINE)
    if color_match:
        frontmatter['color'] = color_match.group(1).strip()

    # Extract tools
    tools_section = re.search(r'tools:\s*\n((?:  .+\n)+)', yaml_content, re.MULTILINE)
    if tools_section:
        tools = {}
        for line in tools_section.group(1).split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                key = key.strip()
                value = value.strip()
                if value.startswith('[') and value.endswith(']'):
                    # Parse array
                    items = [item.strip() for item in value[1:-1].split(',')]
                    tools[key] = items
        frontmatter['tools'] = tools

    # Extract skills
    skills_match = re.search(r'skills:\s*\n((?:  - .+\n)+)', yaml_content, re.MULTILINE)
    if skills_match:
        skills = []
        for line in skills_match.group(1).split('\n'):
            if line.strip().startswith('- '):
                skill = line.strip()[2:].strip()
                skills.append(skill)
        frontmatter['skills'] = skills

    return frontmatter

def extract_commands(content: str) -> Dict[str, List[Dict]]:
    """Extract command information"""
    commands = {'primary': [], 'secondary': []}

    # Find Commands section
    cmd_section = re.search(r'### Commands This Agent Responds To\n\n\*\*Primary Commands\*\*:(.*?)(?=\*\*Secondary Commands\*\*:|##|\Z)', content, re.DOTALL)
    if cmd_section:
        primary_text = cmd_section.group(1)
        # Extract each command
        cmd_blocks = re.findall(r'- \*\*`([^`]+)`\*\* - ([^\n]+)\n\s+- \*\*When Selected\*\*: ([^\n]+)\n\s+- \*\*Responsibilities\*\*: ([^\n]+)', primary_text, re.DOTALL)
        for cmd, desc, when, resp in cmd_blocks:
            commands['primary'].append({
                'command': cmd,
                'description': desc.strip(),
                'selection_criteria': when.strip(),
                'responsibilities': resp.strip()
            })

    return commands

def extract_use_cases(content: str) -> List[str]:
    """Extract primary use cases from Core Mission section"""
    use_cases = []

    # Find Core Mission section
    mission_section = re.search(r'## 🎯 Your Core Mission\n\n(.*?)(?=##|\Z)', content, re.DOTALL)
    if mission_section:
        mission_text = mission_section.group(1)
        # Extract bullet points from first subsection
        bullets = re.findall(r'^- (.+)$', mission_text, re.MULTILINE)
        use_cases = [bullet.strip() for bullet in bullets[:5]]  # Take first 5

    return use_cases

def infer_technologies(skills: List[str]) -> List[str]:
    """Map skills to technology names"""
    tech_map = {
        'nextjs-16-expert': 'Next.js',
        'typescript-5-expert': 'TypeScript',
        'tailwindcss-4-expert': 'Tailwind CSS',
        'prisma-latest-expert': 'Prisma',
        'drizzle-0-expert': 'Drizzle ORM',
        'supabase-latest-expert': 'Supabase',
        'shadcn-latest-expert': 'shadcn/ui',
        'ai-5-expert': 'Vercel AI SDK',
        'mastra-latest-expert': 'Mastra',
        'fastmcp-2-expert': 'FastMCP',
        'pixeltable-0-expert': 'Pixeltable',
        'next-auth-beta-expert': 'NextAuth.js',
        'acli-latest-expert': 'Atlassian CLI'
    }

    technologies = []
    for skill in skills:
        if skill in tech_map:
            technologies.append(tech_map[skill])

    return technologies

def extract_capabilities(content: str, name: str) -> List[str]:
    """Derive capability keywords from content"""
    capabilities = []

    # Map agent names to capabilities
    capability_keywords = {
        'api': ['api', 'endpoint', 'backend'],
        'frontend': ['ui', 'component', 'react'],
        'testing': ['test', 'qa', 'validation'],
        'design': ['design', 'ux', 'visual'],
        'orchestration': ['orchestrate', 'coordinate', 'pipeline'],
        'analytics': ['analytics', 'data', 'metrics'],
        'mobile': ['mobile', 'ios', 'android'],
        'devops': ['devops', 'deploy', 'infrastructure']
    }

    content_lower = content.lower()
    for cap, keywords in capability_keywords.items():
        if any(keyword in content_lower for keyword in keywords):
            capabilities.append(cap)

    return list(set(capabilities))

def process_agent(file_path: Path) -> Dict[str, Any]:
    """Process a single agent file and extract all metadata"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    frontmatter = extract_frontmatter(content)
    if not frontmatter or 'name' not in frontmatter:
        return None

    # Determine category from path
    parts = file_path.parts
    if len(parts) >= 3 and parts[-3] == 'agents':
        category = parts[-2]
    else:
        category = 'meta'

    agent_name = frontmatter['name']
    agent_id = agent_name.replace(' ', '-').lower()

    # Extract all data
    commands = extract_commands(content)
    use_cases = extract_use_cases(content)
    skills = frontmatter.get('skills', [])
    technologies = infer_technologies(skills)
    capabilities = extract_capabilities(content, agent_name)

    # Categorize skills
    tech_skills = [s for s in skills if '-expert' in s or 'framework' in s or 'sdk' in s]
    quality_skills = [s for s in skills if 'testing' in s or 'review' in s or 'quality' in s]
    essential_skills = ['agency-workflow-patterns']

    agent_data = {
        'id': agent_id,
        'name': agent_name,
        'display_name': agent_name.replace('-', ' ').title(),
        'category': category,
        'file_path': str(file_path),
        'description': frontmatter.get('description', ''),
        'color': frontmatter.get('color', 'gray'),
        'primary_use_cases': use_cases,
        'when_to_select': [cmd['selection_criteria'] for cmd in commands.get('primary', [])],
        'commands': commands,
        'skills': {
            'essential': essential_skills,
            'technology': tech_skills,
            'quality': quality_skills,
            'all': skills
        },
        'tools': frontmatter.get('tools', {}),
        'technologies': technologies,
        'capabilities': capabilities
    }

    return agent_data

def build_indices(agents: List[Dict]) -> Dict[str, Dict]:
    """Build all indices from agent data"""
    indices = {
        'by_category': {},
        'by_technology': {},
        'by_command': {},
        'by_capability': {},
        'by_skill': {}
    }

    for agent in agents:
        agent_name = agent['name']

        # By category
        category = agent['category']
        if category not in indices['by_category']:
            indices['by_category'][category] = []
        indices['by_category'][category].append(agent_name)

        # By technology
        for tech in agent.get('technologies', []):
            if tech not in indices['by_technology']:
                indices['by_technology'][tech] = []
            indices['by_technology'][tech].append(agent_name)

        # By command
        for cmd in agent.get('commands', {}).get('primary', []):
            cmd_name = cmd['command']
            if cmd_name not in indices['by_command']:
                indices['by_command'][cmd_name] = []
            indices['by_command'][cmd_name].append(agent_name)

        # By capability
        for cap in agent.get('capabilities', []):
            if cap not in indices['by_capability']:
                indices['by_capability'][cap] = []
            indices['by_capability'][cap].append(agent_name)

        # By skill
        for skill in agent.get('skills', {}).get('all', []):
            if skill not in indices['by_skill']:
                indices['by_skill'][skill] = []
            indices['by_skill'][skill].append(agent_name)

    return indices

def main():
    """Main extraction process"""
    agents_dir = Path('agents')
    all_agents = []

    # Process all agent files
    for agent_file in sorted(agents_dir.rglob('*.md')):
        print(f"Processing: {agent_file}")
        agent_data = process_agent(agent_file)
        if agent_data:
            all_agents.append(agent_data)

    # Build indices
    indices = build_indices(all_agents)

    # Create final structure
    output = {
        'version': '1.0.0',
        'generated_at': '2025-12-11',
        'total_agents': len(all_agents),
        'agents': all_agents,
        'indices': indices
    }

    # Write to JSON file
    output_file = Path('.agency/agent-capabilities.json')
    output_file.parent.mkdir(parents=True, exist_ok=True)

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2)

    print(f"\n✅ Successfully processed {len(all_agents)} agents")
    print(f"📄 Output written to: {output_file}")
    print(f"\nBreakdown by category:")
    for category, agents in sorted(indices['by_category'].items()):
        print(f"  {category}: {len(agents)} agents")

if __name__ == '__main__':
    main()
