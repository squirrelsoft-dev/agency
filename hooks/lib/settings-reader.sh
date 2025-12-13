#!/bin/bash
#
# Settings reader for Agency hooks
# Implements cascading settings: CLI > Project > User > Defaults
#

# ============================================================================
# Settings Paths
# ============================================================================

get_settings_paths() {
    local plugin_root="${PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    local project_root="${PWD}"
    local user_home="${HOME}"

    # Settings cascade order (later overrides earlier)
    echo "${plugin_root}/settings/defaults.yaml"           # 1. Plugin defaults
    echo "${user_home}/.claude/agency.local.md"           # 2. User settings
    echo "${user_home}/.claude/agency.local.yaml"         # 2. User settings (YAML)
    echo "${project_root}/.claude/agency.local.md"        # 3. Project settings
    echo "${project_root}/.claude/agency.local.yaml"      # 3. Project settings (YAML)
}

# ============================================================================
# Hook Enablement
# ============================================================================

is_hook_enabled() {
    local hook_name="$1"

    # Map hook names to setting paths
    case "$hook_name" in
        "auto-format")
            local enabled=$(get_setting "hooks.enable_auto_format" "true")
            ;;
        "pre-commit-validation")
            local enabled=$(get_setting "hooks.enable_pre_commit_validation" "true")
            ;;
        "auto-lint")
            local enabled=$(get_setting "hooks.enable_auto_lint" "false")
            ;;
        "build-verification")
            local enabled=$(get_setting "hooks.enable_build_verification" "false")
            ;;
        "test-auto-run")
            local enabled=$(get_setting "hooks.enable_test_auto_run" "false")
            ;;
        *)
            local enabled="true"  # Unknown hooks enabled by default
            ;;
    esac

    [[ "$enabled" == "true" ]]
}

# ============================================================================
# Setting Retrieval
# ============================================================================

get_setting() {
    local setting_path="$1"
    local default_value="${2:-}"

    # Try to find setting in cascade order (reverse for project to override user)
    local value=""

    # Check each settings file in reverse order (project overrides user)
    while IFS= read -r settings_file; do
        if [[ -f "$settings_file" ]]; then
            value=$(extract_setting_from_file "$settings_file" "$setting_path")
            if [[ -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        fi
    done < <(get_settings_paths | tail -r)  # Reverse order (project overrides user)

    # Not found, return default
    echo "$default_value"
}

extract_setting_from_file() {
    local file="$1"
    local setting_path="$2"

    # Determine file format
    local ext="${file##*.}"

    case "$ext" in
        yaml|yml)
            extract_yaml_setting "$file" "$setting_path"
            ;;
        md)
            # Markdown with YAML frontmatter or inline settings
            # For now, skip - too complex for bash
            # Future: Use Python/Node.js script
            echo ""
            ;;
        json)
            extract_json_setting "$file" "$setting_path"
            ;;
        *)
            echo ""
            ;;
    esac
}

extract_yaml_setting() {
    local file="$1"
    local setting_path="$2"

    # Use yq if available, otherwise skip
    if command -v yq >/dev/null 2>&1; then
        yq eval ".${setting_path}" "$file" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

extract_json_setting() {
    local file="$1"
    local setting_path="$2"

    # Convert dot notation to jq syntax
    local jq_path=$(echo "$setting_path" | sed 's/\./\./g')

    jq -r ".${jq_path} // empty" "$file" 2>/dev/null || echo ""
}
