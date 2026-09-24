---
id: TASK-151
title: Upgrade RubyLLM from 1.16 to 2.0
status: Done
assignee: []
created_date: '2026-09-24 09:30'
updated_date: '2026-09-24 10:30'
labels:
  - llm
  - upgrade
dependencies: []
references:
  - docs/agents/ruby_llm_2_upgrade.md
  - Gemfile
  - config/initializers/00_ruby_llm.rb
  - app/services/LLM/orchestrator/response_recorder.rb
  - app/services/LLM/orchestrator/model_ref.rb
priority: medium
type: chore
ordinal: 162000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upgrade `ruby_llm` from 1.16.0 to 2.0.0. RubyLLM 2.0 introduces official model ownership (`RubyLLM::ActiveRecord::Model`, `RubyLLM::ActiveRecord::ToolCall`, `RubyLLM::ActiveRecord::Usage`), migrates schema generation from `ruby_llm-schema` to `schematist`, and transitions token tracking to normalized `RubyLLM::Tokens` objects.

Full plan and verification details: `docs/agents/ruby_llm_2_upgrade.md`.

Empirical verification against `ruby_llm-2.0.0.gem`:
- `RubyLLM::Providers::*` still present; `RubyLLM::Provider.resolve` canonical.
- `RubyLLM::Thinking.build(text: nil, signature: nil)` identical.
- `opentelemetry-instrumentation-ruby_llm` and `ruby_llm-instrumentation` compatible.
- `ruby_llm-schema` safely removed (replaced by `schematist ~> 1.1` in core gem).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 `ruby_llm` pinned to `~> 2.0.0` in Gemfile, `ruby_llm-schema` removed, bundle installed.
- [x] #2 Code adaptations applied:
  - `config/initializers/00_ruby_llm.rb`: remove `config.use_new_acts_as`
  - `app/services/LLM/orchestrator/model_ref.rb`: add `max_output_tokens` and `supports?`
  - `app/services/LLM/orchestrator/response_recorder.rb`: use `tokens.input`, `tokens.output`, `tokens.cache_read`, `cost&.total`
  - `app/controllers/models_controller.rb`: use `RubyLLM.models.refresh`
  - `app/controllers/application_controller.rb`: use `RubyLLM.models.chat_models.all`
- [x] #3 `bin/rails generate ruby_llm:upgrade chat:LLMChat message:LLMMessage model:Model tool_call:ToolCall` executed and migrations run (`prepare`, `backfill`, `finish`).
- [x] #4 `RAILS_ENV=development bin/rails ruby_llm:load_models` succeeds.
- [x] #5 `RAILS_ENV=test bundle exec rspec` passes 100% green (1286/1286 passing).
<!-- AC:END -->
