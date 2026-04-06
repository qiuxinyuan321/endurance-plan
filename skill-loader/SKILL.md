---
name: skill-loader
description: On-demand skill loader. When user request doesn't match active skills, find the best match below, Read its SKILL.md, and follow instructions.
---

# Skill Loader

When the user's request doesn't match any active Tier 1 skill, consult this index.
1. Find the best-matching skill by name or trigger keywords
2. If it's a **Shim → Tier 1**, invoke the active target directly via Skill tool
3. If it's a **Shim → Tier 2**, Read the target's SKILL.md and follow its instructions
4. For all other matches, `Read` the skill's SKILL.md at `~/.claude/skills/{name}/SKILL.md` and follow its instructions

## Shim Aliases → Tier 1 (direct invoke)

| Alias | Target (active) |
|-------|-----------------|
| brainstorming | unified-coding-agent |
| coding-agent | unified-coding-agent |
| code-review-expert | unified-coding-agent |
| requesting-code-review | unified-coding-agent |
| browser-automation | playwright |
| browser-automation-lite | playwright |
| agent-brain | unified-memory-system |
| chromadb-memory | unified-memory-system |
| memory-lancedb-pro-adapter | unified-memory-system |
| obsidian-external-brain | unified-memory-system |
| ultimate-memory-fusion | unified-memory-system |
| unified-memory-query | unified-memory-system |
| unified-memory-system-dup | unified-memory-system |
| feishu-file-sender | unified-lark |
| feishu-send-message | unified-lark |
| lark-calendar | unified-lark |
| lark-integration | unified-lark |
| verify-before-done | verification-before-completion |
| super-serach | super-search |

## Shim Aliases → Tier 2 (Read target SKILL.md)

| Alias | Target (on-demand) | Path |
|-------|--------------------|------|
| consciousness-architecture-core | unified-identity-cognition | skills/unified-identity-cognition/SKILL.md |
| video-learner | unified-video-intelligence | skills/unified-video-intelligence/SKILL.md |
| video-learner-pro | unified-video-intelligence | skills/unified-video-intelligence/SKILL.md |
| query-optimizer | sql-query-optimizer | skills/sql-query-optimizer/SKILL.md |
| turix | turix-windows | skills/turix-windows/SKILL.md |
| gsd | using-superpowers | skills/using-superpowers/SKILL.md |
| kaihui | pijiang-council | skills/pijiang-council/SKILL.md |
| yihui | pijiang-council | skills/pijiang-council/SKILL.md |
| metaso-search | fusion-tavily-search-metaso-search | skills/fusion-tavily-search-metaso-search/SKILL.md |

## On-Demand Skills Index

| Skill | Trigger Keywords |
|-------|-----------------|
| accessibility-check | UI accessibility, WCAG, a11y |
| agent-browser | headless browser CLI, Rust browser |
| agent-orchestrator | multi-agent decompose, orchestrate subtasks |
| agent-router | route task to agent mode, agent-team |
| anydocs | index docs site, search documentation |
| api-architecture-comprehensive | API design, REST architecture |
| assumption-test | validate assumptions, risk scoring |
| batch-cad-converter | batch CAD conversion |
| bilibili-learner | Bilibili video notes, B站学习 |
| blender-pipeline | Blender 3D pipeline |
| blogwatcher | RSS feed monitor, blog updates |
| caching-strategy | cache design, Redis strategy |
| caldav-calendar | CalDAV sync, iCloud/Google calendar |
| calendar | calendar operations |
| chaos-testing | resilience test, failure injection |
| chart-generator | generate charts, data visualization |
| clawdbot-filesystem | advanced filesystem ops, batch files |
| clawhub | skill marketplace, install skills |
| clawpedia | knowledge base wiki |
| code-review-workflow | code review process |
| complexity-analysis | algorithm complexity, Big-O |
| conflict-resolution | team disagreements, decision conflicts |
| context-transfer | session handoff, context preserve |
| continuity-protocol | continuity, session persistence |
| contract-testing | API contracts, service compatibility |
| create-dxf | create DXF files |
| database-design | DB schema, data modeling |
| debugging-meta-cognition | debug cognitive traps, bias avoidance |
| disk-cleaner | disk space, large files cleanup |
| docker-dev | Docker, containers, compose |
| dwg-to-excel | AutoCAD DWG to Excel |
| dxf-to-image | DXF rendering to image |
| error-design | error handling, error messages UX |
| error-recovery | multi-agent error recovery, failover |
| evolution-design | system evolution, future-proof design |
| excalidraw-diagram | Excalidraw diagrams, visual architecture |
| explain-to | adjust explanation to audience level |
| external-wrapper-modernization | CLI wrapper audit, upgrade wrappers |
| failure-mode | failure analysis, resilience design |
| family-quality-audit | skill family audit, entrypoint consolidation |
| feishu-card | 飞书卡片, Feishu interactive cards |
| feishu-doc-manager | publish Markdown to Feishu Docs |
| find-skills | discover new skills, skill search |
| finishing-a-development-branch | branch completion, merge/PR decision |
| fusion-assumption-test-feishu-doc-manager | Feishu doc + assumption gating |
| fusion-executing-plans-subagent-driven-development-2 | plan execution + spec/code review gates |
| fusion-tavily-search-metaso-search | bilingual web research, EN+CN search |
| git-assistant | git operations helper |
| git-worktree-orchestrator | worktree management |
| github | GitHub operations |
| github-mcp-setup | GitHub MCP server setup |
| governed-agent-orchestrator | governed multi-agent, audit lanes |
| healthcheck | security hardening, OpenClaw health |
| image-analyzer | image analysis |
| imap-smtp-email-plus | email IMAP/SMTP, mailbox |
| jupyter-notebook | Jupyter .ipynb creation |
| knowledge-gap | learning plan, unfamiliar concepts |
| llm-integration | prompt engineering, RAG, LLM apps |
| local-file-enhanced | enhanced file operations |
| markdown-converter | convert PDF/DOCX/PPTX/XLSX to Markdown |
| mcp-adapter | MCP protocol adapter |
| mcporter | MCP server CLI management |
| meeting-prep | meeting preparation, sprint planning |
| multi-agent-parallel-build | parallel multi-agent build waves |
| multi-agent-sync | cross-agent progress sync |
| nano-pdf | targeted PDF edits |
| network-tools | HTTP/DNS/port/SSL diagnostics |
| observability-design | monitoring, logging, alerting design |
| office-document-specialist-suite | Office docs creation/editing |
| ontology | knowledge graph, entity relations |
| openclaw-agent-optimize | OpenClaw optimization |
| openclaw-self-healing | OpenClaw auto-recovery |
| openclaw-unbound | OpenClaw security config toggle |
| opencortex | long-term memory distillation |
| openrouter-transcribe | audio transcription via OpenRouter |
| pan-direct-downloader | 百度网盘/夸克下载, Baidu/Quark links |
| parallel-task-executor | 并行任务执行, parallel task runner |
| pattern-matching | problem pattern recognition |
| pdf-parser | PDF parsing/extraction |
| performance-profile | performance profiling, latency analysis |
| permission-auto-approve | auto-approve permissions |
| pijiang-council | 皮匠议会, council discussion |
| playwright-interactive | persistent browser REPL |
| postgresql-client | PostgreSQL queries |
| prompt-cache-proxy-repair | prompt cache optimization |
| prompt-engineering-expert | prompt engineering |
| rlm-core | RLM core operations |
| security-audit | code security review, OWASP |
| security-best-practices | security patterns |
| security-threat-model | threat modeling |
| self-healing | diagnose-fix-verify loop |
| self-healing-runtime | runtime self-healing |
| session-logs | search session history |
| shadcn-ui | shadcn/ui components, React UI |
| short-video-learner | short video analysis, Douyin/TikTok |
| skill-distillation | mine & score external skills |
| skill-upgrade-foundry | skill upgrade pipeline |
| skill-upstream-governance | skill upstream review |
| smart-web-fetch | clean web fetch via Jina/defuddle |
| snippet-manager | templates, reusable text blocks |
| spreadsheet | Excel/CSV creation & analysis |
| sql-query-generator | SQL generation & execution |
| sql-query-optimizer | SQL optimization, indexes |
| subagent-driven-development-2 | subagent per task + review gates |
| system-boundary | API/service boundary design |
| system-slim-down | system consolidation, reduce skills |
| task-foundry | goal to phased execution plan |
| tasknotes | Obsidian tasks, TaskNotes API |
| tavily-search | direct Tavily search provider |
| test-driven-development | TDD, test-first development |
| testing-comprehensive | test strategy, coverage, test data |
| tmux-integration | tmux session management |
| trade-off-analysis | architecture tradeoffs |
| turix-windows | TuriX Windows desktop automation |
| unified-identity-cognition | identity-aware cognition |
| unified-monitor-layer | monitoring layer |
| unified-scrape | web scraping, DOM extraction |
| unified-skill-manager | skill routing & management |
| unified-video-intelligence | video analysis, Bilibili/YouTube |
| unified-workflow-engine | multi-variant workflow execution |
| using-git-worktrees | git worktree isolation |
| using-superpowers | skill orchestration, lane routing |
| ux-review | UI/UX review |
| video-frames | extract video frames via ffmpeg |
| video-learning-evolution | video insights to rules/skills |
| visual-aesthetic-design | visual design, diagrams, formatting |
| visual-regression-testing | UI screenshot regression testing |
| weather | weather forecast, wttr.in |
| workflow-automation | git hooks, CI/CD automation |
| writing-skills | create/rewrite skills |
