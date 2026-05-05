# Workflow — End-to-End Process Flow

## Workflow Steps

1. **data-writer** → data-writer
2. **extract-requirements** → extract-requirements
3. **clarify-if-needed** → native-tool: message (depends on extract-requirements)
4. **retrieve-design-knowledge** → retrieve-design-knowledge (depends on extract-requirements)
5. **analyze-repository** → analyze-repository (depends on extract-requirements)
6. **estimate-cloud-cost** → estimate-cloud-cost (depends on extract-requirements, retrieve-design-knowledge)
7. **generate-architecture** → generate-architecture (depends on extract-requirements, retrieve-design-knowledge, analyze-repository, estimate-cloud-cost)
8. **generate-diagram** → generate-diagram (depends on generate-architecture)
9. **persist-design-session** → persist-design-session (depends on generate-architecture, generate-diagram)
10. **deliver-response** → native-tool: message (depends on persist-design-session)
11. **post-github-suggestion** → post-github-suggestion (depends on analyze-repository, generate-architecture)
12. **attach-design-to-ticket** → attach-design-to-ticket (depends on generate-architecture, generate-diagram)

## Diagram

```
data-writer → extract-requirements → clarify-if-needed → retrieve-design-knowledge → analyze-repository → estimate-cloud-cost → generate-architecture → generate-diagram → persist-design-session → deliver-response → post-github-suggestion → attach-design-to-ticket
```
