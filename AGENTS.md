<!-- ═══════════════════════════════════════════════════════════════════════
     CURRENT FOCUS  —  last updated 2026-09-24 (session 12)
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
    Restoration roadmap from pre-release backup (backup/core @ 26ba96fb):
      ALL SLICES DONE (0-6). Restoration complete as of session 12.

  NEXT UP — TASK-151: RubyLLM 1.16 to 2.0 upgrade (ready to execute)
    Full plan: docs/agents/ruby_llm_2_upgrade.md  <- READ THIS FIRST
    Quick resume:
      1. bin/wwwr-ctl stop all
      2. Gemfile: ruby_llm ~> 2.0.0, remove ruby_llm-schema line
      3. bundle install
      4. Apply Ruby code changes (see plan doc)
      5. bin/rails generate ruby_llm:upgrade            chat:LLMChat message:LLMMessage model:Model tool_call:ToolCall
      6. RAILS_ENV=development bin/rails db:migrate
      7. RAILS_ENV=development bin/rails ruby_llm:load_models
      8. RAILS_ENV=test bundle exec rspec
      9. bin/wwwr-ctl start all
     10. Commit (SKIP=RuboCop,RSpec) + cleanup migration later

  Live tasks (Backlog MCP):
    TASK-151  (Med, Ready) RubyLLM 1.16 to 2.0 upgrade — see above.
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

  Operational state (verified 2026-09-24):
    web: bin/wwwr-web, Puma cluster, watchdog self-heals in ~2 min.
    jobs: bin/wwwr-jobs (SolidQueue + cron + aggregators), running.
    database: wwworkremote_development backed up (20260916_124139.dump, 279 MB).
    test suite: full suite 100% green (1286/1286 passing).
    git: clean at 4cca8790. Run bin/tmi-scan before pushing.

  Done 2026-09-24 session 12 (Antigravity):
    - Restored Slices 3-6 (App intake, resume intelligence, data quality, tooling).
    - Fixed Applications::CyclePlan ProviderStrategy namespace resolution.
    - Restored InterviewSession scheduled_at validation & callbacks for multi-round tracking.
    - Restored User#interview_tasks association.
    - Added missing routes: cancel for guided sessions, update for interview sessions.
    - Resolved test isolation in batch_match_job_spec and yaml_importer_spec.
    - Full test suite green (1286/1286 passing). Committed: 4cca8790.
    - Healed system: both web + jobs launchd services running.
    - Planned TASK-151 (RubyLLM 2.0 upgrade): docs/agents/ruby_llm_2_upgrade.md.
  Done 2026-09-21 session 11: TASK-145 Gemini/Anthropic provider fixes.
  Done session 10 (2026-09-16): DB backup, RuboCop cleanup, 4 migrations restored.
  Done sessions 1-9: see handoff files in ~/.config/adots/handoffs/.

  DO NOT touch other repos from a wwworkremote/wwworkremote session. See memory
  feedback_stay_in_this_repo.

  Deep handoff: ~/.config/adots/handoffs/2026-09-24-wwworkremote-session12.md
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
