Rails.application.routes.draw do
  mount Clockface::Engine => "/clockface"
  mount Sidekiq::Web => "/sidekiq"

  root to: "home#index"
end
