#!/bin/bash
#
# Project type detection utilities
# Auto-detects TypeScript, JavaScript, Python, Go, Rust projects
#

detect_project_type() {
    local cwd="${PWD}"

    # Next.js
    if [[ -f "$cwd/next.config.js" ]] || [[ -f "$cwd/next.config.ts" ]] || [[ -f "$cwd/next.config.mjs" ]]; then
        echo "nextjs"
        return 0
    fi

    # TypeScript
    if [[ -f "$cwd/tsconfig.json" ]]; then
        echo "typescript"
        return 0
    fi

    # JavaScript (Node.js)
    if [[ -f "$cwd/package.json" ]]; then
        echo "javascript"
        return 0
    fi

    # Python
    if [[ -f "$cwd/setup.py" ]] || [[ -f "$cwd/pyproject.toml" ]] || [[ -f "$cwd/requirements.txt" ]]; then
        echo "python"
        return 0
    fi

    # Go
    if [[ -f "$cwd/go.mod" ]]; then
        echo "go"
        return 0
    fi

    # Rust
    if [[ -f "$cwd/Cargo.toml" ]]; then
        echo "rust"
        return 0
    fi

    # Unknown
    echo "unknown"
}

detect_test_framework() {
    local project_type="${1:-unknown}"

    case "$project_type" in
        typescript|javascript|nextjs)
            if [[ -f "jest.config.js" ]] || [[ -f "jest.config.ts" ]]; then
                echo "jest"
            elif [[ -f "vitest.config.ts" ]] || [[ -f "vitest.config.js" ]]; then
                echo "vitest"
            else
                echo "unknown"
            fi
            ;;
        python)
            if command -v pytest >/dev/null 2>&1; then
                echo "pytest"
            else
                echo "unittest"
            fi
            ;;
        go)
            echo "go-test"
            ;;
        rust)
            echo "cargo-test"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}
