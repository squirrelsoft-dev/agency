# Project Context: Build Tool Detection

Detect the build tool/bundler used in the project to run builds correctly, optimize for production, and understand the build process.

## Detection Strategy

Check for build tools in order of likelihood:

### 1. Next.js (Built-in Build System)

**Primary Indicators**:
```bash
# Next.js has its own build system
test -f next.config.js || test -f next.config.mjs || test -f next.config.ts
```

**Secondary Indicators**:
- `package.json` contains `"next"` dependency
- `.next/` build output directory
- Build script: `"build": "next build"`

**Build Commands**:
```bash
# Production build
npm run build
# or
next build

# Development mode
npm run dev
# or
next dev

# Start production server
npm run start
# or
next start
```

**Output Directory**: `.next/`

**Build Tool**: `Next.js` (Webpack or Turbopack)
**Note**: Next.js 13+ can use Turbopack with `--turbo` flag

---

### 2. Vite

**Primary Indicators**:
```bash
# Check for Vite config
test -f vite.config.js || test -f vite.config.ts || test -f vite.config.mjs
```

**Secondary Indicators**:
- `package.json` contains `"vite"` dependency
- Build script: `"build": "vite build"`
- Dev script: `"dev": "vite"`
- `dist/` output directory (default)

**Build Commands**:
```bash
# Production build
npm run build
# or
vite build

# Development mode
npm run dev
# or
vite

# Preview production build
npm run preview
# or
vite preview
```

**Output Directory**: `dist/` (default, configurable)

**Build Tool**: `Vite`
**Features**: Fast HMR, ESM-native, optimized bundling

---

### 3. Webpack

**Primary Indicators**:
```bash
# Check for Webpack config
test -f webpack.config.js || test -f webpack.config.ts
```

**Secondary Indicators**:
- `package.json` contains `"webpack"` dependency
- `webpack-cli` in devDependencies
- Build script uses `webpack` command
- Common with older React/Vue projects

**Build Commands**:
```bash
# Production build
npm run build
# or
webpack --mode production

# Development mode
npm run dev
# or
webpack --mode development --watch

# Webpack dev server
webpack serve
```

**Output Directory**: `dist/` or `build/` (configurable)

**Build Tool**: `Webpack`
**Note**: Often paired with webpack-dev-server

---

### 4. Turbopack (Next.js 13+)

**Primary Indicators**:
```bash
# Turbopack is built into Next.js 13+
grep '"next"' package.json | grep -E '"(13|14|15)'
```

**Secondary Indicators**:
- Next.js 13+ with Turbopack flag
- Dev script: `"dev": "next dev --turbo"`
- Faster than Webpack for dev builds

**Build Commands**:
```bash
# Development with Turbopack
next dev --turbo

# Production still uses Webpack by default (as of Next.js 14)
next build
```

**Build Tool**: `Turbopack` (dev only, Next.js 13+)
**Note**: Production builds still use Webpack in Next.js 14

---

### 5. Rollup

**Primary Indicators**:
```bash
# Check for Rollup config
test -f rollup.config.js || test -f rollup.config.mjs || test -f rollup.config.ts
```

**Secondary Indicators**:
- `package.json` contains `"rollup"` dependency
- Build script uses `rollup` command
- Common for libraries/packages

**Build Commands**:
```bash
# Production build
npm run build
# or
rollup -c

# Watch mode
rollup -c -w
```

**Output Directory**: `dist/` (configurable)

**Build Tool**: `Rollup`
**Use Case**: Libraries, packages (not typical for apps)

---

### 6. Parcel

**Primary Indicators**:
```bash
# Check for Parcel
grep '"parcel"' package.json
```

**Secondary Indicators**:
- `.parcelrc` or `package.json` has `"source"` field
- Build script: `"build": "parcel build"`
- Zero-config bundler

**Build Commands**:
```bash
# Production build
npm run build
# or
parcel build src/index.html

# Development mode
npm run dev
# or
parcel src/index.html
```

**Output Directory**: `dist/` (default)

**Build Tool**: `Parcel`
**Features**: Zero-config, automatic transforms

---

### 7. esbuild

**Primary Indicators**:
```bash
# Check for esbuild
grep '"esbuild"' package.json
```

**Secondary Indicators**:
- Build script uses `esbuild` command
- Very fast, minimal configuration
- Often used directly or via Vite

**Build Commands**:
```bash
# Production build
npm run build
# or
esbuild src/index.ts --bundle --outfile=dist/bundle.js

# Watch mode
esbuild src/index.ts --bundle --outfile=dist/bundle.js --watch
```

**Output Directory**: Configurable via `--outfile` or `--outdir`

**Build Tool**: `esbuild`
**Features**: Extremely fast, minimal API

---

### 8. tsc (TypeScript Compiler)

**Primary Indicators**:
```bash
# TypeScript only (no bundler)
test -f tsconfig.json && ! grep -qE '"(vite|webpack|rollup)"' package.json
```

**Secondary Indicators**:
- Build script: `"build": "tsc"`
- No bundler dependencies
- Outputs `.js` files alongside `.ts` files

**Build Commands**:
```bash
# Compile TypeScript
npm run build
# or
tsc

# Watch mode
tsc --watch
```

**Output Directory**: Based on `outDir` in `tsconfig.json`

**Build Tool**: `tsc` (TypeScript Compiler)
**Note**: Compiles but doesn't bundle - use with Node.js or add bundler

---

### 9. Create React App (react-scripts)

**Primary Indicators**:
```bash
# Check for react-scripts
grep '"react-scripts"' package.json
```

**Secondary Indicators**:
- Build script: `"build": "react-scripts build"`
- Dev script: `"start": "react-scripts start"`
- `public/` directory with `index.html`
- Webpack under the hood (abstracted)

**Build Commands**:
```bash
# Production build
npm run build

# Development mode
npm start

# Eject (not recommended)
npm run eject
```

**Output Directory**: `build/`

**Build Tool**: `react-scripts` (Webpack wrapper)
**Note**: CRA is now deprecated - prefer Vite or Next.js

---

### 10. Laravel Mix (PHP/Laravel)

**Primary Indicators**:
```bash
# Check for Laravel Mix
test -f webpack.mix.js
```

**Secondary Indicators**:
- `package.json` contains `"laravel-mix"`
- Used in Laravel projects
- Webpack wrapper for Laravel

**Build Commands**:
```bash
# Development build
npm run dev

# Production build
npm run prod

# Watch mode
npm run watch
```

**Output Directory**: `public/` (Laravel convention)

**Build Tool**: `Laravel Mix` (Webpack wrapper)

---

## Detection Algorithm

```bash
# Check for build tools in order of specificity:

if test -f next.config.js || test -f next.config.mjs || test -f next.config.ts; then
  BUILD_TOOL="Next.js"
elif test -f vite.config.js || test -f vite.config.ts; then
  BUILD_TOOL="Vite"
elif test -f webpack.mix.js; then
  BUILD_TOOL="Laravel Mix"
elif test -f webpack.config.js || test -f webpack.config.ts; then
  BUILD_TOOL="Webpack"
elif test -f rollup.config.js || test -f rollup.config.ts; then
  BUILD_TOOL="Rollup"
elif grep -q '"parcel"' package.json 2>/dev/null; then
  BUILD_TOOL="Parcel"
elif grep -q '"react-scripts"' package.json 2>/dev/null; then
  BUILD_TOOL="Create React App"
elif grep -q '"esbuild"' package.json 2>/dev/null && ! grep -q '"vite"' package.json 2>/dev/null; then
  BUILD_TOOL="esbuild"
elif test -f tsconfig.json && ! grep -qE '"(vite|webpack|rollup)"' package.json 2>/dev/null; then
  BUILD_TOOL="tsc (TypeScript only)"
else
  BUILD_TOOL="Unknown"
fi
```

---

## Build Configuration Files

### Next.js
- `next.config.js` / `next.config.ts`
- Configuration: output, redirects, rewrites, env vars

### Vite
- `vite.config.js` / `vite.config.ts`
- Configuration: plugins, build options, server options

### Webpack
- `webpack.config.js` / `webpack.config.ts`
- Configuration: entry, output, loaders, plugins

### Rollup
- `rollup.config.js` / `rollup.config.ts`
- Configuration: input, output, plugins

### TypeScript
- `tsconfig.json`
- Configuration: compiler options, paths, exclude

---

## Build Optimization

### Production Build Checklist

**Next.js**:
```bash
# Production build with optimizations
next build

# Analyze bundle
npm run build -- --analyze
# or install @next/bundle-analyzer
```

**Vite**:
```bash
# Production build (automatic optimizations)
vite build

# Analyze bundle
npm run build -- --mode analyze
# or use rollup-plugin-visualizer
```

**Webpack**:
```bash
# Production build with optimizations
webpack --mode production

# Analyze bundle
webpack-bundle-analyzer stats.json
```

### Common Optimizations
- Minification (automatic in production)
- Tree-shaking (remove unused code)
- Code splitting (dynamic imports)
- Asset optimization (images, fonts)
- Compression (gzip, brotli)
- Source maps (for debugging)

---

## Environment-Specific Builds

### Development
- Fast rebuilds
- Source maps
- Hot module replacement (HMR)
- No minification

### Production
- Optimized bundles
- Minified code
- Tree-shaking
- Asset hashing
- Smaller bundle sizes

### Commands by Tool

**Next.js**:
```bash
# Development
next dev

# Production
next build && next start
```

**Vite**:
```bash
# Development
vite

# Production
vite build && vite preview
```

**Webpack**:
```bash
# Development
webpack --mode development

# Production
webpack --mode production
```

---

## Output Directory Structure

### Next.js (`.next/`)
```
.next/
├── cache/
├── server/
│   ├── pages/
│   └── chunks/
└── static/
    ├── chunks/
    └── css/
```

### Vite/Webpack (`dist/`)
```
dist/
├── assets/
│   ├── index.[hash].js
│   ├── index.[hash].css
│   └── logo.[hash].svg
└── index.html
```

### TypeScript (`dist/` or `build/`)
```
dist/
├── index.js
├── utils.js
└── types/
```

---

## Build Scripts in package.json

### Recommended Scripts

```json
{
  "scripts": {
    "dev": "vite",                    // or next dev, webpack serve
    "build": "vite build",            // or next build, webpack --mode production
    "preview": "vite preview",        // Test production build locally
    "type-check": "tsc --noEmit",     // TypeScript type checking
    "lint": "eslint .",               // Linting
    "clean": "rm -rf dist .next"      // Clean build artifacts
  }
}
```

---

## Fallback Strategy

### When No Build Tool Detected

1. **Check package.json scripts**:
   ```bash
   jq -r '.scripts' package.json
   ```

2. **Look for framework** (framework detection takes precedence):
   - Next.js → Use Next.js build system
   - Django → No JS build needed (unless frontend separate)

3. **Ask user**:
   ```
   ⚠️ No build tool detected.

   How is this project built?
   - Specify build command (e.g., npm run build)
   - Or confirm: "No build step needed"
   ```

4. **Check for TypeScript**:
   - If `tsconfig.json` exists → Use `tsc`

---

## Usage Examples

### Example 1: Next.js
```bash
$ test -f next.config.js
$ grep '"next"' package.json
"next": "14.0.4"

✅ Build Tool Detected: Next.js 14.0.4
- Config: next.config.js
- Output: .next/
- Build: npm run build
- Dev: npm run dev
- Start: npm run start

📋 Optimizations Available:
- Turbopack: Use `next dev --turbo` for faster dev builds
- Bundle analyzer: Install @next/bundle-analyzer
```

### Example 2: Vite + React
```bash
$ test -f vite.config.ts
$ grep '"vite"' package.json
"vite": "^5.0.0"

✅ Build Tool Detected: Vite 5.0.0
- Config: vite.config.ts
- Output: dist/
- Build: npm run build
- Dev: npm run dev
- Preview: npm run preview

📋 Features:
- Fast HMR with ES modules
- Optimized production builds
- Plugin ecosystem
```

### Example 3: TypeScript Only (No Bundler)
```bash
$ test -f tsconfig.json
$ ! grep -qE '"(vite|webpack|rollup)"' package.json

✅ Build Tool Detected: tsc (TypeScript Compiler)
- Config: tsconfig.json
- Output: dist/ (based on tsconfig.json)
- Build: npm run build (runs tsc)

⚠️ Note: No bundling - outputs individual .js files
Recommend adding bundler for:
- Frontend apps: Vite or Webpack
- Libraries: Rollup or esbuild
```

---

## Validation

After detection, verify by:

1. **Config File**: Confirm configuration file exists
2. **Build Command**: Test build command works
3. **Output Directory**: Check build artifacts are created

**Report Format**:
```markdown
## Build Tool Detection

**Tool**: [Tool Name] [Version]
**Config**: [config file path]
**Output**: [output directory]

**Commands**:
- Build: [command]
- Dev: [command]
- Preview: [command] (if applicable)

**Verified**:
- ✅ Config file exists
- ✅ Build command works
- ✅ Output directory created

**Build Time**: [time in seconds]
**Bundle Size**: [size in KB/MB]
```

---

## Commands Using This Component

- `/agency:implement` - Run builds during implementation
- `/agency:work` - Build during development
- `/agency:deploy` - Production build before deployment
- `/agency:optimize` - Analyze and optimize build output
- `/agency:test` - Build for testing
- `/agency:review` - Verify build succeeds
