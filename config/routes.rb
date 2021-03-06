DemoApp::Application.routes.draw do

  post "sessions/create"
  post "microposts/new"
	post "posts/cnmedia"
  get  "users/show_mobile"
  get  "users/user_with_email"
  get  "users/send_reset_password_email"
  get "talks/topics"

  resources :users do
    member do
      get :friends
      get :requested_friends
		  get :followees
      get :find_users
      get :relation
			get :relation_follow
      get :amazon_s3_temporary_credentials
      get :details
      get :avatar
      get :users_and_users_relation_with_emails
      get :reset_password
      get :aliyun_oss_credentials
      
      post :update_password      
      post :activate
      post :send_activation_code
    end
  end
  
  resources :sessions,   only: [:new, :create, :destroy]
  resources :posts, only: [:create, :destroy, :index, :update, :show] do
    member do
      get :comments
      get :reports
      get :media
      get :thumbnail
    end
  end
  resources :post_bans, only: [:create, :destroy]
  resources :post_reports, only: [:create, :index]
  resources :friendships, only: [:create, :destroy, :update]
  resources :comments, only: [:create]
  resources :landmarks, only: [:create, :index, :show]
  resources :notifications, only: [:update, :create]
	resources :follows, only: [:create, :destroy]
  resources :concierge_apps
  resources :events, only: [:index, :create, :show, :new, :destroy] do
    resources :talks, only: [:create, :show, :new, :destroy]
  end
  resources :content_recommendation_config

  root to: 'static_pages#home'

  match '/help',    to: 'static_pages#help'
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  match '/terms_of_use', to: 'static_pages#terms_of_use'
  match '/test', to: 'static_pages#test'

  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
