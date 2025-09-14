Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  scope :api do
    resources :users, only: [:index, :show] do
      member do
        post :follow # POST /api/users/:id/follow
        delete :unfollow # DELETE /api/users/:id/unfollow
        get :following_sleep_records # GET /api/users/:id/following_sleep_records
      end
    end
    
    
    # Sleep records
    resources :sleep_records, only: [:index, :create, :update, :show]
    
    
    # Clock in/out convenience endpoints
    post "/clock_in", to: "sleep_records#clock_in"
    post "/clock_out", to: "sleep_records#clock_out"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
