require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/users/{id}/following_sleep_records' do
    get 'Get following users sleep records (last week, sorted by duration)' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :'X-User-Id', in: :header, type: :string, required: true
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :items, in: :query, type: :integer, required: false

      response '200', 'success' do
        let(:id) { User.create!(name: "Alice").id }
        let(:'X-User-Id') { id }
        run_test!
      end
    end
  end
end
