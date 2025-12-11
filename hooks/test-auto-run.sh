#!/bin/bash
#
# Test auto-run hook for Agency plugin
# Runs tests after Edit/Write operations
# Performance: Very slow (30+ seconds)
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

LOG_FILE="/tmp/agency-hooks-test-auto-run.log"

# ============================================================================
# Main Logic
# ============================================================================

main() {
    log "=== Test auto-run hook triggered ==="

    # 1. Check if hook is enabled
    if ! is_hook_enabled "test-auto-run"; then
        log "Test auto-run hook disabled"
        exit 0
    fi

    # 2. Extract file path
    FILE_PATH=$(get_file_path_from_tool_call)
    if [[ -z "$FILE_PATH" ]]; then
        exit 0
    fi

    log "Running tests after editing: $FILE_PATH"

    # 3. Run tests
    PROJECT_TYPE=$(detect_project_type)

    run_tests "$PROJECT_TYPE"
}

run_tests() {
    local project_type="$1"

    case "$project_type" in
        typescript|javascript|nextjs)
            run_javascript_tests
            ;;
        python)
            run_python_tests
            ;;
        go)
            run_go_tests
            ;;
        rust)
            run_rust_tests
            ;;
        *)
            log "SKIP: No test command for project type: $project_type"
            ;;
    esac
}

run_javascript_tests() {
    if [[ -f "package.json" ]] && grep -q '"test":' package.json; then
        log "Running npm test"
        if npm test >> "$LOG_FILE" 2>&1; then
            log "✅ Tests passed"
        else
            echo "⚠️  Tests failed (check $LOG_FILE)" >&2
        fi
    else
        log "SKIP: No test script in package.json"
    fi
}

run_python_tests() {
    if command_exists pytest; then
        log "Running pytest"
        if pytest >> "$LOG_FILE" 2>&1; then
            log "✅ Tests passed"
        else
            echo "⚠️  Tests failed (check $LOG_FILE)" >&2
        fi
    elif [[ -f "manage.py" ]]; then
        log "Running Django tests"
        if python manage.py test >> "$LOG_FILE" 2>&1; then
            log "✅ Tests passed"
        else
            echo "⚠️  Tests failed (check $LOG_FILE)" >&2
        fi
    else
        log "SKIP: No test framework available"
    fi
}

run_go_tests() {
    log "Running go test ./..."
    if go test ./... >> "$LOG_FILE" 2>&1; then
        log "✅ Tests passed"
    else
        echo "⚠️  Tests failed (check $LOG_FILE)" >&2
    fi
}

run_rust_tests() {
    log "Running cargo test"
    if cargo test >> "$LOG_FILE" 2>&1; then
        log "✅ Tests passed"
    else
        echo "⚠️  Tests failed (check $LOG_FILE)" >&2
    fi
}

main "$@"
