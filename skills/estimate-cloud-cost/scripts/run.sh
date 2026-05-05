#!/usr/bin/env bash
# Auto-generated script for estimate-cloud-cost
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="estimate-cloud-cost"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────


# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/retrieve-design-knowledge_${RUN_ID}.json"
OUTPUT_FILE="/tmp/estimate-cloud-cost_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
REQ_FILE="/tmp/extract-requirements_${RUN_ID}.json"
REF_FILE="$INPUT_FILE"
AZURE_STATUS="skipped"
if [ -n "${AZURE_API_KEY:-}" ] || [ -n "${AZURE_TENANT_ID:-}" ]; then
  CODE=$(curl -sS -m 15 -o "/tmp/azure_price_${RUN_ID}.json" -w "%{http_code}" "https://prices.azure.com/api/retail/prices?\$top=1" || true)
  if [ "$CODE" != "200" ]; then echo "Azure price endpoint failed HTTP $CODE: $(head -c 1000 "/tmp/azure_price_${RUN_ID}.json")" >&2; AZURE_STATUS="error"; else AZURE_STATUS="ok"; fi
fi
export AZURE_STATUS
python3 - <<'PY'
import json, os, re, hashlib, time
from pathlib import Path
start=time.time(); req=json.loads(Path(f"/tmp/extract-requirements_{os.environ['RUN_ID']}.json").read_text())
text=(req.get('product_idea','')+' '+' '.join(c.get('constraint_value','') for c in req.get('constraints',[]))).lower(); provider='provider_agnostic'
for p in ['aws','gcp','azure']:
 if p in text: provider=p.upper()
if provider=='provider_agnostic' and os.environ.get('AWS_REGION'): provider='AWS'
scale='large' if re.search(r'1\s?m|million|high scale', text) else ('medium' if re.search(r'100\s?k|\d+[kK]', text) else 'small')
low,high={'small':(80,450),'medium':(450,3500),'large':(3500,25000)}[scale]
if 'low-cost' in text or 'budget' in text or 'cheap' in text: low=int(low*.6); high=int(high*.75)
if 'multi-region' in text or '99.99' in text: low*=2; high*=3
assumptions={'range_is_rough':True,'scale_tier':scale,'included':'app compute, managed database, object storage, basic cache/queue when justified, logs/monitoring','excluded':'staff time, enterprise support, paid third-party APIs, unusual egress spikes','region':os.environ.get('AWS_REGION') or 'unspecified'}
warnings=[]
if provider=='AWS' and not os.environ.get('AWS_API_KEY'): warnings.append('AWS credentials not configured; using provider-agnostic AWS-like rough ranges.')
if provider=='GCP' and not os.environ.get('GCP_API_KEY'): warnings.append('GCP credentials not configured; using provider-agnostic rough ranges.')
if provider=='AZURE' and os.environ.get('AZURE_STATUS')!='ok': warnings.append('Azure pricing endpoint unavailable or credentials absent; using rough ranges.')
eid='estimate_'+hashlib.sha1((req['session_id']+provider+scale).encode()).hexdigest()[:20]
out={'status':'partial' if warnings else 'ok','estimate_id':eid,'session_id':req['session_id'],'recommendation_id':None,'cloud_provider':provider,'monthly_low_usd':low,'monthly_high_usd':high,'assumptions':assumptions,'cost_drivers':['database size and IOPS','compute instance/container-hours','storage and backups','egress/CDN traffic','observability/log volume'],'confidence':'medium' if not warnings else 'low','warnings':warnings,'elapsed_ms':int((time.time()-start)*1000)}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(out,indent=2))
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: estimate-cloud-cost complete"
