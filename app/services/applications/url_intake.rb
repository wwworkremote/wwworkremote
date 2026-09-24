# frozen_string_literal: true

# Idempotent front door for a job URL. It creates the lead/posting if needed,
# starts the user's tracked application, and leaves execution at the next
# evidence or human-decision boundary.
class Applications::UrlIntake
  def self.call(url:, user:, attributes: {})
    new(url: url, user: user, attributes: attributes).call
  end

  def initialize(url:, user:, attributes: {})
    @url = url.to_s.strip
    @user = user
    @attributes = attributes.to_h.symbolize_keys
  end

  def call
    return failure("A valid http(s) URL is required") unless @url.match?(%r{\Ahttps?://}i)

    lead = Lead.find_or_initialize_by(signature: Lead.incoming_signature(@url))
    lead.assign_attributes(url: @url, provider: JobFetchers::ProviderDetector.call(@url),
                           title: @attributes[:title], company_name: @attributes[:company_name],
                           location: @attributes[:location], raw_html: @attributes[:raw_html],
                           discovery: @attributes[:discovery] || {})
    lead.found_at ||= Time.current
    lead.save!

    promotion_attributes = @attributes.merge(target_url: @url)
    promotion_attributes[:company] ||= { name: @attributes[:company_name] } if @attributes[:company_name].present?
    promoted = Leads::CaptureService.call(lead: lead, params: promotion_attributes, user: @user)
    return promoted unless promoted[:success]

    posting = promoted[:job_posting]
    application = @user.user_job_postings.find_or_create_by!(job_posting: posting)
    application.record_status_event!("favorite") if application.status == "none"
    session = application.guided_sessions.where(purpose: "application_execution", status: %w[active paused])
                         .order(created_at: :desc).first ||
              GuidedSession.create!(source_url: posting.target_url, purpose: "application_execution",
                                    user_job_posting: application)
    { success: true, lead: lead, job_posting: posting, application: application, guided_session: session,
      cycle_plan: Applications::CyclePlan.call(application) }
  rescue ActiveRecord::RecordInvalid => e
    failure(e.message)
  end

  private

  def failure(error)
    { success: false, error: error }
  end
end
