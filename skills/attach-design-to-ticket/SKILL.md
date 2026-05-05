---
name: attach-design-to-ticket
version: 1.0.0
description: Attaches approved architecture summaries to Linear or Jira tickets.
user-invocable: false
metadata:
  openclaw:
    requires:
      bins: [bash, python3, curl, jq]
      env: []
    primaryEnv: LINEAR_API_KEY
---
# Attach Design To Ticket

## I/O Contract

- **Input:** `/tmp/generate-architecture_${RUN_ID}.json`
- **Output:** `/tmp/attach-design-to-ticket_${RUN_ID}.json`

## Execute

```bash
bash {baseDir}/scripts/run.sh
```
