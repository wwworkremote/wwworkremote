# frozen_string_literal: true

class Api::V0::ExtensionErrorEventsController < ApiController
  def create
    event = ExtensionErrorEvent.create(event_attrs)
    return render(json: { success: true, id: event.id }) if event.persisted?

    render json: { success: false, errors: event.errors.full_messages }, status: :unprocessable_content
  end

  private

  def event_attrs
    attrs = base_attrs
    session = GuidedSession.find_by(session_token: params[:guided_session_token])
    attrs.merge(session_attrs(session)).merge(signature: event_signature(attrs))
  end

  def base_attrs
    event_params.merge(occurred_at: Time.current, guided_session_token: params[:guided_session_token])
  end

  def session_attrs(session)
    ujp = session&.user_job_posting
    { guided_session: session, user_job_posting: ujp, job_posting: ujp&.job_posting }
  end

  def event_signature(attrs)
    Digest::SHA256.hexdigest([attrs[:event_name], attrs[:provider], attrs[:phase], attrs[:error_message]].join("|"))
  end

  def event_params
    params.expect(extension_error_event: %i[build_version event_name phase provider page_host error_name error_message
                                            recoverable context])
  end
end
