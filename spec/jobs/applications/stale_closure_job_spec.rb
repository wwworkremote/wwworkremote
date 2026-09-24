# frozen_string_literal: true

RSpec.describe Applications::StaleClosureJob do
  it "runs stale closure and logs the resulting count" do
    allow(Applications::StaleClosure).to receive(:call).and_return(count: 2, cutoff: Time.current,
                                                                   application_ids: [1, 2], dry_run: false)
    expect(Rails.logger).to receive(:info).with(a_string_including("closed=2", "application_ids=1,2"))

    described_class.perform_now
  end
end
