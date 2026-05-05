#!/usr/bin/env bash
# Auto-generated script for retrieve-design-knowledge
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="retrieve-design-knowledge"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────


# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/extract-requirements_${RUN_ID}.json"
OUTPUT_FILE="/tmp/retrieve-design-knowledge_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
TMP_BODY="/tmp/vector_body_${RUN_ID}.json"
TMP_RESP="/tmp/vector_resp_${RUN_ID}.json"
python3 - <<'PY' > "$TMP_BODY"
import json, os
from pathlib import Path
req=json.loads(Path(os.environ['INPUT_FILE']).read_text())
query=' '.join([req.get('product_idea','')] + [c.get('constraint_value','') for c in req.get('constraints',[])])[:2000]
print(json.dumps({'query':query,'top_k':5,'filters':{'kind':['pattern','benchmark','cloud_pricing','prior_session']}}))
PY
VECTOR_STATUS="skipped"
if [ -n "${VECTOR_DB_URL:-}" ] && [ -n "${VECTOR_DB_API_KEY:-}" ]; then
  HTTP_CODE=$(curl -sS -m 20 -o "$TMP_RESP" -w "%{http_code}" -H "Authorization: Bearer ${VECTOR_DB_API_KEY}" -H "Content-Type: application/json" -X POST "${VECTOR_DB_URL%/}/query" --data-binary "@$TMP_BODY" || true)
  if [ "$HTTP_CODE" != "200" ]; then echo "Vector DB query failed with HTTP $HTTP_CODE: $(head -c 1000 "$TMP_RESP" 2>/dev/null)" >&2; VECTOR_STATUS="error"; else VECTOR_STATUS="ok"; fi
fi
export VECTOR_STATUS
python3 - <<'PY'
import json, os, hashlib, time
from pathlib import Path
start=time.time(); req=json.loads(Path(os.environ['INPUT_FILE']).read_text()); out=Path(os.environ['OUTPUT_FILE'])
text=(req.get('product_idea','')+' '+' '.join(c.get('constraint_value','') for c in req.get('constraints',[]))).lower()
def ref(t,title,excerpt,score,uri='bundled://autosys/patterns'):
 return {'reference_id':'ref_'+hashlib.sha1((req['session_id']+title).encode()).hexdigest()[:20],'session_id':req['session_id'],'reference_type':t,'title':title,'source_uri':uri,'excerpt':excerpt,'score':score,'metadata':{'source':'bundled','deterministic':True}}
refs=[ref('pattern','Start simple: modular monolith plus managed data store','Prefer a modular monolith or small set of services until team size, scale, or independent deployability justify microservices.',0.82),ref('pattern','Managed relational database baseline','Use PostgreSQL/MySQL for transactional product data unless access patterns require specialized stores.',0.76),ref('pattern','Async workers for slow or bursty tasks','Introduce a queue and workers for email, media processing, webhooks, imports, and retryable integrations.',0.72),ref('benchmark','Reliability baseline','For early production, single-region managed services with backups, health checks, and observability are usually simpler than multi-region active-active.',0.68),ref('cloud_pricing','Rough cost-estimate guardrail','Report broad monthly ranges and drivers such as compute, database, storage, cache, queue, CDN, observability, and egress.',0.66)]
if 'real-time' in text or 'low latency' in text: refs.append(ref('pattern','Realtime delivery options','Use WebSockets/SSE for interactive updates; avoid global pub/sub unless latency and scale demand it.',0.8))
if 'feed' in text or 'social' in text: refs.append(ref('pattern','Feed fanout tradeoff','Start with fanout-on-read for smaller products; fanout-on-write/cache is justified for very large read-heavy feeds.',0.79))
if 'hipaa' in text or 'pci' in text or 'gdpr' in text: refs.append(ref('pattern','Compliance-sensitive architecture','Prefer managed services with audit logging, encryption, access controls, retention policy, and human architecture review.',0.78))
warnings=[]
if os.environ.get('VECTOR_STATUS') == 'ok':
 try:
  vr=json.loads(Path(f"/tmp/vector_resp_{os.environ['RUN_ID']}.json").read_text())
  for r in (vr.get('matches') or vr.get('results') or [])[:5]:
   title=r.get('title') or r.get('metadata',{}).get('title') or 'Vector reference'; refs.append({'reference_id':'ref_'+hashlib.sha1((req['session_id']+title).encode()).hexdigest()[:20],'session_id':req['session_id'],'reference_type':r.get('type') or r.get('metadata',{}).get('type','pattern'),'title':title[:200],'source_uri':r.get('source_uri') or r.get('id'),'excerpt':(r.get('excerpt') or r.get('text') or '')[:1200],'score':r.get('score'),'metadata':{'source':'vector_db'}})
 except Exception as e: warnings.append('Vector response could not be parsed; bundled references used.')
elif os.environ.get('VECTOR_STATUS') == 'error': warnings.append('Vector DB unavailable or returned non-200; bundled knowledge used.')
else: warnings.append('Vector DB credentials not configured; bundled knowledge used.')
out.write_text(json.dumps({'status':'ok' if not warnings else 'partial','session_id':req['session_id'],'references':refs[:10],'warnings':warnings,'elapsed_ms':int((time.time()-start)*1000)},indent=2))
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: retrieve-design-knowledge complete"
