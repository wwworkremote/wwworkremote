<!-- ═══════════════════════════════════════════════════════════════════════
     CURRENT FOCUS  —  last updated 2026-11-07 (session 15)
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
    (none)

  NEXT UP:
    TASK-141 (High) dev web service wedges silently (watchdog mitigates, root cause open).
    TASK-143  (Med) guided harness: no first-class Lever support.
    TASK-139  (Med) chrome.debugger dies before 2nd capture — needs retest.

  Live tasks (Backlog MCP):
    TASK-151  (Med, DONE) RubyLLM 1.16 to 2.0 upgrade.
    TASK-140  (Med, DONE) JobBoards::Syncer starves on unordered LIMIT.
    TASK-147.1 (Med, DONE) multi-round interview tracking.
    TASK-141  (High, In Progress) dev web service wedges silently.
    TASK-143  (Med) guided harness: no first-class Lever support.
    TASK-142  (Low) ClaudeAssets pre-commit hook broken on main.
              Workaround: SKIP=ClaudeAssets for any .claude/ commits.
    TASK-139  (Med) chrome.debugger dies before 2nd capture — needs retest.
    TASK-112  guided recorder HITL ACs #3/#4/#5 — wants a Greenhouse run.

  Operational state (verified 2026-11-07):
    web: running via launchd (bin/wwwr-ctl status, port 31000).
    jobs: stopped cleanly to maintain lightweight dev environment.
    backlog: running via launchd (com.wwworkremote.backlog, port 31055, proxy 31050).
    database: wwworkremote_development up to date with RubyLLM 2.0 tables.
    git: clean after commit. Run bin/tmi-scan before pushing.

  Done 2026-11-07 session 15 (Antigravity):
    - Reaped orphaned Solid Queue processes and maintained lightweight web-only dev operation.
    - Scoped `bin/wwwr-ctl` orphan detection to `$APP_ROOT` to protect other machine processes.
    - Fixed polymorphic `#company` handling in `bin/fetch-jobs`.
    - Configured persistent Backlog.md service and Nginx TLS proxy on port 31050.
  Done 2026-09-26 session 14 (Antigravity):
    - Completed TASK-147.1: multi-round interview tracking (ACs #6, #7, #8).
    - Finalized, committed, and pushed TASK-140 (resolve JobBoards::Syncer starvation).
    - Resolved pre-push Brakeman ignore for PipelineStep link_to_href.
  Done 2026-09-24 session 13 (Antigravity):
    - Executed TASK-151: Upgraded RubyLLM from 1.16 to 2.0.0.
    - Updated Gemfile (ruby_llm ~> 2.0.0, removed ruby_llm-schema), bundle install.
    - Generated & ran 3 upgrade migrations (prepare, backfill, finish).
    - Loaded 1676 models via ruby_llm:load_models into development DB.
    - Adapted Model & ToolCall classes to RubyLLM 2.0 ActiveRecord hierarchy.
    - Updated ModelRef and ProviderMessage (attachments, cache_until_here?).
    - Updated ResponseRecorder for 2.0 Tokens object & cost ledger.
    - Updated ModelsController to RubyLLM.models.refresh.
    - Full test suite verified green (1286/1286 passing).
    - Restarted both web & jobs services cleanly.
    - Fixed TASK-140 JobBoards::Syncer starvation, drained dev DB backlog (0 pending, 1 failed).
  Done 2026-09-24 session 12: Restored Slices 3-6, TASK-145, full suite green (4cca8790).
  Done 2026-09-21 session 11: TASK-145 Gemini/Anthropic provider fixes.
  Done session 10 (2026-09-16): DB backup, RuboCop cleanup, 4 migrations restored.
  Done sessions 1-9: see handoff files in ~/.config/adots/handoffs/.

  DO NOT touch other repos from a wwworkremote/wwworkremote session. See memory
  feedback_stay_in_this_repo.

  Deep handoff: ~/.config/adots/handoffs/2026-09-24-wwworkremote-session13.md
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
