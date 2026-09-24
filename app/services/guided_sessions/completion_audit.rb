# frozen_string_literal: true

# Reports whether supervised application sessions reached an explicit
# applied state. Completion alone is evidence capture, not submission.
class GuidedSessions::CompletionAudit
  def self.call
    sessions = GuidedSession.where(purpose: "application_execution")
                            .includes(:user_job_posting)
    linked = sessions.select(&:user_job_posting)
    completed = linked.select { |session| session.status == "completed" }
    applied = completed.select { |session| session.user_job_posting.status == "applied" }

    {
      execution_sessions: sessions.size,
      linked_sessions: linked.size,
      completed_sessions: completed.size,
      completed_applied_sessions: applied.size,
      incomplete: linked.reject { |session|
        session.status == "completed" && session.user_job_posting.status == "applied"
      }
                        .map { |session|
        { id: session.id, session_status: session.status,
          posting_status: session.user_job_posting.status }
      }
    }
  end
end
