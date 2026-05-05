---
name: estimate-cloud-cost
version: 1.0.0
description: "Produces rough monthly cloud-cost ranges, assumptions, cost drivers, and confidence."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, curl, jq]
      env: []
    primaryEnv: AWS_API_KEY
---
# Estimate Cloud Cost

## I/O Contract

- **Input:** `/tmp/retrieve-design-knowledge_${RUN_ID}.json`
- **Output:** `/tmp/estimate-cloud-cost_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
