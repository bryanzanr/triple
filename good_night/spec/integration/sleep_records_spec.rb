require 'swagger_helper'

RSpec.describe 'Sleep Records API', type: :request do
  let(:user) { User.create!(name: "Alice") }
  let!(:record) do
    SleepRecord.create!(
      user: user,
      started_at: 2.hours.ago,
      ended_at: 1.hour.ago
    )
  end

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
  path '/api/sleep_records' do
    get 'List current user sleep records' do
      tags 'SleepRecords'
      produces 'application/json'
      parameter name: 'X-User-Id', in: :header, type: :string, required: true
      parameter name: 'page', in: :query, type: :integer, required: false
      parameter name: 'items', in: :query, type: :integer, required: false

      response '200', 'records listed' do
        let(:'X-User-Id') { User.create!(name: "Alice").id }
        run_test!
      end
    end

    post 'Create a sleep record' do
      tags 'SleepRecords'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'X-User-Id', in: :header, type: :string, required: true
      parameter name: :sleep_record, in: :body, schema: {
        type: :object,
        properties: {
          started_at: { type: :string, format: :date_time },
          ended_at: { type: :string, format: :date_time }
        },
        required: ['started_at']
      }

      response '201', 'record created' do
        let(:'X-User-Id') { User.create!(name: "Alice").id }
        let(:sleep_record) { { started_at: Time.current.iso8601 } }
        run_test!
      end

      response '422', 'invalid record' do
        let(:'X-User-Id') { User.create!(name: "Alice").id }
        let(:sleep_record) { { started_at: nil } }
        run_test!
      end
    end
  end

  path '/api/sleep_records/{id}' do
    parameter name: :id, in: :path, type: :string
    parameter name: 'X-User-Id', in: :header, type: :string, required: true

    get 'Show a sleep record' do
      tags 'SleepRecords'
      produces 'application/json'
      response '404', 'not found' do
        let(:'X-User-Id') { User.create!(name: "Alice").id }
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/api/sleep_records/{id}' do
    put 'Update a sleep record' do
      tags 'SleepRecords'
      consumes 'application/json'
      produces 'application/json'
  
      parameter name: :id, in: :path, type: :string
      parameter name: 'X-User-Id', in: :header, type: :string, required: true
      parameter name: :sleep_record, in: :body, schema: {
        type: :object,
        properties: {
          ended_at: { type: :string, format: 'date-time' }
        },
        required: ['ended_at']
      }
  
      response '200', 'record updated' do
        let(:id) { record.id }
        let(:'X-User-Id') { user.id }   # key point: must match record.user
        let(:sleep_record) { { ended_at: Time.current.iso8601 } }
  
        run_test!
      end
    end
  end  

  path '/api/clock_out' do
    post 'Clock out from current open record' do
      tags 'SleepRecords'
      produces 'application/json'
      parameter name: 'X-User-Id', in: :header, type: :string, required: true

      response '422', 'no open record' do
        let(:'X-User-Id') { User.create!(name: "Alice").id }
        run_test!
      end
    end
  end
end
