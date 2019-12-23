# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :achievements do
    resources :encouragements, only: %i[new create]
  end

  namespace :api do
    resources :achievements, only: [:index]
  end

  root to: 'welcome#index'
end
