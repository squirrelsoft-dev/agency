#!/usr/bin/env bash

# validate-phase2-commands.sh
# Validates Phase 2 commands for structural correctness and completeness

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Commands to test
COMMANDS=(
  "sprint"
  "refactor"
  "optimize"
  "document"
  "security"
  "adr"
  "deploy"
)

COMMANDS_DIR="../commands"

# Helper functions
pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((PASSED_TESTS++))
  ((TOTAL_TESTS++))
}

fail() {
  echo -e "${RED}✗${NC} $1"
  ((FAILED_TESTS++))
  ((TOTAL_TESTS++))
}

warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Test functions

test_file_exists() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  if [ -f "$file" ]; then
    pass "File exists: ${command}.md"
    return 0
  else
    fail "File missing: ${command}.md"
    return 1
  fi
}

test_yaml_frontmatter() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Check for YAML frontmatter delimiters
  if head -1 "$file" | grep -q "^---$"; then
    pass "YAML frontmatter starts correctly"
  else
    fail "YAML frontmatter missing opening '---'"
    return 1
  fi

  # Check for closing delimiter
  if head -20 "$file" | tail -n +2 | grep -q "^---$"; then
    pass "YAML frontmatter ends correctly"
  else
    fail "YAML frontmatter missing closing '---'"
    return 1
  fi

  # Check for required fields
  if grep -q "^description:" "$file"; then
    pass "YAML contains 'description' field"
  else
    fail "YAML missing 'description' field"
  fi

  if grep -q "^argument-hint:" "$file"; then
    pass "YAML contains 'argument-hint' field"
  else
    fail "YAML missing 'argument-hint' field"
  fi

  if grep -q "^allowed-tools:" "$file"; then
    pass "YAML contains 'allowed-tools' field"
  else
    fail "YAML missing 'allowed-tools' field"
  fi
}

test_command_structure() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Required sections
  local required_sections=(
    "# .*: \\\$ARGUMENTS"
    "## Your Mission"
    "## Critical Instructions"
    "## Phase 0: Project Context Detection"
    "## Error Handling"
    "## Important Notes"
    "## Skills to Reference"
    "## Related Commands"
  )

  for section in "${required_sections[@]}"; do
    if grep -q "$section" "$file"; then
      pass "Contains section: ${section//\\/}"
    else
      fail "Missing section: ${section//\\/}"
    fi
  done
}

test_skill_activation() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Check for skill activation instruction
  if grep -q "agency-workflow-patterns" "$file"; then
    pass "References required 'agency-workflow-patterns' skill"
  else
    fail "Missing reference to 'agency-workflow-patterns' skill"
  fi

  # Check for IMMEDIATELY keyword in skill activation
  if grep -q "IMMEDIATELY.*agency-workflow-patterns" "$file"; then
    pass "Instructs immediate skill activation"
  else
    warn "Should instruct IMMEDIATE skill activation"
  fi
}

test_todowrite_usage() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Check for TodoWrite mentions
  if grep -qi "TodoWrite" "$file"; then
    pass "References TodoWrite for progress tracking"
  else
    warn "Should reference TodoWrite for progress tracking"
  fi

  # Check for todo list creation
  if grep -qi "Use TodoWrite to create tracking" "$file" || \
     grep -qi "create.*todo.*list" "$file"; then
    pass "Instructs todo list creation"
  else
    warn "Should instruct todo list creation"
  fi
}

test_askuserquestion_usage() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Check for AskUserQuestion usage
  if grep -qi "AskUserQuestion" "$file"; then
    pass "Uses AskUserQuestion for user interaction"
  else
    fail "Should use AskUserQuestion for critical decisions"
  fi
}

test_agent_spawning() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Check for Task tool usage
  if grep -qi "Task tool" "$file" || grep -qi "Spawn.*agent" "$file"; then
    pass "Includes agent spawning pattern"
  else
    fail "Should include agent spawning with Task tool"
  fi

  # Check for agent selection guidance
  if grep -q "| .* | .* |" "$file"; then
    pass "Contains agent selection table/guidance"
  else
    warn "Should contain agent selection guidance"
  fi
}

test_phase_structure() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Count phases
  local phase_count=$(grep -c "^## Phase [0-9]" "$file" || true)

  if [ "$phase_count" -ge 4 ]; then
    pass "Contains $phase_count phases (minimum 4)"
  else
    fail "Only contains $phase_count phases (minimum 4 required)"
  fi

  # Check phase numbering is sequential
  local expected_phase=0
  local sequential=true
  while IFS= read -r line; do
    if echo "$line" | grep -q "^## Phase [0-9]"; then
      local phase_num=$(echo "$line" | sed 's/^## Phase \([0-9]\).*/\1/')
      if [ "$phase_num" -ne "$expected_phase" ]; then
        sequential=false
        break
      fi
      ((expected_phase++))
    fi
  done < "$file"

  if [ "$sequential" = true ]; then
    pass "Phase numbering is sequential"
  else
    fail "Phase numbering is not sequential"
  fi
}

test_project_detection() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Check for Phase 0: Project Context Detection
  if grep -q "## Phase 0: Project Context Detection" "$file"; then
    pass "Contains Phase 0: Project Context Detection"
  else
    fail "Missing Phase 0: Project Context Detection"
    return
  fi

  # Check for framework detection
  if grep -q "Detect Framework" "$file" || grep -q "FRAMEWORK=" "$file"; then
    pass "Includes framework detection"
  else
    warn "Should include framework detection"
  fi

  # Check for bash detection commands
  if grep -q "\[ -f \"next.config" "$file" || \
     grep -q "\[ -f \"package.json" "$file"; then
    pass "Uses bash file existence checks for detection"
  else
    warn "Should use bash commands for project detection"
  fi
}

test_error_handling() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Check Error Handling section exists
  if ! grep -q "## Error Handling" "$file"; then
    fail "Missing Error Handling section"
    return
  fi

  # Check for multiple error scenarios
  local error_count=$(grep -c "^### If " "$file" || true)

  if [ "$error_count" -ge 3 ]; then
    pass "Documents $error_count error scenarios"
  else
    warn "Only documents $error_count error scenarios (recommend 3+)"
  fi
}

test_code_examples() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  # Count code blocks
  local code_block_count=$(grep -c '```' "$file" || true)
  local code_block_pairs=$((code_block_count / 2))

  if [ "$code_block_pairs" -ge 5 ]; then
    pass "Contains $code_block_pairs code examples"
  else
    warn "Only contains $code_block_pairs code examples (more recommended)"
  fi

  # Check for bash code blocks
  if grep -q '```bash' "$file"; then
    pass "Includes bash script examples"
  else
    warn "Should include bash script examples"
  fi
}

test_command_specific() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  case "$command" in
    "sprint")
      # Sprint-specific tests
      if grep -qi "dependency" "$file"; then
        pass "[Sprint] Mentions dependency resolution"
      else
        fail "[Sprint] Should mention dependency resolution"
      fi

      if grep -qi "parallel" "$file"; then
        pass "[Sprint] Mentions parallel execution"
      else
        fail "[Sprint] Should mention parallel execution"
      fi

      if grep -qi "GitHub\|Jira" "$file"; then
        pass "[Sprint] References GitHub/Jira providers"
      else
        fail "[Sprint] Should reference provider support"
      fi
      ;;

    "refactor")
      # Refactor-specific tests
      if grep -qi "rollback\|checkpoint" "$file"; then
        pass "[Refactor] Mentions rollback/checkpoint strategy"
      else
        fail "[Refactor] Should mention rollback strategy"
      fi

      if grep -qi "incremental" "$file"; then
        pass "[Refactor] Mentions incremental refactoring"
      else
        fail "[Refactor] Should mention incremental approach"
      fi

      if grep -qi "test.*pass" "$file"; then
        pass "[Refactor] Emphasizes test preservation"
      else
        fail "[Refactor] Should emphasize test preservation"
      fi
      ;;

    "optimize")
      # Optimize-specific tests
      if grep -qi "benchmark\|profil" "$file"; then
        pass "[Optimize] Mentions benchmarking/profiling"
      else
        fail "[Optimize] Should mention benchmarking"
      fi

      if grep -qi "baseline" "$file"; then
        pass "[Optimize] Mentions baseline measurement"
      else
        fail "[Optimize] Should mention baseline measurement"
      fi

      if grep -qi "lighthouse\|bundle-analyzer\|autocannon" "$file"; then
        pass "[Optimize] References profiling tools"
      else
        warn "[Optimize] Should reference specific profiling tools"
      fi
      ;;

    "document")
      # Document-specific tests
      if grep -qi "template" "$file"; then
        pass "[Document] Mentions documentation templates"
      else
        fail "[Document] Should mention templates"
      fi

      if grep -qi "validate.*example\|example.*valid" "$file"; then
        pass "[Document] Includes code example validation"
      else
        fail "[Document] Should validate code examples"
      fi

      if grep -qi "API\|Architecture\|Component" "$file"; then
        pass "[Document] References documentation types"
      else
        fail "[Document] Should reference different doc types"
      fi
      ;;

    "security")
      # Security-specific tests
      if grep -qi "vulnerability\|vulnerabilities" "$file"; then
        pass "[Security] Mentions vulnerability scanning"
      else
        fail "[Security] Should mention vulnerability scanning"
      fi

      if grep -qi "OWASP" "$file"; then
        pass "[Security] References OWASP Top 10"
      else
        fail "[Security] Should reference OWASP Top 10"
      fi

      if grep -qi "secrets\|credentials" "$file"; then
        pass "[Security] Includes secrets detection"
      else
        fail "[Security] Should include secrets detection"
      fi
      ;;

    "adr")
      # ADR-specific tests
      if grep -qi "decision.*record\|ADR" "$file"; then
        pass "[ADR] Mentions Architecture Decision Records"
      else
        fail "[ADR] Should mention ADRs"
      fi

      if grep -qi "alternatives" "$file"; then
        pass "[ADR] Includes alternatives section"
      else
        fail "[ADR] Should include alternatives"
      fi

      if grep -qi "consequences" "$file"; then
        pass "[ADR] Mentions consequences"
      else
        fail "[ADR] Should mention consequences"
      fi
      ;;

    "deploy")
      # Deploy-specific tests
      if grep -qi "pre-flight\|preflight" "$file"; then
        pass "[Deploy] Mentions pre-flight checks"
      else
        fail "[Deploy] Should mention pre-flight checks"
      fi

      if grep -qi "rollback" "$file"; then
        pass "[Deploy] Includes rollback strategy"
      else
        fail "[Deploy] Should include rollback strategy"
      fi

      if grep -qi "health.*check\|smoke.*test" "$file"; then
        pass "[Deploy] Mentions health checks or smoke tests"
      else
        fail "[Deploy] Should mention health checks"
      fi
      ;;
  esac
}

test_file_size() {
  local command=$1
  local file="$COMMANDS_DIR/${command}.md"

  local size=$(wc -l < "$file")
  local expected_min=400
  local expected_max=1500

  if [ "$size" -ge "$expected_min" ] && [ "$size" -le "$expected_max" ]; then
    pass "File size: $size lines (within expected range)"
  elif [ "$size" -lt "$expected_min" ]; then
    warn "File size: $size lines (expected minimum $expected_min)"
  else
    info "File size: $size lines (larger than typical, but acceptable)"
  fi
}

# Main test execution

main() {
  header "Phase 2 Commands Validation Test Suite"

  info "Testing $(echo ${COMMANDS[@]} | wc -w) commands"
  echo ""

  for command in "${COMMANDS[@]}"; do
    header "Testing: /agency:${command}"

    # Run all tests for this command
    test_file_exists "$command" || continue
    test_file_size "$command"
    test_yaml_frontmatter "$command"
    test_command_structure "$command"
    test_phase_structure "$command"
    test_project_detection "$command"
    test_skill_activation "$command"
    test_todowrite_usage "$command"
    test_askuserquestion_usage "$command"
    test_agent_spawning "$command"
    test_error_handling "$command"
    test_code_examples "$command"
    test_command_specific "$command"
  done

  # Summary
  header "Test Summary"

  echo ""
  echo "Total Tests: $TOTAL_TESTS"
  echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
  echo -e "${RED}Failed: $FAILED_TESTS${NC}"
  echo ""

  local pass_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))

  if [ "$FAILED_TESTS" -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! (100%)${NC}"
    exit 0
  elif [ "$pass_rate" -ge 90 ]; then
    echo -e "${YELLOW}⚠ ${pass_rate}% tests passed (${FAILED_TESTS} failures)${NC}"
    exit 1
  else
    echo -e "${RED}✗ ${pass_rate}% tests passed (${FAILED_TESTS} failures)${NC}"
    exit 1
  fi
}

# Run tests
cd "$(dirname "$0")"
main
