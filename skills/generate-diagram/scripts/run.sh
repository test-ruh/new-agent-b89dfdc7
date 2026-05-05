#!/usr/bin/env bash
# Auto-generated script for generate-diagram
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="generate-diagram"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────


# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/generate-architecture_${RUN_ID}.json"
OUTPUT_FILE="/tmp/generate-diagram_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import json, os, re, hashlib, time
from pathlib import Path
start=time.time(); arch=json.loads(Path(os.environ['INPUT_FILE']).read_text()); comps=arch.get('components',[])
def node_id(name): return re.sub(r'[^A-Za-z0-9_]', '', name.title().replace(' ',''))[:32] or 'Node'
def label(name): return re.sub(r'[\[\]{}<>|]','',name)[:60]
ids={c.get('name','Component'):node_id(c.get('name','Component')) for c in comps}; lines=['flowchart TD']
for c in comps: lines.append(f"  {ids[c.get('name')]}[{label(c.get('name','Component'))}]")
names=[c.get('name') for c in comps]
def has(n): return n in names
edges=[('Web / Mobile Client','API Backend','HTTPS/API'),('API Backend','Managed Relational Database','read/write'),('API Backend','Object Storage','files'),('API Backend','Observability','logs/metrics')]
if has('Cache'): edges.append(('API Backend','Cache','hot reads'))
if has('Queue + Workers'):
 edges.append(('API Backend','Queue + Workers','enqueue jobs')); edges.append(('Queue + Workers','Managed Relational Database','job updates')); edges.append(('Queue + Workers','Observability','worker telemetry'))
if has('CDN / Edge Cache'): edges.insert(0,('Web / Mobile Client','CDN / Edge Cache','static/cacheable')); edges.insert(1,('CDN / Edge Cache','API Backend','dynamic requests'))
if has('Security & Compliance Controls'): edges.append(('Security & Compliance Controls','API Backend','policies/audit')); edges.append(('Security & Compliance Controls','Managed Relational Database','encryption/audit'))
for a,b,l in edges:
 if a in ids and b in ids: lines.append(f"  {ids[a]} -->|{label(l)}| {ids[b]}")
body='\n'.join(lines)+'\n'; warnings=[]
if not body.startswith('flowchart TD') or '-->' not in body: warnings.append('Diagram validation fell back to minimal flowchart.')
diag_id='diagram_'+hashlib.sha1((arch.get('recommendation_id','')+'mermaid').encode()).hexdigest()[:20]
out={'status':'ok' if not warnings else 'partial','diagram_id':diag_id,'session_id':arch.get('session_id'),'recommendation_id':arch.get('recommendation_id'),'diagram_type':'mermaid','title':arch.get('title','Architecture Diagram')[:140],'body':body,'diagram_text':body,'warnings':warnings,'elapsed_ms':int((time.time()-start)*1000)}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(out,indent=2))
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: generate-diagram complete"
