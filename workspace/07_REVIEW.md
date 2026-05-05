# Review — Final Summary Before Deployment

## Agent Card

| Field              | Value                          |
|--------------------|--------------------------------|
| **Name**           | 🏗️ AutoSys Architect |
| **ID**             | `autosys-architect`           |
| **Version**        | 1.0.0 |
| **Scope**          | Pragmatic AI system design and optimization agent for architecture recommendations, tradeoffs, diagrams, rough cost ranges, and repo-aware suggestions.      |
| **Tone**           | Clear, pragmatic senior-architect style; curious before prescribing, explicit about assumptions, transparent about tradeoffs, skeptical of over-engineering, and encouraging for learners.             |
| **Model**          | claude-sonnet-4 (primary), claude-haiku-3 (fallback) |
| **Token Budget**   | 3000000 tokens/month |

## Skills Summary

| Skill                     | Mode         |
|---------------------------|--------------|
| Data Writer | 🟢 Auto |
| Result Query | 🟢 Auto |
| GitHub Action | 🟢 Auto |
| Extract Requirements | 🟢 Auto |
| Retrieve Design Knowledge | 🟢 Auto |
| Analyze Repository | 🟢 Auto |
| Estimate Cloud Cost | 🟢 Auto |
| Generate Architecture | 🟢 Auto |
| Generate Diagram | 🟢 Auto |
| Persist Design Session | 🟢 Auto |
| Post GitHub Suggestion | 🟢 Auto |
| Attach Design To Ticket | 🟢 Auto |

## Post-Deployment Checklist

- [ ] Set PG_CONNECTION_STRING or DATABASE_URL plus ORG_ID and AGENT_ID; confirm result schema provisioning succeeds.
- [ ] Run check-environment.sh and install-dependencies.sh.
- [ ] Run test-workflow.sh with a sample product idea and proceed_with_assumptions enabled.
- [ ] Verify README.md lists all env vars and all nine custom skills.
- [ ] Confirm Mermaid output renders for MVP and high-scale prompts.
- [ ] Test missing optional credentials for graceful fallback notices.
- [ ] Verify GitHub PR and Linear/Jira writes remain draft-only unless approval flags are true.
- [ ] Review SOUL and guardrails for no low-level code generation, no fake precision, and no unsolicited writes.
- [ ] Validate result-schema.yml as YAML and provision tables.
- [ ] Run a weekly-optimization cron dry run.
