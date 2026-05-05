#!/usr/bin/env bash
# Auto-generated script for post-github-suggestion
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="post-github-suggestion"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${GITHUB_TOKEN:?ERROR: GITHUB_TOKEN not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/generate-architecture_${RUN_ID}.json"
OUTPUT_FILE="/tmp/post-github-suggestion_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
export POSTED COMMENT_URL WARNINGS
python3 - <<'PY'
import json, os
from pathlib import Path
rid=os.environ['RUN_ID']; req=json.loads(Path(f"/tmp/extract-requirements_{rid}.json").read_text()); arch=json.loads(Path(f"/tmp/generate-architecture_{rid}.json").read_text()); repo=json.loads(Path(f"/tmp/analyze-repository_{rid}.json").read_text())
findings='\n'.join([f"- **{f.get('severity','info')} / {f.get('category','architecture')}**: {f.get('finding')} Suggestion: {f.get('suggestion')}" for f in repo.get('architecture_findings',[])[:5]]) or '- No major repository-specific architecture risk was detected from available metadata.'
body=f"""## AutoSys Architect architecture review 🏗️\n\nRecommended direction: **{arch.get('title')}**\n\n{arch.get('summary')}\n\n### Repo-aware findings\n{findings}\n\n### Key tradeoffs\n""" + '\n'.join([f"- {x}" for x in arch.get('tradeoffs',{}).get('pros',[])[:2]+arch.get('tradeoffs',{}).get('cons',[])[:2]]) + "\n\n_This is high-level architecture feedback, not line-level code review. Costs/capacity are rough and should be validated before production commitments._\n"
Path(f"/tmp/github_comment_{rid}.json").write_text(json.dumps({'body':body})); Path(f"/tmp/github_meta_{rid}.json").write_text(json.dumps({'approved': bool(req.get('approval',{}).get('github_comment')),'repository':repo.get('repository'),'pull_request_id':repo.get('pull_request_id')}))
PY
APPROVED=$(jq -r '.approved' "/tmp/github_meta_${RUN_ID}.json"); REPO=$(jq -r '.repository // empty' "/tmp/github_meta_${RUN_ID}.json"); PR=$(jq -r '.pull_request_id // empty' "/tmp/github_meta_${RUN_ID}.json")
POSTED=false; COMMENT_URL=""; WARNINGS="[]"
if [ "$APPROVED" = "true" ] && [ -n "$REPO" ] && [ -n "$PR" ]; then
  CODE=$(curl -sS -m 20 -o "/tmp/github_post_${RUN_ID}.json" -w "%{http_code}" -H "Authorization: Bearer ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" -H "Content-Type: application/json" -X POST "https://api.github.com/repos/${REPO}/issues/${PR}/comments" --data-binary "@/tmp/github_comment_${RUN_ID}.json" || true)
  if [ "$CODE" != "201" ]; then echo "GitHub comment post failed HTTP $CODE: $(head -c 1000 "/tmp/github_post_${RUN_ID}.json")" >&2; WARNINGS='["GitHub comment post failed; draft returned instead."]'; else POSTED=true; COMMENT_URL=$(jq -r '.html_url // empty' "/tmp/github_post_${RUN_ID}.json"); fi
else WARNINGS='["Approval flag, repository, or pull request missing; no GitHub write performed."]'; fi
export POSTED COMMENT_URL WARNINGS
python3 - <<'PY'
import json, os
from pathlib import Path
rid=os.environ['RUN_ID']; meta=json.loads(Path(f"/tmp/github_meta_{rid}.json").read_text()); draft=json.loads(Path(f"/tmp/github_comment_{rid}.json").read_text())['body']
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps({'status':'ok' if os.environ.get('POSTED')=='true' else 'draft','posted':os.environ.get('POSTED')=='true','repository':meta.get('repository'),'pull_request_id':meta.get('pull_request_id'),'comment_url':os.environ.get('COMMENT_URL',''),'draft_body':draft,'warnings':json.loads(os.environ.get('WARNINGS','[]'))},indent=2))
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: post-github-suggestion complete"
