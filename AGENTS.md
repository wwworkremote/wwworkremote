<!-- ═══════════════════════════════════════════════════════════════════════
     CURRENT FOCUS  —  last updated 2026-09-16 (session 10)
     Cold-start resume state, canonical for every agent tool (Claude, Codex,
     Gemini, Antigravity). Whoever closes a session rewrites this whole block
     in place — step one, before the wrap-up. `git log` + Backlog are truth
     for exact SHAs / task status; if this block contradicts them, trust them
     and fix the block. Full procedure: docs/agents/session-handoff.md
     ═══════════════════════════════════════════════════════════════════════

  ★ THE REPO IS NOW PUBLIC — https://github.com/wwworkremote/wwworkremote
     TASK-150 (public release) is DONE. Every commit to main is a public
     write. Public-repo discipline applies (see below).

  PUBLIC-REPO DISCIPLINE (standing, permanent):
    - No real names, handles, companies, comp figures, or referrer IDs in
      commit messages, task descriptions, or coordination docs.
    - Use generic language: "the adtech role", "a mid-size company", etc.
    - Run `bin/tmi-scan` before any commit touching AGENTS.md, CLAUDE.md,
      backlog/, or docs/agents/.
    - This CURRENT FOCUS block is public — keep it scrubbed on every close.

  In flight:
    Restoration roadmap from pre-release backup (/Users/mike/github.com/wwworkremote/backup/core @ 26ba96fb):
      - Slice 0: Application Capability Probes (complete, RuboCop clean, specs green).
      - Slice 1: Database Migration Alignment & Schema Harmonization (4 missing migrations restored, test DB migrated, full 1486-spec suite green).
      - Slice 2: Extension Friction & Error Telemetry (admin triage controller, views, routes).
      - Slice 3: Application Intake, Provider Strategy & Stale Closure.
      - Slice 4: Resume Intelligence & Provider Seam (model, provider registry, adapters).
      - Slice 5: Data Quality & Admin Surfaces.
      - Slice 6: Developer Tooling & Cartography (Rubydex / Ledgers).

  Live tasks (Backlog MCP):
    TASK-145  (High) LLM::Orchestrator fails on Gemini provider
              ("Role 'system' is not supported") — every AI-path answer
              silently failing since 2026-08-24. Fix: map :system role to
              first user turn for Gemini. Also unblocks interview-prep model.
    TASK-141  (High, In Progress) dev web service wedges silently.
              Mitigated: cluster mode + WebHealthWatchdogJob. Root cause open.
    TASK-140  (Med) JobBoards::Syncer starves on unordered LIMIT.
              ~6,831 nil-state rows stuck since 2026-07-30. 5-step plan in task.
    TASK-147.1 (Med, In Progress) multi-round interview tracking — see PR #23.
    TASK-143  (Med) guided harness: no first-class Lever support.
    TASK-142  (Low) ClaudeAssets pre-commit hook broken on main.
              Workaround: SKIP=ClaudeAssets for any .claude/ commits.
    TASK-139  (Med) chrome.debugger dies before 2nd capture — needs retest.
    TASK-112  guided recorder HITL ACs #3/#4/#5 — wants a Greenhouse run.

  Operational state (verified 2026-09-16):
    web: bin/wwwr-web, Puma cluster, watchdog self-heals in ~2 min.
    jobs: bin/wwwr-jobs (SolidQueue + cron + aggregators), running.
    database: wwworkremote_development backed up (20260916_124139.dump, 279 MB).
    test suite: bin/rspec-precommit verified green (1486 examples, 0 failures).

  Done 2026-09-16 session 10 (Antigravity):
    - Full DB safety backup taken to data/backups/wwworkremote_development_20260916_124139.dump.
    - Cleaned RuboCop metrics on ApplicationCapabilityProbes stack and JobPosting.
    - Restored 4 missing migrations from pre-release backup and aligned test database schema.
    - Established durable multi-slice restoration roadmap in adots handoffs.
  Done sessions 1-9: see handoff files in ~/.config/adots/handoffs/.

  DO NOT touch other repos from a wwworkremote/core session. See memory
  feedback_stay_in_this_repo.

  Deep handoff: ~/.config/adots/handoffs/2026-09-16-wwworkremote-session10.md
  (local-only, never commit).
-->



# WWWorkRemote: Agent Configuration

This file defines the capabilities, workflows, and skills configured for AI agents interacting with the WWWorkRemote repository.

## 🛠️ Engineering Skills

- **improve-codebase-architecture**: Surface architectural friction and propose deepening opportunities (seams, adapters).
- **triage**: Manage issues through a state machine (needs-triage, ready-for-agent, etc.).
- **tdd**: Test-driven development loop (red-green-refactor).
- **diagnose**: Disciplined bug diagnosis workflow.
- **to-issues**: Vertical slices from plans to independent tasks.
- **metaphor-harmony**: Audit and harmonize system metaphors, domain language (`CONTEXT.md`), and conceptual models (`.claude/skills/metaphor-harmony/SKILL.md`).
- **domain-cartographer-agent**: Dedicated agent (`.claude/agents/domain-cartographer-agent.md`) for maintaining conceptual harmony between the Embodied Rider and Forensic Observer, preventing domain drift, and ensuring sharp dogfooding ergonomics.

## ⚙️ Repository Configuration

### Resuming / closing a session
- Cold-start state = the **CURRENT FOCUS** block at the top of this file.
- Full procedure (resume + close): `docs/agents/session-handoff.md`.
- Closing = rewrite that block + commit, **before** the wrap-up summary; then write
  the deep handoff at `~/.config/adots/handoffs/` (local-only, never `git add`).

### Issue Tracker
- **Canonical**: Backlog.md via MCP (see the CRITICAL_INSTRUCTION block in `CLAUDE.md` /
  `GEMINI.md`). GitHub Issues + `gh` is the secondary/agent-facing tracker.
- **Workflow**: `to-issues` skill turns architecture plans into tasks.

### Triage Labels
- `needs-triage`
- `needs-info`
- `ready-for-agent`
- `ready-for-human`
- `wontfix`

### Domain Docs
- **Layout**: Single-context (root-based).
- **Canonical Docs**: `docs/index.md` serves as the primary map.
- **Engineering Mandates**: `CONTRIBUTING.md` (Database safety, standard wrappers, etc.).
