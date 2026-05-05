---
name: generate-architecture
version: 1.0.0
description: "Synthesizes pragmatic architecture recommendations, alternatives, risks, and tradeoffs."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [python3, jq]
      env: []
    primaryEnv: none
---
# Generate Architecture

## I/O Contract

- **Input:** `/tmp/extract-requirements_${RUN_ID}.json`
- **Output:** `/tmp/generate-architecture_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
