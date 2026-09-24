---
name: system-cartography
description: Map, visualize, and audit the system's architectural topology, relational graph, database consistency, and bounded contexts using Rails ERD, AnnotateRb, and database_consistency.
metadata:
  version: 1.0.0
---

# System Cartography & Schema Topology

System Cartography is the discipline of mapping the empirical terrain of WWWorkRemote's data models, relationships, and persistence guarantees. It bridges the **Embodied Rider** (kinetic operational loops) and the **Forensic Observer** (empirical capture and evaluation).

---

## 1. Core Objectives

1. **Map Reality, Not Aspirations**:
   The database schema is the ultimate ground truth of the system's persistent memory. Cartography reflects actual foreign keys, constraints, and tables as they exist in PostgreSQL.

2. **Decompose Monoliths into Bounded Contexts**:
   With 90+ ActiveRecord models, monolithic diagrams obscure subsystem seams. Cartography maintains both the full panoramic view and isolated bounded-context maps:
   - **Discovery & Ingestion**: Opportunities, feeds, and board crawlers.
   - **Application Automation & Datalake**: Guided sessions, field observations, mappings, question archetypes, and occurrences.
   - **Candidate & Interview Pipeline**: User profiles, resumes, job applications, pipeline steps, and interview rounds.
   - **Forensic Evaluation & LLM Runtime**: Scenarios, reference holotypes, model orchestrations, and tool traces.

3. **Audit Database Consistency**:
   ActiveRecord validations in Ruby code do not guarantee relational integrity under concurrency. Cartography audits and enforces database-level backing constraints (foreign keys, `NOT NULL`, composite unique indexes).

---

## 2. Standard Cartography Workflow

### Step 1: Regenerate Schema Diagrams
Keep visual diagrams synchronized with the database schema:

```bash
# Generate all diagrams (full panoramic + 4 bounded-context SVGs)
RAILS_ENV=development bundle exec rake diagrams:all

# Or generate only specific slices:
RAILS_ENV=development bundle exec rake diagrams:domains
RAILS_ENV=development bundle exec rake diagrams:full
```

Generated diagram assets:
- `erd.svg`: Scalable vector panoramic view (all models).
- `erd.pdf`: High-resolution vector document.
- `erd.png`: High-density raster overview.
- `erd.mmd`: Mermaid diagram definition.
- `docs/architecture/diagrams/erd-discovery-ingestion.svg`
- `docs/architecture/diagrams/erd-application-automation.svg`
- `docs/architecture/diagrams/erd-candidate-pipeline.svg`
- `docs/architecture/diagrams/erd-forensic-evaluation.svg`

### Step 2: Keep Model Annotations Fresh (Markdown)
Ensure schema comments at the top of models, factories, and specs accurately reflect column types, defaults, and indexes in GitHub Markdown format:

```bash
RAILS_ENV=development bundle exec annotaterb models
```

Configured via `.annotaterb.yml` (`:format_markdown: true`, `:position: before`).

### Step 3: Run Database Consistency Diagnostics
Detect drift between ActiveRecord model validations and PostgreSQL database constraints:

```bash
RAILS_ENV=development bundle exec database_consistency
```

Look for:
- `ForeignKeyChecker fail`: `belongs_to` associations missing actual foreign key constraints in Postgres.
- `MissingUniqueIndexChecker fail`: `validates :uniqueness` lacking a database unique index (race hazard).
- `NullConstraintChecker fail`: `validates :presence` lacking `NOT NULL` in the DB schema.
- `ThreeStateBooleanChecker fail`: Nullable boolean columns that should be `NOT NULL default: false`.
- `MissingDependentDestroyChecker fail`: `has_many` associations lacking explicit `dependent:` cascades or DB foreign key `on_delete` behaviors.

### Step 4: Hub Model & Gravity Well Analysis
Audit coupling metrics across high-in-degree models:
- **`User`**: Root identity hub. Ensure user-scoped models cascade safely (`dependent: :destroy` or `:nullify`).
- **`JobPosting`**: Central entity of discovery. Audit relationships across `UserJobPosting`, `Lead`, and `QuestionOccurrence`.
- **`GuidedSession`**: Spine of application automation. Ensure session tokens anchor raw datalake assets without orphaned occurrences.

---

## 3. Output Checklist
When running cartography passes, verify:
- [ ] `rake diagrams:all` finishes cleanly with zero invalid association warnings.
- [ ] `.annotaterb.yml` remains set to `:format_markdown: true`.
- [ ] `docs/architecture/system-map.md` is updated with any newly introduced entities or bounded-context changes.
- [ ] Consistency findings are logged as actionable remediation tasks or fed into `SystemInsight`.
