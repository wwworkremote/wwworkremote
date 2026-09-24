# frozen_string_literal: true

RSpec.describe Applications::UrlIntake do
  it "creates an idempotent tracked intake and guided session" do
    user = create(:user)
    url = "https://careers.toasttab.com/jobs?gh_jid=8186228"

    attributes = { title: "Role", company_name: "Toast", body: "A complete job description" }
    first = described_class.call(url: url, user: user, attributes: attributes)
    second = described_class.call(url: url, user: user, attributes: attributes)

    expect(first).to include(success: true)
    expect(first[:cycle_plan][:provider_strategy]).to include(label: "Greenhouse")
    expect(first[:cycle_plan][:next_step]).to eq("prepare")
    expect(second[:job_posting].id).to eq(first[:job_posting].id)
    expect(second[:application].id).to eq(first[:application].id)
    expect(second[:guided_session].id).to eq(first[:guided_session].id)
  end

  it "fails before creating records for a non-http URL" do
    result = described_class.call(url: "not-a-url", user: create(:user))

    expect(result).to include(success: false, error: "A valid http(s) URL is required")
  end
end
