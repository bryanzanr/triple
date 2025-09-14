# app/controllers/sleep_records_controller.rb
class SleepRecordsController < ApplicationController
    before_action :require_current_user!
    before_action :set_record, only: [:show, :update]
  
    # GET /api/sleep_records
    # List current user's sleep records (newest first)
    def index
      page = params[:page].presence&.to_i || 1
      per_page = params[:items].to_i
      per_page = 20 if per_page <= 0
      cache_key = [
          "sleep_records",
          @current_user.id,
          page,
          per_page
      ].join(":")
      records = @current_user.sleep_records.order(created_at: :desc)
        .page(page)
        .per(per_page)
      paginated_response(records, per_page, cache_key)
    end
  
    # POST /api/sleep_records
    # Create arbitrary record (advanced use, usually for testing/backfill)
    def create
      record = @current_user.sleep_records.new(sleep_record_params)
      if record.save
        render json: record, status: :created
      else
        render json: { error: record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /api/sleep_records/:id
    def update
      if @record.update(sleep_record_params)
        render json: @record
      else
        render json: { error: @record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # GET /api/sleep_records/:id
    def show
      render json: @record
    end
  
    # POST /api/clock_in
    # Starts a new sleep record if none is open
    def clock_in
      existing = @current_user.sleep_records.open_records.first
      if existing
        render json: { error: 'already clocked in', record_id: existing.id }, status: :conflict and return
      end
  
      record = @current_user.sleep_records.create!(started_at: Time.current)
      open_records = @current_user.sleep_records.open_records.order(:created_at)
      render json: { record: record, open_clock_ins: open_records }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  
    # POST /api/clock_out
    # Closes the open sleep record if any
    def clock_out
      record = @current_user.sleep_records.open_records.first
      unless record
        render json: { error: 'no open clock-in' }, status: :unprocessable_entity and return
      end
  
      record.update!(ended_at: Time.current)
      render json: record
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  
    private
  
    def set_record
      @record = @current_user.sleep_records.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'not found' }, status: :not_found
    end
  
    def sleep_record_params
      params.require(:sleep_record).permit(:started_at, :ended_at)
    end
  end
  