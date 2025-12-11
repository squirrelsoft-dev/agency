#!/bin/bash
# Script to track which enhancements have been created
cd /Users/sbeardsley/Developer/squirrelsoft-dev/agency/enhancements/agents
echo "Enhancement documents created so far:"
ls -1 *.md | wc -l
echo "Total agents to process: 52 (51 + orchestrator)"
