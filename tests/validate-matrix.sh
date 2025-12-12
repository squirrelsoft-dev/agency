#!/usr/bin/env bash
#
# validate-matrix.sh - Validate agent capability matrix integrity
#
# This script ensures the agent-capabilities.json file stays in sync with
# the actual agent markdown files in the agents/ directory.
#
# Usage:
#   ./scripts/validate-matrix.sh
#
# Exit codes:
#   0 - All validations passed
#   1 - Validation errors found
#   2 - Required files missing
#
# Can be used in:
#   - Pre-commit hooks
#   - CI/CD pipelines
#   - Manual validation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track validation results
ERRORS=0
WARNINGS=0

# File paths
MATRIX_JSON=".agency/agent-capabilities.json"
AGENTS_DIR="agents"
MATRIX_MD="docs/agent-capability-matrix.md"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Agent Capability Matrix Validator${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check required files exist
if [[ ! -f "$MATRIX_JSON" ]]; then
  echo -e "${RED}✗ Error: $MATRIX_JSON not found${NC}"
  exit 2
fi

if [[ ! -d "$AGENTS_DIR" ]]; then
  echo -e "${RED}✗ Error: $AGENTS_DIR directory not found${NC}"
  exit 2
fi

if ! command -v jq &> /dev/null; then
  echo -e "${YELLOW}⚠ Warning: jq not installed. Install with: brew install jq${NC}"
  echo -e "${YELLOW}  Some validations will be skipped.${NC}"
  WARNINGS=$((WARNINGS + 1))
  JQ_AVAILABLE=false
else
  JQ_AVAILABLE=true
fi

echo "Validating agent capability matrix..."
echo ""

# ================================
# Test 1: Agent count validation
# ================================
echo -e "${BLUE}[1/7]${NC} Validating agent count..."

# Count agents in filesystem
AGENT_FILES=$(find "$AGENTS_DIR" -name "*.md" -type f | wc -l | tr -d ' ')

if [[ "$JQ_AVAILABLE" == true ]]; then
  # Count agents in JSON
  JSON_COUNT=$(jq '.agents | length' "$MATRIX_JSON")
  JSON_TOTAL=$(jq -r '.total_agents' "$MATRIX_JSON")

  if [[ "$AGENT_FILES" -ne "$JSON_COUNT" ]]; then
    echo -e "${RED}✗ Agent count mismatch:${NC}"
    echo -e "  Filesystem: $AGENT_FILES agent files"
    echo -e "  JSON: $JSON_COUNT agents"
    ERRORS=$((ERRORS + 1))
  elif [[ "$JSON_COUNT" -ne "$JSON_TOTAL" ]]; then
    echo -e "${RED}✗ JSON metadata mismatch:${NC}"
    echo -e "  agents array: $JSON_COUNT"
    echo -e "  total_agents field: $JSON_TOTAL"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}✓ Agent count valid: $AGENT_FILES agents${NC}"
  fi
else
  echo -e "${YELLOW}⚠ Skipped (jq not available)${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# ================================
# Test 2: Agent file existence
# ================================
echo -e "${BLUE}[2/7]${NC} Validating agent files exist..."

if [[ "$JQ_AVAILABLE" == true ]]; then
  MISSING_FILES=0
  while IFS= read -r filepath; do
    if [[ ! -f "$filepath" ]]; then
      if [[ $MISSING_FILES -eq 0 ]]; then
        echo -e "${RED}✗ Missing agent files:${NC}"
      fi
      echo -e "  - $filepath"
      MISSING_FILES=$((MISSING_FILES + 1))
      ERRORS=$((ERRORS + 1))
    fi
  done < <(jq -r '.agents[].file_path' "$MATRIX_JSON")

  if [[ $MISSING_FILES -eq 0 ]]; then
    echo -e "${GREEN}✓ All agent files exist${NC}"
  fi
else
  echo -e "${YELLOW}⚠ Skipped (jq not available)${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# ================================
# Test 3: Agent ID uniqueness
# ================================
echo -e "${BLUE}[3/7]${NC} Validating agent ID uniqueness..."

if [[ "$JQ_AVAILABLE" == true ]]; then
  DUPLICATE_IDS=$(jq -r '.agents[].id' "$MATRIX_JSON" | sort | uniq -d)

  if [[ -n "$DUPLICATE_IDS" ]]; then
    echo -e "${RED}✗ Duplicate agent IDs found:${NC}"
    echo "$DUPLICATE_IDS" | while read -r id; do
      echo -e "  - $id"
    done
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}✓ All agent IDs unique${NC}"
  fi
else
  echo -e "${YELLOW}⚠ Skipped (jq not available)${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# ================================
# Test 4: Required fields present
# ================================
echo -e "${BLUE}[4/7]${NC} Validating required fields..."

if [[ "$JQ_AVAILABLE" == true ]]; then
  REQUIRED_FIELDS=("id" "name" "display_name" "category" "file_path" "description")
  MISSING_FIELDS=0

  for field in "${REQUIRED_FIELDS[@]}"; do
    NULL_COUNT=$(jq "[.agents[] | select(.$field == null or .$field == \"\")] | length" "$MATRIX_JSON")

    if [[ "$NULL_COUNT" -gt 0 ]]; then
      if [[ $MISSING_FIELDS -eq 0 ]]; then
        echo -e "${RED}✗ Missing required fields:${NC}"
      fi
      echo -e "  - $field: $NULL_COUNT agents missing"
      MISSING_FIELDS=$((MISSING_FIELDS + 1))
      ERRORS=$((ERRORS + 1))
    fi
  done

  if [[ $MISSING_FIELDS -eq 0 ]]; then
    echo -e "${GREEN}✓ All required fields present${NC}"
  fi
else
  echo -e "${YELLOW}⚠ Skipped (jq not available)${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# ================================
# Test 5: Category consistency
# ================================
echo -e "${BLUE}[5/7]${NC} Validating category consistency..."

if [[ "$JQ_AVAILABLE" == true ]]; then
  INVALID_CATEGORIES=0

  # Expected categories from directory structure
  EXPECTED_CATEGORIES=("engineering" "testing" "design" "marketing" "product" "project-management" "support" "spatial-computing" "specialized" "meta")

  # Get unique categories from JSON
  JSON_CATEGORIES=$(jq -r '.agents[].category' "$MATRIX_JSON" | sort -u)

  # Check for unexpected categories
  while IFS= read -r category; do
    if [[ ! " ${EXPECTED_CATEGORIES[@]} " =~ " ${category} " ]]; then
      if [[ $INVALID_CATEGORIES -eq 0 ]]; then
        echo -e "${YELLOW}⚠ Unexpected categories:${NC}"
      fi
      echo -e "  - $category"
      INVALID_CATEGORIES=$((INVALID_CATEGORIES + 1))
      WARNINGS=$((WARNINGS + 1))
    fi
  done <<< "$JSON_CATEGORIES"

  if [[ $INVALID_CATEGORIES -eq 0 ]]; then
    echo -e "${GREEN}✓ All categories valid${NC}"
  fi
else
  echo -e "${YELLOW}⚠ Skipped (jq not available)${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# ================================
# Test 6: Index integrity
# ================================
echo -e "${BLUE}[6/7]${NC} Validating indices integrity..."

if [[ "$JQ_AVAILABLE" == true ]]; then
  INDEX_ERRORS=0

  # Check by_category index
  AGENTS_COUNT=$(jq '.agents | length' "$MATRIX_JSON")
  INDEXED_COUNT=$(jq '[.indices.by_category | to_entries[] | .value[]] | unique | length' "$MATRIX_JSON")

  if [[ "$AGENTS_COUNT" -ne "$INDEXED_COUNT" ]]; then
    echo -e "${RED}✗ by_category index mismatch:${NC}"
    echo -e "  Total agents: $AGENTS_COUNT"
    echo -e "  Indexed agents: $INDEXED_COUNT"
    INDEX_ERRORS=$((INDEX_ERRORS + 1))
    ERRORS=$((ERRORS + 1))
  fi

  # Check that all indexed agents exist
  ORPHANED_REFS=$(jq -r '
    [.agents[].id] as $agent_ids |
    [.indices.by_category | to_entries[] | .value[]] | unique |
    map(select(. as $id | $agent_ids | index($id) | not))
  ' "$MATRIX_JSON")

  ORPHANED_COUNT=$(echo "$ORPHANED_REFS" | jq 'length')
  if [[ "$ORPHANED_COUNT" -gt 0 ]]; then
    echo -e "${RED}✗ Orphaned index references: $ORPHANED_COUNT${NC}"
    INDEX_ERRORS=$((INDEX_ERRORS + 1))
    ERRORS=$((ERRORS + 1))
  fi

  if [[ $INDEX_ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✓ All indices valid${NC}"
  fi
else
  echo -e "${YELLOW}⚠ Skipped (jq not available)${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# ================================
# Test 7: Markdown documentation sync
# ================================
echo -e "${BLUE}[7/7]${NC} Validating markdown documentation..."

if [[ -f "$MATRIX_MD" ]]; then
  if [[ "$JQ_AVAILABLE" == true ]]; then
    # Check if markdown has all agent IDs mentioned
    MD_MISSING=0
    while IFS= read -r agent_id; do
      if ! grep -q "^### $agent_id" "$MATRIX_MD"; then
        if [[ $MD_MISSING -eq 0 ]]; then
          echo -e "${YELLOW}⚠ Agents missing from markdown:${NC}"
        fi
        echo -e "  - $agent_id"
        MD_MISSING=$((MD_MISSING + 1))
        WARNINGS=$((WARNINGS + 1))
      fi
    done < <(jq -r '.agents[].id' "$MATRIX_JSON")

    if [[ $MD_MISSING -eq 0 ]]; then
      echo -e "${GREEN}✓ Markdown documentation in sync${NC}"
    fi
  else
    echo -e "${YELLOW}⚠ Skipped (jq not available)${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo -e "${YELLOW}⚠ $MATRIX_MD not found${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# ================================
# Summary
# ================================
echo ""
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}=====================================${NC}"

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
  echo -e "${GREEN}✓ All validations passed!${NC}"
  exit 0
elif [[ $ERRORS -eq 0 ]]; then
  echo -e "${YELLOW}⚠ Validation passed with $WARNINGS warning(s)${NC}"
  exit 0
else
  echo -e "${RED}✗ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
  echo ""
  echo "To fix errors:"
  echo "  1. Review agent files in $AGENTS_DIR"
  echo "  2. Regenerate matrix: python .agency/extract_agents.py"
  echo "  3. Run this script again to verify"
  exit 1
fi
