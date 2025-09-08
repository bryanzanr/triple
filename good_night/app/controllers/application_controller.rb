# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
    before_action :set_current_user

    private
    def set_current_user
        uid = request.headers['X-User-Id']
        @current_user = uid.present? ? User.find_by(id: uid) : nil
    end

    def require_current_user!
        render json: { error: 'X-User-Id header required' }, status: :unauthorized unless @current_user
    end
end