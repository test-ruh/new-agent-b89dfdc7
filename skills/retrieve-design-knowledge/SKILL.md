---
name: retrieve-design-knowledge
version: 1.0.0
description: "Retrieves or falls back to curated architecture patterns, references, and prior-session snippets."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, curl, jq]
      env: []
    primaryEnv: VECTOR_DB_API_KEY
---
# Retrieve Design Knowledge

## I/O Contract

- **Input:** `/tmp/extract-requirements_${RUN_ID}.json`
- **Output:** `/tmp/retrieve-design-knowledge_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
