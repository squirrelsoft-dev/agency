#!/bin/bash
#
# Build verification hook for Agency plugin
# Runs build commands after Edit/Write to verify code compiles
# Performance: Slow (5-30 seconds)
#

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/project-detection.sh"
source "${SCRIPT_DIR}/lib/settings-reader.sh"

# ============================================================================
# Configuration
# ============================================================================

LOG_FILE="/tmp/agency-hooks-build-verification.log"

# ============================================================================
# Main Logic
# ============================================================================

main() {
    log "=== Build verification hook triggered ==="

    # 1. Check if hook is enabled
    if ! is_hook_enabled "build-verification"; then
        log "Build verification hook disabled"
        exit 0
    fi

    # 2. Extract file path
    FILE_PATH=$(get_file_path_from_tool_call)
    if [[ -z "$FILE_PATH" ]]; then
        exit 0
    fi

    log "Verifying build after editing: $FILE_PATH"

    # 3. Run build check
    PROJECT_TYPE=$(detect_project_type)

    run_build "$PROJECT_TYPE"
}

run_build() {
    local project_type="$1"

    case "$project_type" in
        typescript|javascript|nextjs)
            build_typescript
            ;;
        python)
            build_python
            ;;
        go)
            build_go
            ;;
        rust)
            build_rust
            ;;
        *)
            log "SKIP: No build command for project type: $project_type"
            ;;
    esac
}

build_typescript() {
    # Try TypeScript type checking first
    if command_exists tsc; then
        log "Running tsc --noEmit"
        if tsc --noEmit >> "$LOG_FILE" 2>&1; then
            log "✅ Type check passed"
        else
            echo "⚠️  Type check failed (check $LOG_FILE)" >&2
        fi
    fi

    # Try npm run build if available
    if [[ -f "package.json" ]] && grep -q '"build":' package.json; then
        log "Running npm run build"
        if npm run build >> "$LOG_FILE" 2>&1; then
            log "✅ Build passed"
        else
            echo "⚠️  Build failed (check $LOG_FILE)" >&2
        fi
    fi
}

build_python() {
    if [[ -f "setup.py" ]]; then
        log "Running python setup.py build"
        if python setup.py build >> "$LOG_FILE" 2>&1; then
            log "✅ Build passed"
        else
            echo "⚠️  Build failed (check $LOG_FILE)" >&2
        fi
    else
        log "SKIP: No setup.py found"
    fi
}

build_go() {
    log "Running go build ./..."
    if go build ./... >> "$LOG_FILE" 2>&1; then
        log "✅ Build passed"
    else
        echo "⚠️  Build failed (check $LOG_FILE)" >&2
    fi
}

build_rust() {
    log "Running cargo build"
    if cargo build >> "$LOG_FILE" 2>&1; then
        log "✅ Build passed"
    else
        echo "⚠️  Build failed (check $LOG_FILE)" >&2
    fi
}

main "$@"
