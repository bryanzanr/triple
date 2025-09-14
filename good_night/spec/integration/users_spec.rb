require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  let!(:alice) { User.create!(name: "Alice") }
  let!(:bob)   { User.create!(name: "Bob") }
  let!(:charlie) { User.create!(name: "Charlie") }
  let(:X_User_Id) { alice.id } # simulate current user

  path '/api/users/following_sleep_records' do
    get 'Get following users sleep records (last week, sorted by duration)' do
      tags 'Users'
      produces 'application/json'
      parameter name: :'X-User-Id', in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :items, in: :query, type: :integer, required: false

      response '200', 'success' do
        let(:'X-User-Id') { User.create!(name: "Alice").id }
        run_test!
      end
    end
  end
  path '/api/users' do
    get 'List all users' do
      tags 'Users'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :items, in: :query, type: :integer, required: false

      response '200', 'users listed' do
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["records"]).to be_an(Array)
          expect(body["records"].first).to have_key("id")
          expect(body["records"].first).to have_key("name")
        end
      end
    end
  end

  path '/api/users/{id}' do
    get 'Show a user' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'user found' do
        let(:id) { bob.id }
        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body["id"]).to eq(bob.id)
          expect(body["name"]).to eq("Bob")
        end
      end

      response '404', 'user not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/api/users/{id}/follow' do
    post 'Follow a user' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: 'X-User-Id', in: :header, type: :string, required: true

      response '200', 'follow created' do
        let(:'X-User-Id') { alice.id }
        let(:id) { bob.id }
        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
    end
  end

  path '/api/users/{id}/unfollow' do
    delete 'Unfollow a user' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: 'X-User-Id', in: :header, type: :string, required: true

      before { alice.active_follows.create!(followed: bob) }

      response '200', 'unfollowed' do
        let(:'X-User-Id') { alice.id }
        let(:id) { bob.id }
        run_test!
      end
    end
  end
end
