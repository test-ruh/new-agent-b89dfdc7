---
name: analyze-repository
version: 1.0.0
description: "Inspects GitHub repository or PR metadata for stack, services, and architecture risks."
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, curl, jq]
      env: []
    primaryEnv: GITHUB_TOKEN
---
# Analyze Repository

## I/O Contract

- **Input:** `/tmp/extract-requirements_${RUN_ID}.json`
- **Output:** `/tmp/analyze-repository_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
