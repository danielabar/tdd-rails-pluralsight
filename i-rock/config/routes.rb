# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :achievements

  namespace :api do
    resources :achievements, only: [:index]
  end

  root to: 'welcome#index'
end
