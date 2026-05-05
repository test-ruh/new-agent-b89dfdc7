#!/usr/bin/env bash
# Auto-generated script for extract-requirements
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="extract-requirements"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────


# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/data-writer_${RUN_ID}.json"
OUTPUT_FILE="/tmp/extract-requirements_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY'
import json, os, re, hashlib, time
from pathlib import Path
start=time.time(); inp=Path(os.environ.get('INPUT_FILE','')); out=Path(os.environ['OUTPUT_FILE'])
try: data=json.loads(inp.read_text()) if inp.exists() and inp.read_text().strip() else {}
except Exception as e: data={"raw_input_error":str(e)}
p=data.get('payload', data)
msg=str(p.get('message') or p.get('prompt') or p.get('product_idea') or p.get('text') or '')
session_id=p.get('session_id') or 'sess_'+hashlib.sha1((msg+os.environ.get('RUN_ID','')).encode()).hexdigest()[:16]
constraints=[]
def add(t,v,src='user_input',pri='should'):
    constraints.append({'constraint_id':'constraint_'+hashlib.sha1((session_id+t+v+src).encode()).hexdigest()[:16],'session_id':session_id,'constraint_type':t,'constraint_value':v,'source':src,'priority':pri})
low=msg.lower()
patterns={'scale':[r'\b\d+[kKmM]?\s*(users|requests|rps|qps|monthly users|maus?)',r'high scale'], 'budget':[r'\$\s?\d+[kKmM]?(\s*/?\s*(mo|month))?',r'low[- ]cost|cheap|budget'], 'latency':[r'\b\d+\s?ms\b',r'low latency|real[- ]time'], 'reliability':[r'99\.\d+%|high availability|multi[- ]region'], 'compliance':[r'hipaa|pci|gdpr|soc2|regulated'], 'cloud_preference':[r'\baws\b|\bgcp\b|azure|cloudflare|vercel|railway'], 'team':[r'\b\d+\s*(engineers|devs|developers)\b|solo founder|small team']}
for typ,pats in patterns.items():
  for pat in pats:
    m=re.search(pat,low)
    if m: add(typ,m.group(0),'user_input','must' if typ in ['scale','budget','reliability','compliance'] else 'should'); break
for typ,key in [('cloud_preference','cloud'),('budget','budget'),('region','region'),('latency','latency'),('reliability','reliability')]:
    if p.get(key): add(typ,str(p[key]),'payload','must')
gaps=[] if msg else ['product idea or feature description']
for typ,label in [('scale','expected users/traffic'),('budget','monthly budget or cost sensitivity'),('reliability','availability/recovery target'),('cloud_preference','preferred cloud/hosting stack')]:
    if not any(c['constraint_type']==typ for c in constraints): gaps.append(label)
qmap={'product idea or feature description':'What product or feature should this architecture support?','expected users/traffic':'What launch and 12-month traffic should we design for?','monthly budget or cost sensitivity':'Is minimizing monthly cloud cost a must-have, and do you have a target range?','availability/recovery target':'What availability or recovery target is needed?','preferred cloud/hosting stack':'Do you prefer AWS, GCP, Azure, Vercel/Cloudflare, or provider-agnostic services?'}
questions=[qmap[g] for g in gaps[:5]]
assumptions=[]
if 'expected users/traffic' in gaps: assumptions.append('Assume early production scale with room to grow, not internet-scale at launch.')
if 'monthly budget or cost sensitivity' in gaps: assumptions.append('Assume cost-conscious managed services and avoid operationally heavy components.')
if 'availability/recovery target' in gaps: assumptions.append('Assume single-region managed services with backups unless higher availability is requested.')
if 'preferred cloud/hosting stack' in gaps: assumptions.append('Assume provider-agnostic service categories until a cloud is selected.')
requires=bool(questions and len(gaps)>=3 and not p.get('proceed_with_assumptions'))
out.write_text(json.dumps({'status':'needs_clarification' if requires else 'ok','session_id':session_id,'channel':p.get('channel') or data.get('channel') or 'web','user_id':p.get('user_id') or p.get('workspace_id'),'product_idea':msg or 'Weekly optimization review','trigger_type':p.get('trigger_type','design_system_request'),'goals':[msg[:240]] if msg else ['Review active sessions for optimization opportunities'],'constraints':constraints,'assumptions':assumptions,'gaps':gaps,'clarification_questions':questions,'requires_clarification':requires,'repository':p.get('repository') or p.get('repo'),'pull_request':p.get('pull_request') or p.get('pr_number'),'ticket':p.get('ticket') or p.get('issue_key'),'approval':p.get('approval',{}),'elapsed_ms':int((time.time()-start)*1000),'warnings':[]},indent=2))
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: extract-requirements complete"
