#!/bin/bash
#
# Common utilities for Agency hooks
# Provides logging, tool call parsing, and utility functions
#

# ============================================================================
# Logging
# ============================================================================

log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "${LOG_FILE:-/tmp/agency-hooks.log}"
}

# ============================================================================
# Tool Call Parsing
# ============================================================================

get_file_path_from_tool_call() {
    # Extract file_path from $TOOL_CALL_JSON environment variable
    if [[ -z "${TOOL_CALL_JSON:-}" ]]; then
        log "ERROR: TOOL_CALL_JSON not set"
        return 1
    fi

    # Try to extract file_path from tool arguments
    local file_path=$(echo "$TOOL_CALL_JSON" | jq -r '.arguments.file_path // empty')

    if [[ -z "$file_path" ]]; then
        log "WARNING: No file_path in tool call"
        return 1
    fi

    echo "$file_path"
}

get_command_from_tool_call() {
    # Extract command from $TOOL_CALL_JSON environment variable
    if [[ -z "${TOOL_CALL_JSON:-}" ]]; then
        log "ERROR: TOOL_CALL_JSON not set"
        return 1
    fi

    # Try to extract command from tool arguments
    local command=$(echo "$TOOL_CALL_JSON" | jq -r '.arguments.command // empty')

    if [[ -z "$command" ]]; then
        log "WARNING: No command in tool call"
        return 1
    fi

    echo "$command"
}

# ============================================================================
# Command Checks
# ============================================================================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# Settings Reader (Placeholder - implemented in settings-reader.sh)
# ============================================================================

is_hook_enabled() {
    local hook_name="$1"
    # Will be implemented by settings-reader.sh
    # For now, default to enabled
    return 0
}

get_setting() {
    local setting_path="$1"
    local default_value="${2:-}"
    # Will be implemented by settings-reader.sh
    # For now, return default
    echo "$default_value"
}
