# frozen_string_literal: true

class ResumeProviders::CareerProfile
  def initialize(user: nil)
    @user = user || User.find_by(email: Wwwr::Identity.email)
  end

  def to_h
    profile = @user&.career_profile
    unless profile
      return { "schema_version" => Resume::DocumentContract::CURRENT_VERSION, "archetypes" => {},
               "positions" => {} }
    end

    positions = profile.work_experiences.order(start_date: :desc, id: :desc)
    {
      "schema_version" => Resume::DocumentContract::CURRENT_VERSION,
      "profile" => {
        "name" => profile.user.name, "email" => profile.user.email,
        "location" => profile.location_info, "contact" => profile.contact_info,
        "github_url" => profile.github_url, "goals" => profile.goals,
        "resume_text" => profile.resume_text
      }.compact,
      "skills" => { "text" => profile.skills.to_s, "experience_level" => profile.experience_level },
      "archetypes" => { "default" => archetype(profile, positions) },
      "positions" => positions.to_h { |experience| [position_id(experience), position(experience)] }
    }
  end

  private

  def archetype(profile, positions)
    {
      "short_label" => profile.experience_level.presence || "Candidate",
      "title" => positions.first&.title || "Candidate", "target_tier" => profile.experience_level,
      "summary" => profile.goals,
      "core_skills" => profile.skills.to_s.split(/[,\n]/).map(&:strip).compact_blank,
      "featured_positions" => positions.map { |experience| { "id" => position_id(experience) } },
      "additional_experience" => [], "selected_projects" => []
    }
  end

  def position(experience)
    {
      "id" => position_id(experience), "title" => experience.title,
      "company" => { "name" => experience.company_name, "location" => experience.location },
      "employment_type" => experience.employment_type,
      "start_date" => experience.start_date&.iso8601, "end_date" => experience.end_date&.iso8601,
      "summary" => experience.summary, "action" => experience.action, "impact" => experience.impact,
      "description" => experience.description, "skills" => experience.skills, "scope" => experience.scope
    }.compact
  end

  def position_id(experience)
    experience.external_id.presence || "work_experience_#{experience.id}"
  end
end
