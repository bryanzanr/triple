require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let!(:alice) { User.create!(name: "Alice") }
  let!(:bob)   { User.create!(name: "Bob") }
  let(:headers) { { "X-User-Id" => alice.id.to_s } }

  describe "POST /api/users/:id/follow" do
    it "follows another user" do
      post "/api/users/#{bob.id}/follow", headers: headers
      expect(response).to have_http_status(:ok)
      expect(alice.following).to include(bob)
    end
  end

  describe "DELETE /api/users/:id/unfollow" do
    it "unfollows another user" do
      alice.following << bob
      delete "/api/users/#{bob.id}/unfollow", headers: headers
      expect(response).to have_http_status(:ok)
      expect(alice.following).not_to include(bob)
    end
  end

  describe "GET /api/users/:id/following_sleep_records" do
    it "returns previous week sleep records of following users" do
      alice.following << bob
      bob.sleep_records.create!(
        started_at: 1.week.ago.beginning_of_week(:monday) + 22.hours,
        ended_at:   1.week.ago.beginning_of_week(:monday) + 30.hours
      )

      get "/api/users/#{alice.id}/following_sleep_records", headers: headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["records"].first["user_id"]).to eq(bob.id)
    end
  end
end
