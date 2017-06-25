Rails.application.routes.draw do
  mount Clockface::Engine => "/clockface"
  mount Sidekiq::Web => "/sidekiq"
end
