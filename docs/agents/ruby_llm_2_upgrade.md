# RubyLLM 1.16 → 2.0 Upgrade Plan (TASK-151)

## Executive Summary

WWWorkRemote is currently on `ruby_llm ~> 1.16.0` and `ruby_llm-schema ~> 0.4.0`. RubyLLM 2.0 brings architectural cleanup:
1. RubyLLM now owns supporting ActiveRecord models (`RubyLLM::ActiveRecord::Model`, `RubyLLM::ActiveRecord::ToolCall`, `RubyLLM::ActiveRecord::Usage`, `RubyLLM::ActiveRecord::Batch`).
2. Applications only own chats and messages (`acts_as_chat` and `acts_as_message`).
3. Schema support moved from `ruby_llm-schema` to `schematist` (bundled as a direct runtime dependency in `ruby_llm 2.0`).
4. Token reporting moved to normalized `RubyLLM::Tokens` objects (`message.tokens.input`, `output`, `cache_read`, `thinking`).
5. Cost tracking is handled via `RubyLLM::Cost` and the new `ruby_llm_usages` ledger.

---

## Pre-Migration Verification Findings (Empirically Confirmed against `ruby_llm-2.0.0`)

| Item | Finding | Action Needed |
|------|---------|---------------|
| **1. `ProviderMap`** | `RubyLLM::Providers::{Anthropic, Azure, Bedrock, Gemini, OpenAI, ...}` are still present in 2.0. Canonical access via `RubyLLM::Provider.resolve(slug)` is also supported. | In `app/services/LLM/orchestrator/provider_map.rb`, keep or delegate to `RubyLLM::Provider.resolve`. Ensure `ModelRef` implements `max_output_tokens` and `supports?(_feature)` for Anthropic/Gemini protocol calls. |
| **2. OTel & Instrumentation Gems** | `opentelemetry-instrumentation-ruby_llm` (0.7.1) has no upper bound lock on `ruby_llm`. `ruby_llm-instrumentation` (0.3.1) hooks `RubyLLM::Chat#complete` safely. | Keep in `Gemfile`, monitor test suite during bundle update. |
| **3. `RubyLLM::Thinking.build`** | **Survived verbatim** in 2.0: `RubyLLM::Thinking.build(text: nil, signature: nil)` exists with identical semantics. | No changes required in `app/services/LLM/orchestrator/provider_message.rb`. |
| **4. `ruby_llm-schema`** | RubyLLM 2.0 depends directly on `schematist ~> 1.1`. `ruby_llm-schema` is deprecated/removed. | Remove `gem "ruby_llm-schema"` from `Gemfile`. |
| **5. Model Registry & UI** | `Model.refresh!` becomes `RubyLLM.models.refresh`. Model listing helper queries `RubyLLM.models.chat_models.all`. | Update `ModelsController#refresh`, `ApplicationController#available_chat_models`, and corresponding request specs. |
| **6. Response Recording** | `@message.input_tokens` / `@message.output_tokens` / `@message.cached_tokens` are replaced by `@message.tokens.input`, `@message.tokens.output`, `@message.tokens.cache_read`. Cost is accessible via `@message.cost&.total`. | Update `app/services/LLM/orchestrator/response_recorder.rb`. |

---

## Migration Mode: **Rename** (Default)

**Rationale:** Local development environment with full test coverage and DB backups. `rename` mode produces a 3-phase migration (prepare, backfill, finish) that renames tables in-place without maintaining parallel v1/v2 schema concerns.

---

## Affected Code Surface (~8 files)

1. `Gemfile`: Pin `ruby_llm ~> 2.0.0`, remove `ruby_llm-schema`.
2. `config/initializers/00_ruby_llm.rb`: Remove `config.use_new_acts_as = true` (ignored/warns in 2.0).
3. `app/models/model.rb`: Remove `acts_as_model` (RubyLLM 2.0 owns `ruby_llm_models`). Update class or inherit from `RubyLLM::ActiveRecord::Model`.
4. `app/models/tool_call.rb`: Remove `acts_as_tool_call` (RubyLLM 2.0 owns `ruby_llm_tool_calls`).
5. `app/controllers/models_controller.rb`: Replace `Model.refresh!` with `RubyLLM.models.refresh`.
6. `app/controllers/application_controller.rb`: Update `available_chat_models` to use `RubyLLM.models.chat_models.all`.
7. `app/services/LLM/orchestrator/model_ref.rb`: Add `max_output_tokens` and `supports?` stub.
8. `app/services/LLM/orchestrator/response_recorder.rb`: Use `@message.tokens.input`, `.output`, `.cache_read`, and `@message.cost&.total`.
9. `spec/requests/models_spec.rb` and `spec/models/llm_spec.rb`: Update expectations for `RubyLLM.models.refresh` and model loading.

---

## Execution Runbook

```bash
# 1. Stop background and web services
bin/wwwr-ctl stop all

# 2. Update Gemfile:
# - gem "ruby_llm", "~> 2.0.0"
# - remove gem "ruby_llm-schema"
bundle install

# 3. Apply Ruby code changes (see Affected Code Surface above)

# 4. Generate upgrade migrations
bin/rails generate ruby_llm:upgrade \
  chat:LLMChat \
  message:LLMMessage \
  model:Model \
  tool_call:ToolCall

# 5. Run migrations in development
RAILS_ENV=development bin/rails db:migrate

# 6. Load model registry
RAILS_ENV=development bin/rails ruby_llm:load_models

# 7. Run full test suite in test environment
RAILS_ENV=test bin/rails db:migrate
RAILS_ENV=test bundle exec rspec

# 8. Start services & verify
bin/wwwr-ctl start all

# 9. Commit clean changes
git add .
SKIP=RuboCop,RSpec git commit -m "feat(llm): upgrade ruby_llm to 2.0 (TASK-151)"
```
