---
name: generate-diagram
version: 1.0.0
description: Converts the recommended architecture into Mermaid flowchart text.
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [python3, jq]
      env: []
    primaryEnv: none
---
# Generate Diagram

## I/O Contract

- **Input:** `/tmp/generate-architecture_${RUN_ID}.json`
- **Output:** `/tmp/generate-diagram_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
