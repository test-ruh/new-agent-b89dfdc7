# 🏗️ AutoSys Architect

Pragmatic AI system design and optimization agent for architecture recommendations, tradeoffs, diagrams, rough cost ranges, and repo-aware suggestions.

## Quick Start

```bash
git clone git@github.com:${GITHUB_OWNER}/autosys-architect.git
cd autosys-architect

# 1. Configure
cp .env.example .env
# Edit .env with your credentials (see "Required Environment Variables" below)

# 2. One-shot setup: validates env, installs deps, provisions DB, registers cron
chmod +x setup.sh
./setup.sh
```

## Manual Setup (if you prefer step-by-step)

```bash
cp .env.example .env             # then edit it
set -a; source .env; set +a       # load vars into the current shell
bash check-environment.sh         # verify everything required is set
bash install-dependencies.sh      # pip install psycopg2-binary, pyyaml
python3 scripts/data_writer.py provision   # create tables in your schema
openclaw cron add --file cron/weekly-optimization.json
```

## Running

```bash
bash test-workflow.sh             # run every skill in order locally (smoke test)
openclaw cron run --name weekly-optimization    # trigger manually
openclaw cron list                # see registered jobs
openclaw cron runs                # see run history
```

## Required Environment Variables

| Variable | Description |
|----------|-------------|
| `PG_CONNECTION_STRING` | PostgreSQL connection string for OpenClaw result storage |
| `DATABASE_URL` | Application database URL for design-session persistence |
| `ORG_ID` | OpenClaw organization identifier |
| `AGENT_ID` | OpenClaw agent identifier |

## Skills

| Skill | Mode | Description |
|-------|------|-------------|
| `data-writer` | Auto | Provision, write, and query the agent database schema via scripts/data_writer.py. Use for all PostgreSQL operations and any result-table persistence. |
| `result-query` | User-invocable | Read stored records from the agent result tables for inspection and follow-up questions. |
| `github-action` | User-invocable | Git branch + PR workflow for syncing agent changes to GitHub. Creates feature branches, commits changes, and opens pull requests against main. NEVER pushes to main directly. MANDATORY for every agent. |
| `extract-requirements` | User-invocable | Normalizes requests into goals, constraints, assumptions, and clarification questions. |
| `retrieve-design-knowledge` | Auto | Retrieves or falls back to curated architecture patterns, references, and prior-session snippets. |
| `analyze-repository` | Auto | Inspects GitHub repository or PR metadata for stack, services, and architecture risks. |
| `estimate-cloud-cost` | Auto | Produces rough monthly cloud-cost ranges, assumptions, cost drivers, and confidence. |
| `generate-architecture` | Auto | Synthesizes pragmatic architecture recommendations, alternatives, risks, and tradeoffs. |
| `generate-diagram` | Auto | Converts the recommended architecture into Mermaid flowchart text. |
| `persist-design-session` | Auto | Upserts sessions, constraints, recommendations, diagrams, costs, references, and repo analyses. |
| `post-github-suggestion` | Auto | Posts or drafts approved architecture feedback on GitHub pull requests. |
| `attach-design-to-ticket` | Auto | Attaches approved architecture summaries to Linear or Jira tickets. |

## Scheduled Jobs

| Job Name | Schedule | Notes |
|----------|----------|-------|
| `weekly-optimization` | `0 8 * * 1` | Timezone: UTC |


## Architecture

- **Runtime**: OpenClaw AI agent framework
- **Data Layer**: PostgreSQL via `scripts/data_writer.py`
- **Scheduling**: OpenClaw cron
- **Schema**: `org_{org_id}_a_autosys_architect`

## Directory Structure

```
autosys-architect/
├── README.md
├── openclaw.json
├── result-schema.yml
├── env-manifest.yml
├── .env.example
├── requirements.txt
├── .gitignore
├── check-environment.sh
├── install-dependencies.sh
├── test-workflow.sh
├── cron/
├── workflows/
├── scripts/
│   ├── data_writer.py
│   └── github_action.py
├── skills/
└── workspace/
    ├── SOUL.md
    ├── 01_IDENTITY.md
    ├── 02_RULES.md
    ├── 03_SKILLS.md
    ├── 04_TRIGGERS.md
    ├── 05_ACCESS.md
    ├── 06_WORKFLOW.md
    └── 07_REVIEW.md
```
