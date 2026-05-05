---
name: extract-requirements
version: 1.0.0
description: "Normalizes requests into goals, constraints, assumptions, and clarification questions."
user-invocable: true
metadata:
  openclaw:
    requires:
      bins: [python3, jq]
      env: []
    primaryEnv: none
---
# Extract Requirements

## I/O Contract

- **Input:** `/tmp/data-writer_${RUN_ID}.json`
- **Output:** `/tmp/extract-requirements_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
