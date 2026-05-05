---
name: post-github-suggestion
version: 1.0.0
description: Posts or drafts approved architecture feedback on GitHub pull requests.
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, curl, jq]
      env: [GITHUB_TOKEN]
    primaryEnv: GITHUB_TOKEN
---
# Post GitHub Suggestion

## I/O Contract

- **Input:** `/tmp/generate-architecture_${RUN_ID}.json`
- **Output:** `/tmp/post-github-suggestion_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
