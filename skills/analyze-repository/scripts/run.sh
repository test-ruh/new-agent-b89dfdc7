#!/usr/bin/env bash
# Auto-generated script for analyze-repository
# DO NOT MODIFY — this script is executed verbatim by the OpenClaw agent
set -euo pipefail

SKILL_ID="analyze-repository"
export SKILL_ID
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "$0")/../../.." && pwd)}"
export PROJECT_ROOT

# ── Environment validation ────────────────────────────────────────────────────


# ── File paths ────────────────────────────────────────────────────────────────
INPUT_FILE="/tmp/extract-requirements_${RUN_ID}.json"
OUTPUT_FILE="/tmp/analyze-repository_${RUN_ID}.json"
export INPUT_FILE OUTPUT_FILE

# ── Input validation ──────────────────────────────────────────────────────────
[ -s "${INPUT_FILE}" ] || { echo "ERROR: input missing: ${INPUT_FILE}" >&2; exit 1; }

# ── Main logic ────────────────────────────────────────────────────────────────
python3 - <<'PY' > "/tmp/repo_meta_${RUN_ID}.json"
import json, os, re
from pathlib import Path
req=json.loads(Path(os.environ['INPUT_FILE']).read_text()); repo=req.get('repository')
if repo and repo.startswith('http'):
    m=re.search(r'github\.com[:/](.+?/[^/#?]+)', repo); repo=m.group(1).replace('.git','') if m else repo
print(json.dumps({'repository':repo,'pull_request':req.get('pull_request')}))
PY
REPO=$(jq -r '.repository // empty' "/tmp/repo_meta_${RUN_ID}.json")
PR=$(jq -r '.pull_request // empty' "/tmp/repo_meta_${RUN_ID}.json")
mkdir -p "/tmp/gh_${RUN_ID}"
GH_STATUS="skipped"
if [ -n "$REPO" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
  CODE=$(curl -sS -m 20 -o "/tmp/gh_${RUN_ID}/repo.json" -w "%{http_code}" -H "Authorization: Bearer ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/${REPO}" || true)
  if [ "$CODE" != "200" ]; then echo "GitHub repo fetch failed HTTP $CODE: $(head -c 1000 "/tmp/gh_${RUN_ID}/repo.json")" >&2; GH_STATUS="error"; else GH_STATUS="ok"; fi
  if [ "$GH_STATUS" = "ok" ]; then
    CODE=$(curl -sS -m 20 -o "/tmp/gh_${RUN_ID}/tree.json" -w "%{http_code}" -H "Authorization: Bearer ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/${REPO}/git/trees/HEAD?recursive=1" || true)
    [ "$CODE" = "200" ] || echo "GitHub tree fetch failed HTTP $CODE: $(head -c 1000 "/tmp/gh_${RUN_ID}/tree.json")" >&2
    if [ -n "$PR" ]; then
      CODE=$(curl -sS -m 20 -o "/tmp/gh_${RUN_ID}/pr.json" -w "%{http_code}" -H "Authorization: Bearer ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/${REPO}/pulls/${PR}" || true)
      [ "$CODE" = "200" ] || echo "GitHub PR fetch failed HTTP $CODE: $(head -c 1000 "/tmp/gh_${RUN_ID}/pr.json")" >&2
    fi
  fi
fi
export GH_STATUS
python3 - <<'PY'
import json, os, hashlib, time
from pathlib import Path
start=time.time(); req=json.loads(Path(os.environ['INPUT_FILE']).read_text()); meta=json.loads(Path(f"/tmp/repo_meta_{os.environ['RUN_ID']}.json").read_text()); repo=meta.get('repository')
warnings=[]; files=[]; findings=[]
if not repo: warnings.append('No repository provided; repo analysis skipped.')
elif not os.environ.get('GITHUB_TOKEN'): warnings.append('GITHUB_TOKEN missing; repo-aware analysis skipped.')
elif os.environ.get('GH_STATUS')!='ok': warnings.append('GitHub API unavailable or permission denied; fallback architecture can still be generated.')
else:
 d=Path(f"/tmp/gh_{os.environ['RUN_ID']}")
 try: files=[x.get('path','') for x in json.loads((d/'tree.json').read_text()).get('tree',[]) if x.get('type')=='blob'][:500]
 except Exception: pass
stack={'languages':[], 'frameworks':[], 'datastores':[], 'queues':[], 'deployment':[]}
for f in files:
 lf=f.lower()
 if lf.endswith('.py'): stack['languages'].append('Python')
 if lf.endswith(('.js','.ts','.tsx')): stack['languages'].append('JavaScript/TypeScript')
 if 'package.json' in lf: stack['frameworks'].append('Node.js ecosystem')
 if 'requirements.txt' in lf or 'pyproject.toml' in lf: stack['frameworks'].append('Python ecosystem')
 if 'dockerfile' in lf or 'docker-compose' in lf: stack['deployment'].append('Docker')
 if 'terraform' in lf: stack['deployment'].append('Terraform')
 if 'postgres' in lf or 'prisma' in lf: stack['datastores'].append('PostgreSQL')
 if 'redis' in lf: stack['datastores'].append('Redis')
 if 'kafka' in lf: stack['queues'].append('Kafka')
for k in stack: stack[k]=sorted(set(stack[k]))
if repo:
 if not stack['deployment']: findings.append({'severity':'medium','category':'deployment','finding':'No obvious deployment/runtime config detected from selected repository metadata.','suggestion':'Confirm hosting topology, environment separation, and rollback approach before recommending production architecture.'})
 if not stack['datastores']: findings.append({'severity':'low','category':'data','finding':'No datastore was confidently detected from file names.','suggestion':'Validate persistence needs with the user; default to managed relational storage for transactional apps.'})
 if 'Kafka' in stack['queues']: findings.append({'severity':'medium','category':'complexity','finding':'Kafka-related files detected.','suggestion':'Check whether throughput/ordering requirements justify Kafka versus a simpler managed queue.'})
if not findings: findings.append({'severity':'info','category':'scope','finding':'Repository analysis found no major architecture risk from limited metadata.','suggestion':'Use written requirements as primary design input.'})
rid='repo_'+hashlib.sha1(((repo or 'none')+str(meta.get('pull_request'))+req['session_id']).encode()).hexdigest()[:20]
out={'status':'partial' if warnings else 'ok','repo_analysis_id':rid,'session_id':req['session_id'],'repository':repo or 'not_provided','pull_request_id':str(meta.get('pull_request') or ''),'detected_stack':stack,'architecture_findings':findings,'facts':[{'path':f} for f in files[:50]],'comment_posted':False,'warnings':warnings,'elapsed_ms':int((time.time()-start)*1000)}
Path(os.environ['OUTPUT_FILE']).write_text(json.dumps(out,indent=2))
PY

# ── Output validation ─────────────────────────────────────────────────────────
[ -s "${OUTPUT_FILE}" ] || { echo "ERROR: output empty: ${OUTPUT_FILE}" >&2; exit 1; }

echo "OK: analyze-repository complete"
