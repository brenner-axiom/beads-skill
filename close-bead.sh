#!/usr/bin/env bash
# close-bead.sh — Close a bead and its linked GitHub issue (if any)
# Usage: close-bead.sh <bead-id> <reason>
set -euo pipefail

BD="${HOME}/.local/bin/bd"
HUB="${HOME}/.openclaw/workspaces/beads-hub"
REPO="brenner-axiom/beads-hub"

BEAD_ID="${1:?Usage: close-bead.sh <bead-id> <reason>}"
REASON="${2:?Usage: close-bead.sh <bead-id> <reason>}"

cd "$HUB"

# Get bead info before closing
BEAD_JSON=$($BD show "$BEAD_ID" --json 2>/dev/null || echo '{}')
TITLE=$(echo "$BEAD_JSON" | jq -r '.title // ""')
NOTES=$(echo "$BEAD_JSON" | jq -r '.notes // ""')

# Close the bead
$BD close "$BEAD_ID" --reason "$REASON" --json

# Extract GitHub issue number from title (GH#N) or notes
GH_NUM=""
if [[ "$TITLE" =~ GH#([0-9]+) ]]; then
  GH_NUM="${BASH_REMATCH[1]}"
elif [[ "$NOTES" =~ /issues/([0-9]+) ]]; then
  GH_NUM="${BASH_REMATCH[1]}"
fi

# Close the linked GitHub issue if found
if [ -n "$GH_NUM" ]; then
  echo "Closing linked GitHub issue #${GH_NUM}..."
  gh issue comment "$GH_NUM" --repo "$REPO" \
    --body "✅ Closed by Brenner Axiom (bead: $BEAD_ID)

**Summary:** $REASON" 2>/dev/null || true
  gh issue close "$GH_NUM" --repo "$REPO" --reason completed 2>/dev/null || true
  echo "✅ GitHub issue #${GH_NUM} closed"
else
  echo "ℹ️  No linked GitHub issue found"
fi

# Sync and push
$BD sync 2>/dev/null || true
git add -A && git commit -m "Closed $BEAD_ID: $REASON" --no-verify -q 2>/dev/null || true
git push -q 2>/dev/null || true

echo "✅ Bead $BEAD_ID closed"
