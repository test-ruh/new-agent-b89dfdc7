#!/usr/bin/env bash
# Auto-generated script for persist-design-session
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="persist-design-session"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────
: "${DATABASE_URL:?ERROR: DATABASE_URL not set}"
: "${ORG_ID:?ERROR: ORG_ID not set}"
: "${AGENT_ID:?ERROR: AGENT_ID not set}"

# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/generate-architecture_${RUN_ID}.json"
OUTPUT_FILE="/tmp/persist-design-session_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import json, os
from pathlib import Path
rid=os.environ['RUN_ID']
def load(name, d):
 p=Path(f"/tmp/{name}_{rid}.json")
 try: return json.loads(p.read_text()) if p.exists() else d
 except Exception: return d
req=load('extract-requirements',{}); arch=load('generate-architecture',{}); diag=load('generate-diagram',{}); cost=load('estimate-cloud-cost',{}); refs=load('retrieve-design-knowledge',{}); repo=load('analyze-repository',{})
sid=req.get('session_id') or arch.get('session_id')
records={'sessions':[{'session_id':sid,'user_id':req.get('user_id'),'channel':req.get('channel','web'),'product_idea':req.get('product_idea',''),'current_status':'generated','assumptions':req.get('assumptions',[])}],'constraints':req.get('constraints',[]),'recommendations':[{'recommendation_id':arch.get('recommendation_id'),'session_id':sid,'title':arch.get('title'),'architecture_style':arch.get('architecture_style'),'summary':arch.get('summary'),'components':arch.get('components',[]),'tradeoffs':arch.get('tradeoffs',{}),'scaling_plan':arch.get('scaling_plan'),'reliability_notes':arch.get('reliability_notes'),'version':arch.get('version',1)}] if arch.get('recommendation_id') else [],'diagrams':[{'diagram_id':diag.get('diagram_id'),'recommendation_id':arch.get('recommendation_id'),'diagram_type':'mermaid','title':diag.get('title'),'body':diag.get('body')}] if diag.get('diagram_id') else [],'costs':[{'estimate_id':cost.get('estimate_id'),'recommendation_id':arch.get('recommendation_id'),'cloud_provider':cost.get('cloud_provider'),'monthly_low_usd':cost.get('monthly_low_usd'),'monthly_high_usd':cost.get('monthly_high_usd'),'assumptions':cost.get('assumptions',{}),'cost_drivers':cost.get('cost_drivers',[]),'confidence':cost.get('confidence','low')}] if cost.get('estimate_id') and arch.get('recommendation_id') else [],'references':[{**r,'recommendation_id':arch.get('recommendation_id')} for r in refs.get('references',[])],'repo':[{'repo_analysis_id':repo.get('repo_analysis_id'),'session_id':sid,'repository':repo.get('repository'),'pull_request_id':repo.get('pull_request_id'),'detected_stack':repo.get('detected_stack',{}),'architecture_findings':repo.get('architecture_findings',[]),'comment_posted':False}] if repo.get('repo_analysis_id') else []}
for k,v in records.items(): Path(f"/tmp/persist_{k}_{rid}.json").write_text(json.dumps([x for x in v if x], indent=2))
PY
write_table () {
  local table="$1" conflict="$2" file="$3"
  if [ -s "$file" ] && [ "$(jq 'length' "$file")" != "0" ]; then
    python3 "${PROJECT_ROOT}/scripts/data_writer.py" write --table "$table" --conflict "$conflict" --run-id "${RUN_ID}" --records "$(cat "$file")"
  fi
}
write_table result_design_sessions "session_id" "/tmp/persist_sessions_${RUN_ID}.json"
write_table result_constraints "constraint_id" "/tmp/persist_constraints_${RUN_ID}.json"
write_table result_architecture_recommendations "recommendation_id" "/tmp/persist_recommendations_${RUN_ID}.json"
write_table result_diagrams "diagram_id" "/tmp/persist_diagrams_${RUN_ID}.json"
write_table result_cost_estimates "estimate_id" "/tmp/persist_costs_${RUN_ID}.json"
write_table result_knowledge_references "reference_id" "/tmp/persist_references_${RUN_ID}.json"
write_table result_repo_analyses "repo_analysis_id" "/tmp/persist_repo_${RUN_ID}.json"
python3 - <<'PY'
import json, os
from pathlib import Path
rid=os.environ['RUN_ID']; counts={}
for k in ['sessions','constraints','recommendations','diagrams','costs','references','repo']:
 p=Path(f"/tmp/persist_{k}_{rid}.json"); counts[k]=len(json.loads(p.read_text())) if p.exists() else 0
arch=json.loads(Path(f"/tmp/generate-architecture_{rid}.json").read_text())
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps({'status':'ok','session_id':arch.get('session_id'),'recommendation_id':arch.get('recommendation_id'),'write_counts':counts,'saved':True,'warnings':[]},indent=2))
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: persist-design-session complete"
