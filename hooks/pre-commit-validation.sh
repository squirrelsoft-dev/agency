#!/bin/bash
#
# Pre-commit validation hook for Agency plugin
# Runs build, lint, and tests before allowing git commit
# Performance: Slow (10-30 seconds) but critical quality gate
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

LOG_FILE="/tmp/agency-hooks-pre-commit.log"

# ============================================================================
# Main Logic
# ============================================================================

main() {
    log "=== Pre-commit validation hook triggered ==="

    # 1. Check if this is a git commit command
    if ! is_git_commit_command; then
        log "Not a git commit command, skipping"
        exit 0
    fi

    # 2. Check if hook is enabled
    if ! is_hook_enabled "pre-commit-validation"; then
        log "Pre-commit validation disabled in settings"
        exit 0
    fi

    log "Running pre-commit validation..."

    # 3. Run quality gates based on settings
    local failed=0

    # Build verification
    if should_require_build_pass; then
        log "Checking build..."
        if ! run_build_check; then
            echo "❌ Build failed. Cannot commit." >&2
            failed=1
        else
            log "✅ Build passed"
        fi
    fi

    # Lint verification
    if should_require_lint_pass; then
        log "Checking lint..."
        if ! run_lint_check; then
            echo "❌ Lint failed. Cannot commit." >&2
            failed=1
        else
            log "✅ Lint passed"
        fi
    fi

    # Test verification
    if should_require_tests_pass; then
        log "Running tests..."
        if ! run_test_check; then
            echo "❌ Tests failed. Cannot commit." >&2
            failed=1
        else
            log "✅ Tests passed"
        fi
    fi

    # Type check verification (TypeScript)
    if should_require_type_check; then
        log "Checking types..."
        if ! run_type_check; then
            echo "❌ Type check failed. Cannot commit." >&2
            failed=1
        else
            log "✅ Type check passed"
        fi
    fi

    # 4. Exit with failure if any check failed
    if [[ $failed -eq 1 ]]; then
        echo "" >&2
        echo "Pre-commit validation failed. Fix the errors and try again." >&2
        echo "Or disable validation in settings: enable_pre_commit_validation: false" >&2
        exit 1
    fi

    log "✅ Pre-commit validation passed"
    exit 0
}

# ============================================================================
# Git Detection
# ============================================================================

is_git_commit_command() {
    # Extract command from tool call
    local command=$(get_command_from_tool_call)

    if [[ -z "$command" ]]; then
        return 1
    fi

    # Check if command contains "git commit"
    if echo "$command" | grep -qE "git\s+commit"; then
        return 0
    fi

    return 1
}

# ============================================================================
# Quality Gate Checks
# ============================================================================

run_build_check() {
    local project_type=$(detect_project_type)

    case "$project_type" in
        typescript|javascript|nextjs)
            # Try different build commands
            if [[ -f "package.json" ]]; then
                if grep -q '"build":' package.json; then
                    npm run build >> "$LOG_FILE" 2>&1
                    return $?
                fi
            fi
            ;;
        python)
            # Python projects might have build scripts
            if [[ -f "setup.py" ]]; then
                python setup.py build >> "$LOG_FILE" 2>&1
                return $?
            fi
            ;;
        go)
            go build ./... >> "$LOG_FILE" 2>&1
            return $?
            ;;
        rust)
            cargo build >> "$LOG_FILE" 2>&1
            return $?
            ;;
    esac

    log "No build command found, skipping"
    return 0
}

run_lint_check() {
    local project_type=$(detect_project_type)

    case "$project_type" in
        typescript|javascript|nextjs)
            if command_exists eslint; then
                eslint . --max-warnings 0 >> "$LOG_FILE" 2>&1
                return $?
            elif [[ -f "package.json" ]] && grep -q '"lint":' package.json; then
                npm run lint >> "$LOG_FILE" 2>&1
                return $?
            fi
            ;;
        python)
            if command_exists pylint; then
                pylint **/*.py >> "$LOG_FILE" 2>&1
                return $?
            elif command_exists flake8; then
                flake8 . >> "$LOG_FILE" 2>&1
                return $?
            fi
            ;;
        go)
            if command_exists golangci-lint; then
                golangci-lint run >> "$LOG_FILE" 2>&1
                return $?
            fi
            ;;
        rust)
            if command_exists cargo; then
                cargo clippy -- -D warnings >> "$LOG_FILE" 2>&1
                return $?
            fi
            ;;
    esac

    log "No linter found, skipping"
    return 0
}

run_test_check() {
    local project_type=$(detect_project_type)

    case "$project_type" in
        typescript|javascript|nextjs)
            if [[ -f "package.json" ]] && grep -q '"test":' package.json; then
                npm test >> "$LOG_FILE" 2>&1
                return $?
            fi
            ;;
        python)
            if command_exists pytest; then
                pytest >> "$LOG_FILE" 2>&1
                return $?
            elif [[ -f "manage.py" ]]; then
                python manage.py test >> "$LOG_FILE" 2>&1
                return $?
            fi
            ;;
        go)
            go test ./... >> "$LOG_FILE" 2>&1
            return $?
            ;;
        rust)
            cargo test >> "$LOG_FILE" 2>&1
            return $?
            ;;
    esac

    log "No test command found, skipping"
    return 0
}

run_type_check() {
    local project_type=$(detect_project_type)

    if [[ "$project_type" == "typescript" || "$project_type" == "nextjs" ]]; then
        if command_exists tsc; then
            tsc --noEmit >> "$LOG_FILE" 2>&1
            return $?
        fi
    fi

    log "No type checker found, skipping"
    return 0
}

# ============================================================================
# Settings Checks
# ============================================================================

should_require_build_pass() {
    local enabled=$(get_setting "quality_gates.require_build_pass" "true")
    [[ "$enabled" == "true" ]]
}

should_require_lint_pass() {
    local enabled=$(get_setting "quality_gates.require_lint_pass" "false")
    [[ "$enabled" == "true" ]]
}

should_require_tests_pass() {
    local enabled=$(get_setting "quality_gates.require_tests" "true")
    [[ "$enabled" == "true" ]]
}

should_require_type_check() {
    local enabled=$(get_setting "quality_gates.require_type_check" "true")
    [[ "$enabled" == "true" ]]
}

# ============================================================================
# Execute
# ============================================================================

main "$@"
