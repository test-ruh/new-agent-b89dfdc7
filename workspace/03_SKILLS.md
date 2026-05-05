# Step 3 of 5 — Skills

## Added Skills

| #    | Skill ID                  | Skill Name               | Mode   | Risk Level | Description                |
|------|---------------------------|--------------------------|--------|------------|----------------------------|
| S1   | `data-writer` | Data Writer | Auto | Low | Provision, write, and query the agent database schema via scripts/data_writer.py. Use for all PostgreSQL operations and any result-table persistence. |
| S2   | `result-query` | Result Query | Auto | Low | Read stored records from the agent result tables for inspection and follow-up questions. |
| S3   | `github-action` | GitHub Action | Auto | Low | Git branch + PR workflow for syncing agent changes to GitHub. Creates feature branches, commits changes, and opens pull requests against main. NEVER pushes to main directly. MANDATORY for every agent. |
| S4   | `extract-requirements` | Extract Requirements | Auto | Low | Normalizes requests into goals, constraints, assumptions, and clarification questions. |
| S5   | `retrieve-design-knowledge` | Retrieve Design Knowledge | Auto | Low | Retrieves or falls back to curated architecture patterns, references, and prior-session snippets. |
| S6   | `analyze-repository` | Analyze Repository | Auto | Low | Inspects GitHub repository or PR metadata for stack, services, and architecture risks. |
| S7   | `estimate-cloud-cost` | Estimate Cloud Cost | Auto | Low | Produces rough monthly cloud-cost ranges, assumptions, cost drivers, and confidence. |
| S8   | `generate-architecture` | Generate Architecture | Auto | Low | Synthesizes pragmatic architecture recommendations, alternatives, risks, and tradeoffs. |
| S9   | `generate-diagram` | Generate Diagram | Auto | Low | Converts the recommended architecture into Mermaid flowchart text. |
| S10   | `persist-design-session` | Persist Design Session | Auto | Low | Upserts sessions, constraints, recommendations, diagrams, costs, references, and repo analyses. |
| S11   | `post-github-suggestion` | Post GitHub Suggestion | Auto | Low | Posts or drafts approved architecture feedback on GitHub pull requests. |
| S12   | `attach-design-to-ticket` | Attach Design To Ticket | Auto | Low | Attaches approved architecture summaries to Linear or Jira tickets. |

## Skill Dependencies (Execution Order)

```
data-writer
result-query
github-action
extract-requirements
retrieve-design-knowledge ← depends on extract-requirements
analyze-repository ← depends on extract-requirements
estimate-cloud-cost ← depends on extract-requirements, retrieve-design-knowledge
generate-architecture ← depends on extract-requirements, retrieve-design-knowledge, analyze-repository, estimate-cloud-cost
generate-diagram ← depends on generate-architecture
persist-design-session ← depends on generate-architecture, generate-diagram
post-github-suggestion ← depends on analyze-repository, generate-architecture
attach-design-to-ticket ← depends on generate-architecture, generate-diagram
```

## Execution Mode Summary

| Mode  | Count          |
|-------|----------------|
| HiTL  | 0              |
| Auto  | 12 |
