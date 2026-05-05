#!/usr/bin/env bash
# Auto-generated script for generate-architecture
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="generate-architecture"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────


# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/extract-requirements_${RUN_ID}.json"
OUTPUT_FILE="/tmp/generate-architecture_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import json, os, re, hashlib, time
from pathlib import Path
start=time.time(); rid=os.environ['RUN_ID']
def load(name, default):
 p=Path(f"/tmp/{name}_{rid}.json")
 try: return json.loads(p.read_text()) if p.exists() else default
 except Exception: return default
req=load('extract-requirements',{}); refs=load('retrieve-design-knowledge',{'references':[]}); repo=load('analyze-repository',{}); cost=load('estimate-cloud-cost',{})
text=(req.get('product_idea','')+' '+' '.join(c.get('constraint_value','') for c in req.get('constraints',[]))).lower(); large=bool(re.search(r'1\s?m|million|high scale',text)); realtime='real-time' in text or 'low latency' in text; compliance=any(x in text for x in ['hipaa','pci','gdpr','regulated'])
style='event_driven_modular_services' if large and realtime else ('modular_services_with_async_processing' if large else ('serverless_or_managed_modular_monolith' if ('serverless' in text or 'low-cost' in text or 'budget' in text) else 'modular_monolith'))
components=[{'name':'Web / Mobile Client','type':'client','purpose':'User entry point and API consumer.'},{'name':'API Backend','type':'service','purpose':'Domain modules, authorization, request validation, and synchronous business workflows.'},{'name':'Managed Relational Database','type':'database','purpose':'Transactional source of truth for core entities.'},{'name':'Object Storage','type':'storage','purpose':'Durable storage for uploads, exports, and large artifacts.'},{'name':'Observability','type':'platform','purpose':'Centralized logs, metrics, traces, alerts, and audit events.'}]
if large or realtime: components += [{'name':'Cache','type':'cache','purpose':'Reduce hot-read latency and protect the database.'},{'name':'Queue + Workers','type':'queue_workers','purpose':'Handle slow, bursty, and retryable work asynchronously.'}]
if large: components.append({'name':'CDN / Edge Cache','type':'cdn','purpose':'Serve static assets and cache public read-heavy content near users.'})
if compliance: components.append({'name':'Security & Compliance Controls','type':'security','purpose':'Encryption, audit logs, least-privilege access, retention, and review workflows.'})
flows=['Client sends requests to API Backend','API Backend reads/writes Managed Relational Database','API Backend stores large files in Object Storage','Observability receives logs/metrics/traces from all runtime components']
if any(c['type']=='cache' for c in components): flows.append('API Backend uses Cache for hot reads and rate-limit state')
if any(c['type']=='queue_workers' for c in components): flows.append('API Backend enqueues background jobs; Workers process retries and integrations')
summary='Recommend the simplest production-ready architecture that satisfies the stated constraints: '+style.replace('_',' ')+'. Start managed and observable, then add distributed components only where scale or latency requires them.'
tradeoffs={'pros':['Simple enough for a small team to operate','Managed services reduce undifferentiated operations','Clear path to add cache/queue/CDN as usage grows'],'cons':['Provider-specific managed services can create migration work','Single-region baseline may not meet strict availability targets','Rough cost range needs validation before procurement'],'alternatives_considered':[{'name':'Microservices first','decision':'not recommended by default','reason':'Higher operational complexity unless independent deployability or team boundaries justify it.'},{'name':'Serverless first','decision':'useful for low-cost or bursty workloads','reason':'Can reduce ops but may complicate latency, local testing, and vendor portability.'}]}
risks=['Cost and capacity are approximate until real traffic and storage profiles are measured.','Human architecture/security review is required for regulated or mission-critical launches.']
if repo.get('architecture_findings'): risks += [f.get('finding') for f in repo.get('architecture_findings',[])[:2]]
rec_id='rec_'+hashlib.sha1((req.get('session_id','')+style+str(os.environ.get('RUN_ID'))).encode()).hexdigest()[:20]
out={'status':'ok','session_id':req.get('session_id'),'recommendation_id':rec_id,'version':1,'title':'Pragmatic '+style.replace('_',' ').title()+' Architecture','architecture_style':style,'summary':summary,'components':components,'data_flows':flows,'alternatives':tradeoffs['alternatives_considered'],'tradeoffs':tradeoffs,'risks':risks,'scaling_plan':'Launch with managed database, API backend, object storage, observability, and backups. Add cache for hot reads, queue/workers for slow jobs, CDN for read-heavy/static traffic, read replicas or partitioning only after metrics justify them.','reliability_notes':'Use health checks, automated backups, restore drills, idempotent workers, retry budgets, alerts, and runbooks. Multi-region is reserved for explicit availability/RTO/RPO needs.','observability_notes':'Capture RED/USE metrics, structured logs, traces for critical paths, SLOs for latency/error rate, and alerts tied to user impact.','security_notes':'Apply least privilege, secret management, encryption in transit/at rest, audit logging, dependency scanning, and explicit data retention.','assumptions':req.get('assumptions',[]),'references':refs.get('references',[])[:8],'cost_estimate':cost,'repo_summary':repo,'before_after':{'changed_constraints':req.get('constraints',[]),'explanation':'For requirement-change triggers, compare this recommendation against the previous saved version in persistence or UI state.'},'warnings':(refs.get('warnings',[])+repo.get('warnings',[])+cost.get('warnings',[])),'elapsed_ms':int((time.time()-start)*1000)}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(out,indent=2))
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: generate-architecture complete"
