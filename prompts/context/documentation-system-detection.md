# Project Context: Documentation System Detection

Detect the documentation system or framework used in the project to generate, update, and maintain documentation correctly.

## Detection Strategy

Check for documentation systems in order of likelihood:

### 1. MkDocs (Python Documentation)

**Primary Indicators**:
```bash
# Check for MkDocs config
test -f mkdocs.yml
```

**Secondary Indicators**:
- `requirements.txt` or `pyproject.toml` contains `mkdocs`
- `docs/` directory with markdown files
- Common themes: `mkdocs-material`
- Build output: `site/` directory

**Build Commands**:
```bash
# Serve locally
mkdocs serve

# Build static site
mkdocs build

# Deploy to GitHub Pages
mkdocs gh-deploy
```

**Content Location**: `docs/` directory
**Output Directory**: `site/`

**Documentation System**: `MkDocs`
**Format**: Markdown
**Best For**: Python projects, technical documentation

---

### 2. Docusaurus (React-based Documentation)

**Primary Indicators**:
```bash
# Check for Docusaurus config
test -f docusaurus.config.js || test -f docusaurus.config.ts
```

**Secondary Indicators**:
- `package.json` contains `@docusaurus/core`
- `docs/` directory with markdown/MDX files
- `blog/` directory (optional)
- `src/pages/` for custom pages
- Build output: `build/` directory

**Build Commands**:
```bash
# Development server
npm run start
# or
docusaurus start

# Production build
npm run build
# or
docusaurus build

# Serve production build
npm run serve
# or
docusaurus serve

# Deploy
npm run deploy
```

**Content Location**: `docs/` and `blog/`
**Output Directory**: `build/`

**Documentation System**: `Docusaurus`
**Format**: Markdown, MDX (Markdown + JSX)
**Best For**: Open source projects, component libraries

---

### 3. Storybook (Component Documentation)

**Primary Indicators**:
```bash
# Check for Storybook config
test -d .storybook || test -f .storybook/main.js || test -f .storybook/main.ts
```

**Secondary Indicators**:
- `package.json` contains `@storybook/` packages
- Story files: `*.stories.js`, `*.stories.ts`, `*.stories.tsx`
- Build output: `storybook-static/` directory

**Build Commands**:
```bash
# Development mode
npm run storybook
# or
storybook dev

# Build static site
npm run build-storybook
# or
storybook build
```

**Content Location**: `*.stories.js/ts/tsx` files alongside components
**Output Directory**: `storybook-static/`

**Documentation System**: `Storybook`
**Format**: JavaScript/TypeScript stories
**Best For**: UI components, design systems

---

### 4. VitePress (Vite-powered Documentation)

**Primary Indicators**:
```bash
# Check for VitePress config
test -f .vitepress/config.js || test -f .vitepress/config.ts || test -f .vitepress/config.mts
```

**Secondary Indicators**:
- `package.json` contains `vitepress`
- `docs/` or root directory with markdown files
- `.vitepress/` directory with theme/config
- Build output: `.vitepress/dist/`

**Build Commands**:
```bash
# Development server
npm run docs:dev
# or
vitepress dev

# Production build
npm run docs:build
# or
vitepress build

# Preview build
npm run docs:preview
# or
vitepress preview
```

**Content Location**: `docs/` or root directory
**Output Directory**: `.vitepress/dist/`

**Documentation System**: `VitePress`
**Format**: Markdown
**Best For**: Vue.js projects, fast documentation sites

---

### 5. Sphinx (Python Documentation)

**Primary Indicators**:
```bash
# Check for Sphinx config
test -f conf.py || test -f docs/conf.py
```

**Secondary Indicators**:
- `requirements.txt` contains `sphinx`
- `docs/` directory with `.rst` or `.md` files
- `Makefile` or `make.bat` in docs/
- Build output: `docs/_build/` or `_build/`

**Build Commands**:
```bash
# Build HTML
cd docs && make html
# or
sphinx-build -b html docs/ docs/_build/html

# Build PDF
cd docs && make latexpdf

# Clean build
cd docs && make clean
```

**Content Location**: `docs/` directory
**Output Directory**: `docs/_build/html/`

**Documentation System**: `Sphinx`
**Format**: reStructuredText (.rst) or Markdown
**Best For**: Python projects, API documentation

---

### 6. JSDoc (JavaScript Documentation)

**Primary Indicators**:
```bash
# Check for JSDoc config
test -f jsdoc.json || test -f jsdoc.conf.json
```

**Secondary Indicators**:
- `package.json` contains `jsdoc`
- JSDoc comments in source code: `/** ... */`
- Build script: `jsdoc` command
- Build output: `docs/` or `out/`

**Build Commands**:
```bash
# Generate documentation
npm run docs
# or
jsdoc src/ -r -d docs/
```

**Content Location**: JSDoc comments in source files
**Output Directory**: `docs/` or `out/` (configurable)

**Documentation System**: `JSDoc`
**Format**: JSDoc comments in code
**Best For**: JavaScript libraries, API documentation

---

### 7. TypeDoc (TypeScript Documentation)

**Primary Indicators**:
```bash
# Check for TypeDoc config
test -f typedoc.json || grep -q '"typedoc"' package.json
```

**Secondary Indicators**:
- `package.json` contains `typedoc`
- TypeScript source files with TSDoc comments
- Build script uses `typedoc` command
- Build output: `docs/` or `dist/docs/`

**Build Commands**:
```bash
# Generate documentation
npm run docs
# or
typedoc src/

# With custom config
typedoc --options typedoc.json
```

**Content Location**: TSDoc comments in TypeScript files
**Output Directory**: `docs/` (configurable)

**Documentation System**: `TypeDoc`
**Format**: TSDoc comments in code
**Best For**: TypeScript libraries, API documentation

---

### 8. GitBook

**Primary Indicators**:
```bash
# Check for GitBook config
test -f .gitbook.yaml || test -f book.json
```

**Secondary Indicators**:
- `SUMMARY.md` file (table of contents)
- `README.md` as homepage
- Markdown files for content
- Often hosted on gitbook.com

**Build Commands**:
```bash
# Install GitBook CLI
npm install -g gitbook-cli

# Serve locally
gitbook serve

# Build static site
gitbook build
```

**Content Location**: Root directory with markdown files
**Output Directory**: `_book/`

**Documentation System**: `GitBook`
**Format**: Markdown
**Best For**: User guides, books, documentation

---

### 9. Nextra (Next.js Documentation)

**Primary Indicators**:
```bash
# Check for Nextra
grep '"nextra"' package.json || grep '"nextra-theme-docs"' package.json
```

**Secondary Indicators**:
- `theme.config.jsx` or `theme.config.tsx`
- `pages/` directory with `.md` or `.mdx` files
- Built on Next.js
- `_meta.json` files for navigation

**Build Commands**:
```bash
# Development
npm run dev

# Production build
npm run build

# Start production
npm run start
```

**Content Location**: `pages/` directory
**Output Directory**: `.next/`

**Documentation System**: `Nextra`
**Format**: Markdown, MDX
**Best For**: Next.js projects, modern documentation

---

### 10. README-only (Simple Documentation)

**Primary Indicators**:
```bash
# Only README, no doc system
test -f README.md && ! test -d docs && ! test -f mkdocs.yml
```

**Secondary Indicators**:
- Just `README.md` file
- No dedicated docs directory
- No documentation framework
- May have additional markdown files

**Content Location**: `README.md`, root directory
**Output Directory**: None (markdown only)

**Documentation System**: `None` (README-only)
**Format**: Markdown
**Best For**: Small libraries, simple projects

---

## Detection Algorithm

```bash
# Check for documentation systems in order:

if test -f mkdocs.yml; then
  DOC_SYSTEM="MkDocs"
elif test -f docusaurus.config.js || test -f docusaurus.config.ts; then
  DOC_SYSTEM="Docusaurus"
elif test -d .storybook; then
  DOC_SYSTEM="Storybook"
elif test -f .vitepress/config.js || test -f .vitepress/config.ts; then
  DOC_SYSTEM="VitePress"
elif test -f docs/conf.py || test -f conf.py; then
  DOC_SYSTEM="Sphinx"
elif test -f jsdoc.json || test -f jsdoc.conf.json; then
  DOC_SYSTEM="JSDoc"
elif test -f typedoc.json || grep -q '"typedoc"' package.json 2>/dev/null; then
  DOC_SYSTEM="TypeDoc"
elif test -f .gitbook.yaml || test -f book.json; then
  DOC_SYSTEM="GitBook"
elif grep -q '"nextra"' package.json 2>/dev/null; then
  DOC_SYSTEM="Nextra"
elif test -f README.md; then
  DOC_SYSTEM="README-only"
else
  DOC_SYSTEM="None"
fi
```

---

## Documentation Types

### Static Site Generators
**MkDocs, Docusaurus, VitePress, Sphinx, GitBook**
- Markdown/MDX content
- Build to static HTML
- Can deploy to any host
- Full site structure

### API Documentation Generators
**JSDoc, TypeDoc**
- Extract from code comments
- Auto-generate API reference
- Type information
- Best for libraries

### Component Documentation
**Storybook**
- Interactive component demos
- Visual regression testing
- Isolated development
- Design system documentation

---

## Common Documentation Tasks

### Add New Page

**MkDocs**:
```bash
# Create markdown file
echo "# New Page" > docs/new-page.md

# Add to mkdocs.yml navigation
nav:
  - Home: index.md
  - New Page: new-page.md
```

**Docusaurus**:
```bash
# Create markdown file
echo "# New Page" > docs/new-page.md

# Docusaurus auto-discovers, or add to sidebars.js
```

**Storybook**:
```tsx
// Create story file
export default {
  title: 'Components/Button',
  component: Button,
};

export const Primary = {
  args: { variant: 'primary' },
};
```

### Update Documentation

**Markdown-based** (MkDocs, Docusaurus, VitePress):
- Edit `.md` or `.mdx` files
- Hot reload in dev mode
- Rebuild for production

**Code-based** (JSDoc, TypeDoc, Storybook):
- Update code comments or stories
- Regenerate documentation
- Commit changes

---

## Deployment Strategies

### GitHub Pages
```bash
# MkDocs
mkdocs gh-deploy

# Docusaurus
GIT_USER=<username> npm run deploy

# Manual
npm run build
# Upload build/ or site/ to GitHub Pages
```

### Vercel/Netlify
- Connect Git repository
- Set build command: `npm run build` or `mkdocs build`
- Set output directory: `build/`, `site/`, `.vitepress/dist/`
- Deploy automatically on push

### Self-hosted
```bash
# Build static site
npm run build

# Upload to server
scp -r build/* user@server:/var/www/docs/
```

---

## Fallback Strategy

### When No Documentation System Detected

1. **Check for docs directory**:
   ```bash
   test -d docs && ls docs/
   ```

2. **Check README**:
   ```bash
   test -f README.md
   ```

3. **Ask user**:
   ```
   ⚠️ No documentation system detected.

   How would you like to document this project?
   - Use existing README.md
   - Set up documentation framework (recommend based on project type)
   - Create new docs/ directory
   ```

4. **Recommend system** based on project type:
   - Python → MkDocs or Sphinx
   - JavaScript/TypeScript library → TypeDoc or JSDoc
   - React components → Storybook
   - General project → Docusaurus or VitePress

---

## Usage Examples

### Example 1: MkDocs
```bash
$ test -f mkdocs.yml
$ grep "mkdocs" requirements.txt
mkdocs==1.5.3
mkdocs-material==9.5.0

✅ Documentation System Detected: MkDocs
- Config: mkdocs.yml
- Content: docs/
- Output: site/
- Theme: Material for MkDocs

📋 Commands:
- Serve: mkdocs serve
- Build: mkdocs build
- Deploy: mkdocs gh-deploy
```

### Example 2: Storybook
```bash
$ test -d .storybook
$ grep "@storybook/react" package.json
"@storybook/react": "^7.6.0"

✅ Documentation System Detected: Storybook 7.6.0
- Config: .storybook/
- Stories: **/*.stories.tsx
- Output: storybook-static/

📋 Commands:
- Dev: npm run storybook
- Build: npm run build-storybook

📋 Story Count: 24 stories found
```

### Example 3: README-only
```bash
$ test -f README.md
$ ! test -d docs

✅ Documentation: README-only
- File: README.md
- Size: 3.2 KB

⚠️ No dedicated documentation system.

Recommendations:
- For API docs: Add TypeDoc or JSDoc
- For user guides: Set up Docusaurus or VitePress
- For components: Add Storybook
```

---

## Validation

After detection, verify by:

1. **Config File**: Confirm configuration exists
2. **Content**: Check documentation files exist
3. **Build**: Verify build command works
4. **Output**: Check generated documentation

**Report Format**:
```markdown
## Documentation System Detection

**System**: [System Name] [Version]
**Config**: [config file]
**Content Location**: [directory/pattern]
**Output**: [output directory]

**Commands**:
- Serve: [command]
- Build: [command]
- Deploy: [command] (if applicable)

**Content**:
- Pages: [count]
- Format: [Markdown/MDX/etc]

**Verified**:
- ✅ Config file exists
- ✅ Content files found
- ✅ Build command works
```

---

## Commands Using This Component

- `/agency:document` - Generate or update documentation
- `/agency:implement` - Document new features
- `/agency:review` - Verify documentation exists
- `/agency:work` - Update docs during development
