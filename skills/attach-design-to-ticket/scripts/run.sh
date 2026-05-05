#!/usr/bin/env bash
# Auto-generated script for attach-design-to-ticket
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="attach-design-to-ticket"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────


# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/generate-architecture_${RUN_ID}.json"
OUTPUT_FILE="/tmp/attach-design-to-ticket_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
export ATTACHED PROVIDER COMMENT_URL WARNINGS
python3 - <<'PY'
import json, os
from pathlib import Path
rid=os.environ['RUN_ID']; req=json.loads(Path(f"/tmp/extract-requirements_{rid}.json").read_text()); arch=json.loads(Path(f"/tmp/generate-architecture_{rid}.json").read_text()); diag=json.loads(Path(f"/tmp/generate-diagram_{rid}.json").read_text())
body=f"""AutoSys Architect summary: {arch.get('title')}\n\n{arch.get('summary')}\n\nScaling plan: {arch.get('scaling_plan')}\n\nReliability: {arch.get('reliability_notes')}\n\nMermaid diagram:\n```mermaid\n{diag.get('body','')}\n```\n\nAssumptions: {', '.join(arch.get('assumptions',[]) or ['none stated'])}\nRough cost estimates are ranges and require validation before commitment."""
Path(f"/tmp/ticket_body_{rid}.txt").write_text(body); Path(f"/tmp/ticket_meta_{rid}.json").write_text(json.dumps({'approved':bool(req.get('approval',{}).get('ticket_attachment')),'ticket':req.get('ticket')}))
PY
APPROVED=$(jq -r '.approved' "/tmp/ticket_meta_${RUN_ID}.json"); TICKET=$(jq -r '.ticket // empty' "/tmp/ticket_meta_${RUN_ID}.json")
ATTACHED=false; PROVIDER="draft"; COMMENT_URL=""; WARNINGS="[]"
if [ "$APPROVED" = "true" ] && [ -n "$TICKET" ] && [ -n "${LINEAR_API_KEY:-}" ]; then
  PROVIDER="linear"; jq -Rs --arg id "$TICKET" '{query:"mutation CommentCreate($input: CommentCreateInput!) { commentCreate(input: $input) { success comment { id url } } }", variables:{input:{issueId:$id, body:.}}}' "/tmp/ticket_body_${RUN_ID}.txt" > "/tmp/linear_payload_${RUN_ID}.json"
  CODE=$(curl -sS -m 20 -o "/tmp/linear_resp_${RUN_ID}.json" -w "%{http_code}" -H "Authorization: ${LINEAR_API_KEY}" -H "Content-Type: application/json" -X POST "https://api.linear.app/graphql" --data-binary "@/tmp/linear_payload_${RUN_ID}.json" || true)
  if [ "$CODE" != "200" ]; then echo "Linear comment failed HTTP $CODE: $(head -c 1000 "/tmp/linear_resp_${RUN_ID}.json")" >&2; WARNINGS='["Linear comment failed; draft returned."]'; else ATTACHED=true; COMMENT_URL=$(jq -r '.data.commentCreate.comment.url // .data.commentCreate.comment.id // empty' "/tmp/linear_resp_${RUN_ID}.json"); fi
elif [ "$APPROVED" = "true" ] && [ -n "$TICKET" ] && [ -n "${JIRA_API_TOKEN:-}" ] && [ -n "${JIRA_BASE_URL:-}" ] && [ -n "${JIRA_EMAIL:-}" ]; then
  PROVIDER="jira"; jq -Rs '{body:.}' "/tmp/ticket_body_${RUN_ID}.txt" > "/tmp/jira_payload_${RUN_ID}.json"
  CODE=$(curl -sS -m 20 -o "/tmp/jira_resp_${RUN_ID}.json" -w "%{http_code}" -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" -H "Content-Type: application/json" -X POST "${JIRA_BASE_URL%/}/rest/api/2/issue/${TICKET}/comment" --data-binary "@/tmp/jira_payload_${RUN_ID}.json" || true)
  if [ "$CODE" != "201" ]; then echo "Jira comment failed HTTP $CODE: $(head -c 1000 "/tmp/jira_resp_${RUN_ID}.json")" >&2; WARNINGS='["Jira comment failed; draft returned."]'; else ATTACHED=true; COMMENT_URL=$(jq -r '.self // .id // empty' "/tmp/jira_resp_${RUN_ID}.json"); fi
else WARNINGS='["Approval, ticket ID, or ticket connector credentials missing; no ticket write performed."]'; fi
export ATTACHED PROVIDER COMMENT_URL WARNINGS
python3 - <<'PY'
import json, os
from pathlib import Path
rid=os.environ['RUN_ID']; meta=json.loads(Path(f"/tmp/ticket_meta_{rid}.json").read_text())
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps({'status':'ok' if os.environ.get('ATTACHED')=='true' else 'draft','attached':os.environ.get('ATTACHED')=='true','provider':os.environ.get('PROVIDER','draft'),'ticket':meta.get('ticket'),'comment_url':os.environ.get('COMMENT_URL',''),'draft_body':Path(f"/tmp/ticket_body_{rid}.txt").read_text(),'warnings':json.loads(os.environ.get('WARNINGS','[]'))},indent=2))
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: attach-design-to-ticket complete"
