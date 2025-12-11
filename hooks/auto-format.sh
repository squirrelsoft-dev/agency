#!/bin/bash
#
# Auto-format hook for Agency plugin
# Runs project-specific formatter after Edit/Write tool use
# Performance: Fast (< 1 second)
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

LOG_FILE="/tmp/agency-hooks-auto-format.log"

# ============================================================================
# Main Logic
# ============================================================================

main() {
    log "=== Auto-format hook triggered ==="

    # 1. Check if hook is enabled in settings
    if ! is_hook_enabled "auto-format"; then
        log "Auto-format hook disabled in settings"
        exit 0
    fi

    # 2. Extract file path from tool call
    FILE_PATH=$(get_file_path_from_tool_call)
    if [[ -z "$FILE_PATH" ]]; then
        log "ERROR: Could not extract file_path from tool call"
        exit 0
    fi

    log "File modified: $FILE_PATH"

    # 3. Check if file exists and is a file
    if [[ ! -f "$FILE_PATH" ]]; then
        log "SKIP: Not a file or doesn't exist: $FILE_PATH"
        exit 0
    fi

    # 4. Get file extension
    FILE_EXT="${FILE_PATH##*.}"

    # 5. Detect project type and formatter
    PROJECT_TYPE=$(detect_project_type)
    log "Project type: $PROJECT_TYPE"

    # 6. Format based on file type
    format_file "$FILE_PATH" "$FILE_EXT" "$PROJECT_TYPE"

    log "✅ Auto-format complete: $FILE_PATH"
}

# ============================================================================
# Format Logic
# ============================================================================

format_file() {
    local file_path="$1"
    local file_ext="$2"
    local project_type="$3"

    case "$file_ext" in
        ts|tsx|js|jsx|json)
            format_javascript "$file_path" "$project_type"
            ;;
        py)
            format_python "$file_path"
            ;;
        go)
            format_go "$file_path"
            ;;
        rs)
            format_rust "$file_path"
            ;;
        md|markdown)
            format_markdown "$file_path"
            ;;
        yaml|yml)
            format_yaml "$file_path"
            ;;
        *)
            log "SKIP: No formatter for extension: $file_ext"
            ;;
    esac
}

format_javascript() {
    local file_path="$1"
    local project_type="$2"

    # Try prettier first (most common)
    if command_exists npx; then
        log "Running prettier on $file_path"
        npx prettier --write "$file_path" >> "$LOG_FILE" 2>&1 || {
            log "WARNING: prettier failed, trying alternative"
        }
        return 0
    fi

    # Fallback: eslint with --fix
    if command_exists eslint; then
        log "Running eslint --fix on $file_path"
        eslint --fix "$file_path" >> "$LOG_FILE" 2>&1 || true
        return 0
    fi

    log "SKIP: No JavaScript formatter available"
}

format_python() {
    local file_path="$1"

    # Try black first (opinionated, fast)
    if command_exists black; then
        log "Running black on $file_path"
        black "$file_path" >> "$LOG_FILE" 2>&1 || true
        return 0
    fi

    # Fallback: autopep8
    if command_exists autopep8; then
        log "Running autopep8 on $file_path"
        autopep8 --in-place "$file_path" >> "$LOG_FILE" 2>&1 || true
        return 0
    fi

    log "SKIP: No Python formatter available"
}

format_go() {
    local file_path="$1"

    if command_exists gofmt; then
        log "Running gofmt on $file_path"
        gofmt -w "$file_path" >> "$LOG_FILE" 2>&1 || true
    else
        log "SKIP: gofmt not available"
    fi
}

format_rust() {
    local file_path="$1"

    if command_exists rustfmt; then
        log "Running rustfmt on $file_path"
        rustfmt "$file_path" >> "$LOG_FILE" 2>&1 || true
    else
        log "SKIP: rustfmt not available"
    fi
}

format_markdown() {
    local file_path="$1"

    # Use prettier for markdown if available
    if command_exists npx; then
        log "Running prettier on markdown: $file_path"
        npx prettier --write "$file_path" >> "$LOG_FILE" 2>&1 || true
    else
        log "SKIP: No markdown formatter available"
    fi
}

format_yaml() {
    local file_path="$1"

    # Use prettier for YAML if available
    if command_exists npx; then
        log "Running prettier on YAML: $file_path"
        npx prettier --write "$file_path" >> "$LOG_FILE" 2>&1 || true
    else
        log "SKIP: No YAML formatter available"
    fi
}

# ============================================================================
# Execute
# ============================================================================

main "$@"
