# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  get "/privacy", to: "home#privacy"
  get "/terms", to: "home#terms"

  get "401", to: "errors#unauthorized", as: :unauthorized
  get "403", to: "errors#forbidden", as: :forbidden
  get "404", to: "errors#not_found", as: :not_found

  devise_scope :user do
    namespace :users, as: "user" do
      resource :registration,
               only: %i[new create],
               path: "",
               path_names: { new: "sign_up" }

      resource :invitation, only: %i[] do
        get :edit, path: "accept", as: :accept
        get :destroy, path: "remove", as: :remove
      end

      match "sign_out" => "sessions#destroy", via: %i[get delete], as: :sign_out
    end
  end

  devise_for :users, skip: %i[registrations invitations], controllers: {
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  get "sign_up", to: redirect("/users/sign_up")
  get "sign_in", to: redirect("/users/sign_in")

  namespace :account, module: "accounts" do
    resource :password, only: %i[show update]
    resource :profile, only: %i[show update]
  end
end
