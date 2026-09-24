# frozen_string_literal: true

ERD_COMMON_ATTRS = "--attributes=content,foreign_keys,primary_keys,timestamps,inheritance --polymorphism --inheritance"

namespace :diagrams do
  desc "Generate full ERD diagrams (SVG, PDF, PNG, Mermaid)"
  task full: :environment do
    puts "\n📊 Generating full ERD diagrams..."
    %w[svg pdf png].each do |ext|
      system("RAILS_ENV=development bundle exec erd --generator=graphviz --filetype=#{ext} " \
             "--filename=erd #{ERD_COMMON_ATTRS}")
    end
    system("RAILS_ENV=development bundle exec erd --generator=mermaid --filename=erd #{ERD_COMMON_ATTRS}")
    mmd_path = Rails.root.join("erd.mmd")
    File.write(mmd_path, File.read(mmd_path).gsub("\t", "  ")) if File.exist?(mmd_path)
    puts "✅ Full ERD diagrams generated."
  end

  desc "Generate bounded-context ERD diagrams in docs/architecture/diagrams/"
  task domains: :environment do
    FileUtils.mkdir_p(Rails.root.join("docs/architecture/diagrams"))

    domains = {
      "erd-discovery-ingestion" => %w[
        JobPosting Source Domain BoardQuery JobSearch JobRun
        JobPostingTrend Lead Company TargetDomain DiscoveryLink
      ],
      "erd-application-automation" => %w[
        GuidedSession GuidedSessionEvent GuidedSessionReplay
        ApplicationFieldObservation ApplicationFieldMapping ApplicationFieldAnswer
        ApplicationQuestion ApplicationAnswerTemplate QuestionArchetype
        QuestionOccurrence AnswerProposalVerdict AnswerStrategy
        ArchetypeReadinessAssessment ExtractionRule ExtractionRuleObservation
      ],
      "erd-candidate-pipeline" => %w[
        User CareerProfile Resume ResumeSkill Skill WorkExperience
        JobExperience ExperienceHighlight UserJobPosting PipelineStep
        PipelinePrompt CompanyPipelineStep HumanTask InterviewSession
        InterviewQuestion InterviewTask Contact
      ],
      "erd-forensic-evaluation" => %w[
        Scenario ScenarioSignature ReferenceScenario ReferenceComparison
        ComparisonFinding FindingDisposition TenantIdentity Model
        LLMChat LLMMessage ToolCall SystemInsight SystemSetting
      ]
    }

    domains.each do |filename, models|
      puts "\n🗺️  Generating bounded-context ERD: #{filename} (#{models.size} models)..."
      cmd = [
        "RAILS_ENV=development bundle exec erd",
        "--generator=graphviz",
        "--filetype=svg",
        "--filename=docs/architecture/diagrams/#{filename}",
        "--only=#{models.join(',')}",
        ERD_COMMON_ATTRS
      ].join(" ")
      system(cmd)
    end
    puts "✅ Bounded-context ERD diagrams generated in docs/architecture/diagrams/."
  end

  desc "Generate all diagrams (full + domains)"
  task all: %i[full domains]
end
