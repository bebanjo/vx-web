VxWeb::Application.routes.draw do

  namespace :api do

    resources :users do
      collection do
        get :me
      end
    end

    namespace :user_identities do
      resources :gitlab, only: [:update, :create, :destroy]
    end

    resources :projects do
      resources :builds, only: [:index, :create]
      resources :cached_files, only: [:index]
      resource :subscription, only: [:create, :destroy], controller: "project_subscriptions"
      resources :pull_requests, only: [:index]
      resources :branches, only: [:index]
      member do
        get "key"
      end
    end

    resources :builds, only: [:show] do
      member do
        post :restart
      end
      collection do
        get :queued
        get "sha/:sha", action: :sha, as: :sha
      end
      resources :jobs, only: [:index]
    end

    resources :jobs, only: [:show] do
      resources :logs, only: [:index], controller: "job_logs"
    end

    resources :user_repos, only: [:index] do
      member do
        post :subscribe
        post :unsubscribe
      end
      collection do
        post :sync
      end
    end

    resources :cached_files, only: [:destroy]
    resources :status, only: [:show], id: /(jobs)/
    resources :events, only: [:index]

    resources :companies, only: [] do
      member do
        post :default
      end
    end
  end

  namespace :users do
    get    'github/callback', to: "github#callback"
    get    'failure',         to: redirect('/ui')

    resource :session, only: [:destroy, :show], controller: "session"
    resource :invite,  only: [:new]
    resource :signup,  only: [:show, :new, :create], controller: "signup"
  end

  put "/f/cached_files/:token/*file_name.:file_ext", to: "api/cached_files#upload", as: :upload_cached_file
  get "/f/cached_files/:token/*file_name.:file_ext", to: "api/cached_files#download"

  post '/callbacks/:_service/:_token', to: 'repo_callbacks#create', _service: /(github|gitlab)/,
    as: 'repo_callback'

  get "builds/sha/:sha" => "builds#sha"

  scope constraints: ->(req){ req.format == Mime::HTML } do
    get "/",         to: redirect("/ui")
    get "/ui",       to: "users/session#show"
    get "/ui/*path", to: "users/session#show"
  end
end
