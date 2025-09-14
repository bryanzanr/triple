# app/controllers/users_controller.rb
class UsersController < ApplicationController
    before_action :require_current_user!, only: [:follow, :unfollow, :following_sleep_records]
    before_action :set_user, only: [:show, :follow, :unfollow]
    
    def index
        per_page = params[:items].to_i
        per_page = 20 if per_page <= 0
        paginated_response(User.all.order(:id)
            .page(params[:page].presence&.to_i || 1)
            .per(per_page), per_page)
    end
    
    def show
        render json: @user
    end

    def follow
        follow = Follow.find_or_initialize_by(follower: @current_user, followed: @user)
        if follow.persisted? || follow.save
            render json: { ok: true }
        else
            render json: { error: follow.errors.full_messages }, status: :unprocessable_entity
        end
    end
        
    def unfollow
        Follow.where(follower: @current_user, followed: @user).delete_all
        render json: { ok: true }
    end

    # GET /api/users/following_sleep_records
    def following_sleep_records    
        # Compute previous calendar week in app timezone
        Time.use_zone(Time.zone) do
            now = Time.zone.now
            start_of_this_week = now.beginning_of_week(:monday)
            start_of_prev_week = start_of_this_week - 1.week
            end_of_prev_week = start_of_this_week - 1.second
            
            following_ids = @current_user.following.select(:id)
            # sanitize items param
            per_page = params[:items].to_i
            per_page = 20 if per_page <= 0   # fallback to default
            # record considered if it ENDED in previous week
            records = SleepRecord
              .closed_records
              .where(user_id: following_ids)
              .where(ended_at: start_of_prev_week..end_of_prev_week)
              .select('sleep_records.*, users.name AS user_name')
              .joins(:user)
              .order(duration_sec: :desc, ended_at: :desc)
              .page(params[:page].presence&.to_i || 1) # default to page 1
              .per(per_page) # default 20 per page

            payload = records.map do |r|
                {
                id: r.id,
                user_id: r.user_id,
                user_name: r.attributes['user_name'],
                started_at: r.started_at,
                ended_at: r.ended_at,
                duration_sec: r.duration_sec
                }
            end
        
            paginated_response(records, per_page)
        end
    end
    
    private
    def set_user
        @user = User.find(params[:id])
    end
end