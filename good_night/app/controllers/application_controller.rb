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

    def paginated_response(records, per_page)
        prev_page = records.prev_page
        prev_page ||= records.total_pages if records.out_of_range? && records.total_pages > 0
        
        render json: {
                records: records.as_json,
                pagination: {
                    current_page: records.current_page,
                    next_page: records.next_page,
                    prev_page: prev_page,
                    total_pages: records.total_pages,
                    total_count: records.total_count,
                    per_page: per_page
                }
            }
    end
end