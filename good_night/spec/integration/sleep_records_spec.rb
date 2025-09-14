require 'swagger_helper'

RSpec.describe 'Sleep Records API', type: :request do
  path '/api/clock_in' do
    post 'Clock in (start sleep)' do
      tags 'SleepRecords'
      consumes 'application/json'
      parameter name: :'X-User-Id', in: :header, type: :string, required: true

      response '201', 'clocked in' do
        let(:'X-User-Id') { User.create!(name: "Alice").id }
        run_test!
      end

      response '409', 'already clocked in' do
        let(:'X-User-Id') { User.create!(name: "Alice").tap { |u| u.sleep_records.create!(started_at: Time.now) }.id }
        run_test!
      end
    end
  end
end
