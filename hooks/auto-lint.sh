#!/bin/bash
#
# Auto-lint hook for Agency plugin
# Runs linter after Edit/Write and reports issues
# Performance: Medium (2-5 seconds), can be noisy
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

LOG_FILE="/tmp/agency-hooks-auto-lint.log"

# ============================================================================
# Main Logic
# ============================================================================

main() {
    log "=== Auto-lint hook triggered ==="

    # 1. Check if hook is enabled
    if ! is_hook_enabled "auto-lint"; then
        log "Auto-lint hook disabled"
        exit 0
    fi

    # 2. Extract file path
    FILE_PATH=$(get_file_path_from_tool_call)
    if [[ -z "$FILE_PATH" ]]; then
        exit 0
    fi

    log "Linting file: $FILE_PATH"

    # 3. Run linter based on file type
    FILE_EXT="${FILE_PATH##*.}"
    PROJECT_TYPE=$(detect_project_type)

    lint_file "$FILE_PATH" "$FILE_EXT" "$PROJECT_TYPE"
}

lint_file() {
    local file_path="$1"
    local file_ext="$2"
    local project_type="$3"

    case "$file_ext" in
        ts|tsx|js|jsx)
            lint_javascript "$file_path"
            ;;
        py)
            lint_python "$file_path"
            ;;
        go)
            lint_go "$file_path"
            ;;
        rs)
            lint_rust "$file_path"
            ;;
        *)
            log "SKIP: No linter for extension: $file_ext"
            ;;
    esac
}

lint_javascript() {
    local file_path="$1"

    if command_exists eslint; then
        log "Running eslint on $file_path"
        eslint "$file_path" >> "$LOG_FILE" 2>&1 || {
            echo "⚠️  Lint warnings found in $file_path (check $LOG_FILE)" >&2
        }
    else
        log "SKIP: eslint not available"
    fi
}

lint_python() {
    local file_path="$1"

    if command_exists pylint; then
        log "Running pylint on $file_path"
        pylint "$file_path" >> "$LOG_FILE" 2>&1 || {
            echo "⚠️  Lint warnings found in $file_path (check $LOG_FILE)" >&2
        }
    elif command_exists flake8; then
        log "Running flake8 on $file_path"
        flake8 "$file_path" >> "$LOG_FILE" 2>&1 || {
            echo "⚠️  Lint warnings found in $file_path (check $LOG_FILE)" >&2
        }
    else
        log "SKIP: No Python linter available"
    fi
}

lint_go() {
    local file_path="$1"

    if command_exists golangci-lint; then
        log "Running golangci-lint on $file_path"
        golangci-lint run "$file_path" >> "$LOG_FILE" 2>&1 || {
            echo "⚠️  Lint warnings found in $file_path (check $LOG_FILE)" >&2
        }
    else
        log "SKIP: golangci-lint not available"
    fi
}

lint_rust() {
    local file_path="$1"

    if command_exists cargo; then
        log "Running clippy on $file_path"
        cargo clippy -- "$file_path" >> "$LOG_FILE" 2>&1 || {
            echo "⚠️  Lint warnings found in $file_path (check $LOG_FILE)" >&2
        }
    else
        log "SKIP: cargo not available"
    fi
}

main "$@"
