# Step 5 of 5 — Access

## User Access

### Authorized Teams

| Team               | Access Level | Members (approx) |
|--------------------|-------------|-------------------|
| Product Engineering | invoke and review architecture outputs | Backend engineers, frontend engineers, tech leads, and product managers |
| Architecture Reviewers | approve external writes and high-risk recommendations | Senior architects, staff engineers, platform leads, and security reviewers |
| Demo Operators | configure optional connectors and run staged demos | Authorized OpenClaw demo owners |

### Restricted From

| Team / Role          | Reason                          |
|----------------------|---------------------------------|
| Unapproved external automation | The agent must not post PR comments, ticket attachments, docs updates, or Slack announcements without explicit approval. |
| Production operations owner | The agent does not deploy infrastructure, operate systems, handle incidents, or change cloud resources. |
| Compliance final approver | The agent cannot replace formal legal, security, or compliance review. |

## HiTL Approvers

| Skill                | Action                         | Approver             | Fallback Approver    |
|----------------------|--------------------------------|----------------------|----------------------|
| post-github-suggestion | Post architecture feedback as a GitHub PR comment | Architecture Reviewers or pull-request owner via explicit payload approval | Return a draft comment and do not write to GitHub. |
| attach-design-to-ticket | Attach architecture summary and diagram to Linear or Jira ticket | Ticket owner, tech lead, or Architecture Reviewers via explicit payload approval | Return a draft attachment body and do not write to Linear/Jira. |

## Model Configuration

| Field                | Value                          |
|----------------------|--------------------------------|
| **Primary Model**    | claude-sonnet-4   |
| **Fallback Model**   | claude-haiku-3  |

## Token Budget

| Field                  | Value                  |
|------------------------|------------------------|
| **Monthly Budget**     | 3000000 tokens |
| **Alert Threshold**    | 2400000 tokens |
| **Auto-Pause on Limit**| Yes |

## Security & Permissions

| Permission                         | Allowed    |
|------------------------------------|------------|
| Read user-submitted prompts and constraints | ✅ |
| Generate architecture recommendations, tradeoffs, diagrams, and cost ranges | ✅ |
| Write result tables through schema-isolated data_writer.py | ✅ |
| Read GitHub repository metadata, file tree, selected config/dependency files, and PR metadata when token is configured | ✅ |
| Post GitHub PR comments without explicit approval | ❌ |
| Attach Linear/Jira ticket comments without explicit approval | ❌ |
| Read optional vector database references when configured | ✅ |
| Expose, log, or persist secret values | ❌ |
| Execute destructive SQL or schema changes from skills | ❌ |
| Generate production-ready low-level code or infrastructure automation | ❌ |
