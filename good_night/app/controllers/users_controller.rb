# app/controllers/users_controller.rb
class UsersController < ApplicationController
    before_action :require_current_user!, only: [:follow, :unfollow, :following_sleep_records]
    before_action :set_user, only: [:show, :follow, :unfollow, :following_sleep_records]
    
    def index
        render json: User.all.order(:id)
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

    # GET /api/users/:id/following_sleep_records
    def following_sleep_records    
        # Compute previous calendar week in app timezone
        Time.use_zone(Time.zone) do
            now = Time.zone.now
            start_of_this_week = now.beginning_of_week(:monday)
            start_of_prev_week = start_of_this_week - 1.week
            end_of_prev_week = start_of_this_week - 1.second
            
            following_ids = @user.following.select(:id)
            # record considered if it ENDED in previous week
            records = SleepRecord
              .closed_records
              .where(user_id: following_ids)
              .where(ended_at: start_of_prev_week..end_of_prev_week)
              .select('sleep_records.*, users.name AS user_name')
              .joins(:user)
              .order(duration_sec: :desc, ended_at: :desc)
              .page(params[:page] || 1)    # default to page 1
              .per(params[:items] || 20)   # default 20 per page

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
        
            render json: {
                records: records.as_json,
                pagination: {
                    current_page: records.current_page,
                    next_page: records.next_page,
                    prev_page: records.prev_page,
                    total_pages: records.total_pages,
                    total_count: records.total_count
                }
            }
        end
    end
    
    private
    def set_user
        @user = User.find(params[:id])
    end
end