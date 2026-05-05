# Step 4 of 5 — Triggers

## Active Triggers

### design-system-request — User asks to design a system for a product idea or feature.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | conversational                     |
| **Status**  | enabled                   |

**Sample User Queries This Trigger Handles:**

- "Design a low-cost architecture for a B2B SaaS MVP."
- "Architect a social feed for 1M monthly users with 99.9% availability."

---

### requirement-change-request — User changes constraints such as scale, budget, latency, reliability, compliance, region, or cloud preference.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | conversational                     |
| **Status**  | enabled                   |

**Sample User Queries This Trigger Handles:**

- "Now redesign it for 1M users and 99.9% availability."
- "Reduce the monthly cloud spend by half."

---

### github-repository-analysis — Repository connected or pull request opened/updated for architecture review; requires GitHub token and explicit approval before comments.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | event                     |
| **Status**  | optional                   |

---

### requirements-document-import — Notion or docs content is connected or updated for requirements extraction.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | event                     |
| **Status**  | optional                   |

---

### weekly-optimization — Review active sessions or connected repos for cost, scaling, reliability, and simplification opportunities.

| Field       | Value                              |
|-------------|------------------------------------|
| **Type**    | scheduled                     |
| **Status**  | enabled                   |
| **Channel** | web |
| **Frequency**   | Every Monday at 08:00 UTC                       |
| **Cron**        | `0 8 * * 1`                        |

