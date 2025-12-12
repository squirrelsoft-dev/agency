# Project Context: Framework Detection

Detect the primary application framework used in the project to adapt commands, testing strategies, and build processes accordingly.

## Detection Strategy

Execute detection in order of specificity (most specific → most general):

### 1. Next.js (React Framework)

**Primary Indicators**:
```bash
# Check for Next.js configuration
test -f next.config.js || test -f next.config.mjs || test -f next.config.ts
```

**Secondary Indicators**:
- `package.json` contains `"next"` dependency
- `app/` directory exists (App Router)
- `pages/` directory exists (Pages Router)
- `.next/` build directory

**Version Detection**:
```bash
grep '"next"' package.json | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
```

**Framework**: `Next.js` (React-based, full-stack)

---

### 2. Django (Python Framework)

**Primary Indicators**:
```bash
# Check for Django configuration
test -f manage.py || test -f settings.py
```

**Secondary Indicators**:
- `requirements.txt` or `pyproject.toml` contains `Django`
- `wsgi.py` or `asgi.py` exists
- Directory structure: `app_name/models.py`, `app_name/views.py`
- `urls.py` files

**Version Detection**:
```bash
python -c "import django; print(django.get_version())" 2>/dev/null
# Or check requirements.txt
grep -i "django==" requirements.txt
```

**Framework**: `Django` (Python, full-stack)

---

### 3. Laravel (PHP Framework)

**Primary Indicators**:
```bash
# Check for Laravel artisan
test -f artisan
```

**Secondary Indicators**:
- `composer.json` contains `"laravel/framework"`
- `bootstrap/app.php` exists
- `routes/` directory with `web.php`, `api.php`
- `app/Http/`, `app/Models/` directories
- `.env` with `APP_KEY=`

**Version Detection**:
```bash
php artisan --version
# Or check composer.json
grep '"laravel/framework"' composer.json
```

**Framework**: `Laravel` (PHP, full-stack)

---

### 4. FastAPI (Python Framework)

**Primary Indicators**:
```bash
# Check dependencies
grep -i "fastapi" requirements.txt || grep -i "fastapi" pyproject.toml
```

**Secondary Indicators**:
- Main file contains `from fastapi import FastAPI`
- `uvicorn` in dependencies (ASGI server)
- API-focused structure (no templates directory)

**Common File Locations**:
- `main.py`, `app/main.py`, `src/main.py`

**Framework**: `FastAPI` (Python, API-only)

---

### 5. Flask (Python Framework)

**Primary Indicators**:
```bash
# Check dependencies
grep -i "flask" requirements.txt || grep -i "flask" pyproject.toml
```

**Secondary Indicators**:
- Main file contains `from flask import Flask`
- `templates/` directory (if using Jinja)
- `static/` directory
- `app.py` or `wsgi.py`

**Framework**: `Flask` (Python, web/API)

---

### 6. Express.js (Node.js Framework)

**Primary Indicators**:
```bash
# Check package.json
grep '"express"' package.json
```

**Secondary Indicators**:
- `server.js`, `app.js`, or `index.js` with Express imports
- `routes/` directory
- Middleware-focused structure
- No frontend build step (API-only)

**Framework**: `Express.js` (Node.js, API-only)

---

### 7. Ruby on Rails

**Primary Indicators**:
```bash
# Check for Rails configuration
test -f config/application.rb || test -f bin/rails
```

**Secondary Indicators**:
- `Gemfile` contains `gem 'rails'`
- `app/controllers/`, `app/models/`, `app/views/` structure
- `config/routes.rb`
- `db/migrate/` directory

**Version Detection**:
```bash
rails --version
# Or check Gemfile
grep "gem 'rails'" Gemfile
```

**Framework**: `Ruby on Rails` (Ruby, full-stack)

---

### 8. Remix (React Framework)

**Primary Indicators**:
```bash
# Check for Remix configuration
test -f remix.config.js || test -f remix.config.ts
```

**Secondary Indicators**:
- `package.json` contains `@remix-run/react`
- `app/routes/` directory
- `app/root.tsx` or `app/root.jsx`

**Framework**: `Remix` (React-based, full-stack)

---

### 9. SvelteKit (Svelte Framework)

**Primary Indicators**:
```bash
# Check for SvelteKit configuration
test -f svelte.config.js
```

**Secondary Indicators**:
- `package.json` contains `@sveltejs/kit`
- `src/routes/` directory
- `.svelte` files

**Framework**: `SvelteKit` (Svelte-based, full-stack)

---

### 10. Astro

**Primary Indicators**:
```bash
# Check for Astro configuration
test -f astro.config.mjs || test -f astro.config.ts
```

**Secondary Indicators**:
- `package.json` contains `astro`
- `src/pages/` directory
- `.astro` files

**Framework**: `Astro` (Multi-framework, static-first)

---

### 11. Vue.js / Nuxt

**Primary Indicators**:
```bash
# Check for Nuxt configuration
test -f nuxt.config.js || test -f nuxt.config.ts

# Or standalone Vue
grep '"vue"' package.json
```

**Secondary Indicators**:
- Nuxt: `pages/`, `components/`, `layouts/` directories
- Vue: `src/App.vue`, Vite or webpack config
- `.vue` files

**Framework**: `Nuxt` (Vue-based, full-stack) or `Vue.js` (Frontend library)

---

### 12. Angular

**Primary Indicators**:
```bash
# Check for Angular configuration
test -f angular.json
```

**Secondary Indicators**:
- `package.json` contains `@angular/core`
- `src/app/` directory
- `.component.ts` files

**Framework**: `Angular` (TypeScript, full-framework)

---

### 13. Create React App / Vite React

**Primary Indicators**:
```bash
# Check for React without framework
grep '"react"' package.json && ! test -f next.config.js && ! test -f remix.config.js
```

**Secondary Indicators**:
- `src/App.tsx` or `src/App.jsx`
- `vite.config.ts` (Vite) or `react-scripts` (CRA)
- No server-side rendering setup

**Framework**: `React` (Frontend library with bundler)

---

## Fallback Detection

If no framework detected, check for:

### Static Site Generator
- **Jekyll**: `_config.yml`, `_posts/` directory
- **Hugo**: `config.toml`, `content/` directory
- **Eleventy**: `.eleventy.js`, `_site/` directory

### Plain HTML/JS
- No framework dependencies
- Just `index.html` + CSS/JS

**Framework**: `Static` or `None`

---

## Detection Algorithm

```bash
# Execute in order, return first match:

if test -f next.config.js || test -f next.config.mjs || test -f next.config.ts; then
  echo "Next.js"
elif test -f manage.py; then
  echo "Django"
elif test -f artisan; then
  echo "Laravel"
elif grep -q "fastapi" requirements.txt 2>/dev/null || grep -q "fastapi" pyproject.toml 2>/dev/null; then
  echo "FastAPI"
elif grep -q "flask" requirements.txt 2>/dev/null || grep -q "flask" pyproject.toml 2>/dev/null; then
  echo "Flask"
elif test -f bin/rails || test -f config/application.rb; then
  echo "Ruby on Rails"
elif test -f remix.config.js || test -f remix.config.ts; then
  echo "Remix"
elif test -f svelte.config.js; then
  echo "SvelteKit"
elif test -f astro.config.mjs || test -f astro.config.ts; then
  echo "Astro"
elif test -f nuxt.config.js || test -f nuxt.config.ts; then
  echo "Nuxt"
elif test -f angular.json; then
  echo "Angular"
elif grep -q '"express"' package.json 2>/dev/null; then
  echo "Express.js"
elif grep -q '"react"' package.json 2>/dev/null; then
  echo "React"
elif grep -q '"vue"' package.json 2>/dev/null; then
  echo "Vue.js"
else
  echo "Unknown"
fi
```

---

## Framework Characteristics

Once detected, adapt behavior based on framework type:

### Full-Stack Frameworks
**Next.js, Django, Laravel, Rails, Nuxt, Remix, SvelteKit**
- Has both frontend and backend
- Built-in routing
- Server-side rendering capabilities
- May need database migrations
- Test both client and server code

### API-Only Frameworks
**FastAPI, Flask (API mode), Express.js**
- Backend only
- Focus on endpoints/routes
- API testing (Postman, curl, pytest)
- No frontend build step

### Frontend-Only
**React, Vue.js, Angular**
- Client-side only
- Bundler required (Vite, webpack)
- Component testing
- No server-side concerns

---

## Command-Specific Adaptations

### `/agency:implement`
- Use framework-specific file structure
- Adapt code generation patterns
- Use framework conventions (components, models, controllers)

### `/agency:test`
- Select appropriate test framework (see testing-framework-detection.md)
- Use framework test helpers
- Mock framework-specific features

### `/agency:deploy`
- Use framework build commands
- Set framework environment variables
- Configure framework production mode

### `/agency:document`
- Document framework-specific patterns
- Reference framework documentation
- Use framework terminology

### `/agency:refactor`
- Follow framework best practices
- Use framework-specific patterns
- Maintain framework conventions

---

## Ambiguity Handling

### Multiple Frameworks Detected
**Example**: Next.js + Express.js (separate backend)

**Strategy**:
1. Ask user which framework to target
2. List detected frameworks with file evidence
3. Document both in context
4. Prioritize user-specified framework

### Unknown Framework
**When detection fails**:

1. Check `package.json` scripts for clues:
   - `"dev"`, `"build"`, `"start"` commands
   - Framework-specific commands

2. List top dependencies:
   ```bash
   jq -r '.dependencies | keys[]' package.json | head -10
   ```

3. Ask user to specify framework

4. Proceed with generic approach:
   - Generic test commands
   - Standard build process
   - No framework-specific assumptions

---

## Usage Examples

### Example 1: Next.js Detection
```bash
$ test -f next.config.js
$ echo "Detected framework: Next.js"
$ grep '"next"' package.json
"next": "14.0.4"

✅ Framework: Next.js 14.0.4
- Type: Full-stack React framework
- Build: npm run build
- Dev: npm run dev
- Test: Jest/Vitest (see testing-framework-detection.md)
```

### Example 2: Django Detection
```bash
$ test -f manage.py
$ python -c "import django; print(django.get_version())"
5.0.1

✅ Framework: Django 5.0.1
- Type: Full-stack Python framework
- Run: python manage.py runserver
- Test: pytest or python manage.py test
- Migrate: python manage.py migrate
```

### Example 3: Ambiguous (Multiple Frameworks)
```bash
$ test -f next.config.js && grep -q '"express"' package.json

⚠️ Multiple frameworks detected:
1. Next.js (frontend framework)
   - Evidence: next.config.js, app/ directory
2. Express.js (backend API)
   - Evidence: package.json, server/index.js

📋 Please specify which framework is the primary target:
- Type "Next.js" for frontend work
- Type "Express" for backend API work
- Type "Both" if work spans both
```

---

## Validation

After detection, verify by:

1. **File Structure Check**: Confirm expected directories exist
2. **Build Command**: Verify build command works
3. **Dev Command**: Confirm dev server starts
4. **Dependencies**: Check critical dependencies installed

**Report Format**:
```markdown
## Framework Detection

**Detected**: [Framework Name] [Version]
**Type**: [Full-stack/API-only/Frontend-only]
**Confidence**: [High/Medium/Low]

**Evidence**:
- ✅ Configuration file: [file path]
- ✅ Dependencies: [key dependencies]
- ✅ Directory structure: [key directories]

**Adapted Commands**:
- Build: [command]
- Test: [command]
- Dev: [command]
```

---

## Commands Using This Component

- `/agency:implement` - Adapt code generation to framework
- `/agency:work` - Use framework-specific patterns
- `/agency:test` - Select appropriate testing approach
- `/agency:refactor` - Follow framework conventions
- `/agency:optimize` - Apply framework-specific optimizations
- `/agency:deploy` - Use framework build/deploy process
- `/agency:document` - Document framework patterns
- `/agency:review` - Verify framework best practices
- `/agency:sprint` - Plan based on framework capabilities
- `/agency:plan` - Consider framework constraints
- `/agency:security` - Check framework-specific vulnerabilities
