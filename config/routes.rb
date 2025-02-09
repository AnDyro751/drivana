Rails.application.routes.draw do
  # Rutas de autenticación web
  devise_for :users, controllers: {
    registrations: "user/registrations"
  }

  # Rutas de autenticación API
  devise_for :users,
    controllers: {
      sessions: "api/sessions",
      registrations: "api/registrations"
    },
    defaults: { format: :json },
    path: "api",
    path_names: {
      sign_in: "login",
      sign_out: "logout",
      registration: "signup"
    },
    as: :api_user # Esto agrega un prefijo 'api_' a los nombres de las rutas

  # API routes (sin dashboard namespace)
  resources :bookings, only: [ :index, :show, :create ] do
    member do
      post :extend_booking
      get :tickets
      get :consolidated_ticket
    end
  end

  resources :tickets, only: [ :index, :show, :create ]

  # Dashboard routes (mantienen la funcionalidad web actual)
  get "dashboard", to: "dashboard#index"
  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :dashboard do
    resources :cars, except: [ :edit, :update, :destroy ] do
      member do
        get :reserve
      end
    end
    resources :bookings, except: [ :edit, :update, :destroy ] do
      member do
        get :ticket
        get :extend_booking
        delete :cancel
      end
      resources :booking_extensions, only: [ :create ]
    end
    resources :tickets, only: [ :index, :show ]
  end
end
