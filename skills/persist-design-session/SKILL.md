---
name: persist-design-session
version: 1.0.0
description: "Upserts sessions, constraints, recommendations, diagrams, costs, references, and repo analyses."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, jq]
      env: [DATABASE_URL, ORG_ID, AGENT_ID]
    primaryEnv: DATABASE_URL
---
# Persist Design Session

## I/O Contract

- **Input:** `/tmp/generate-architecture_${RUN_ID}.json`
- **Output:** `/tmp/persist-design-session_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
