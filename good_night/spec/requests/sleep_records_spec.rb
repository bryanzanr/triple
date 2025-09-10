require 'rails_helper'

RSpec.describe "SleepRecords API", type: :request do
  let!(:user) { User.create!(name: "Alice") }
  let(:headers) { { "X-User-Id" => user.id.to_s } }

  describe "POST /api/clock_in" do
    it "creates a new sleep record" do
      post "/api/clock_in", headers: headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["record"]["user_id"]).to eq(user.id)
    end

    it "rejects clock-in if already open" do
      user.sleep_records.create!(started_at: Time.current)
      post "/api/clock_in", headers: headers
      expect(response).to have_http_status(:conflict)
    end
  end

  describe "POST /api/clock_out" do
    it "closes an open record" do
      record = user.sleep_records.create!(started_at: Time.current)
      post "/api/clock_out", headers: headers
      expect(response).to have_http_status(:ok)
      expect(record.reload.ended_at).not_to be_nil
    end

    it "returns error when no open record" do
      post "/api/clock_out", headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
