#!/bin/bash
# generate.sh - Extract today's Claude Code session logs and generate a FlipBook HTML
#
# Usage: ./generate.sh [YYYY-MM-DD]
# If no date provided, defaults to today.
#
# Output: /tmp/claude/daily-flipbook/YYYY-MM-DD.html

set -euo pipefail

DATE="${1:-$(date +%Y-%m-%d)}"
YEAR=$(echo "$DATE" | cut -d'-' -f1)
MONTH=$(echo "$DATE" | cut -d'-' -f2)
DAY=$(echo "$DATE" | cut -d'-' -f3)
DISPLAY_DATE="${YEAR}年${MONTH}月${DAY}日"

OUTPUT_DIR="/tmp/claude/daily-flipbook"
OUTPUT_FILE="$OUTPUT_DIR/$DATE.html"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/template.html"

mkdir -p "$OUTPUT_DIR"

# ── Collect session logs from both paths ──
SEARCH_PATHS=(
  "$HOME/.claude/projects"
  "$HOME/claude-data/projects"
)

touch -t "${YEAR}${MONTH}${DAY}0000" /tmp/flipbook_date_marker 2>/dev/null || true

SESSIONS_JSON="[]"
SESSION_COUNT=0

for search_path in "${SEARCH_PATHS[@]}"; do
  if [ ! -d "$search_path" ]; then
    continue
  fi

  # Find JSONL files modified today (skip subagent logs)
  while IFS= read -r logfile; do
    [ -z "$logfile" ] && continue

    # Extract project name from path
    project_dir=$(basename "$(dirname "$logfile")")

    # Parse user messages and assistant tool uses
    if command -v jq &>/dev/null; then
      # Extract summary: user messages (first 200 chars each)
      user_msgs=$(jq -r '
        select(.type == "user")
        | .message
        | if type == "array" then
            map(select(.type == "text") | .text) | join(" ")
          elif type == "string" then .
          else empty
          end
        | .[0:200]
      ' "$logfile" 2>/dev/null | head -20)

      # Extract tool uses (file writes, edits, commands)
      tool_actions=$(jq -r '
        select(.type == "assistant")
        | .message[]?
        | select(.type == "tool_use")
        | "\(.name): \(.input.file_path // .input.command // .input.pattern // "" | .[0:100])"
      ' "$logfile" 2>/dev/null | head -30)

      if [ -n "$user_msgs" ]; then
        SESSION_COUNT=$((SESSION_COUNT + 1))
        echo "--- Session $SESSION_COUNT: $project_dir ---" >> /tmp/flipbook_sessions_$DATE.txt
        echo "$user_msgs" >> /tmp/flipbook_sessions_$DATE.txt
        echo "" >> /tmp/flipbook_sessions_$DATE.txt
        if [ -n "$tool_actions" ]; then
          echo "Tools used:" >> /tmp/flipbook_sessions_$DATE.txt
          echo "$tool_actions" >> /tmp/flipbook_sessions_$DATE.txt
          echo "" >> /tmp/flipbook_sessions_$DATE.txt
        fi
      fi
    fi
  done < <(find "$search_path" -name "*.jsonl" -newer /tmp/flipbook_date_marker -not -path "*/subagents/*" 2>/dev/null)
done

# ── Output results ──
SESSIONS_FILE="/tmp/flipbook_sessions_$DATE.txt"

if [ ! -f "$SESSIONS_FILE" ] || [ ! -s "$SESSIONS_FILE" ]; then
  echo "No session logs found for $DATE"
  echo "Searched paths:"
  for p in "${SEARCH_PATHS[@]}"; do
    echo "  - $p"
  done
  exit 1
fi

echo "Found $SESSION_COUNT sessions for $DATE"
echo "Session data saved to: $SESSIONS_FILE"
echo ""
echo "To generate the FlipBook, run this in Claude Code:"
echo ""
echo "  /daily-flipbook"
echo ""
echo "Or ask Claude Code:"
echo "  \"$SESSIONS_FILE を読んで、template.html をベースに FlipBook を生成して\""
echo ""
echo "Template: $TEMPLATE"
echo "Output will be: $OUTPUT_FILE"
