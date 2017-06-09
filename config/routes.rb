Clockface::Engine.routes.draw do
  root to: "dashboard#show"

  resource :dashboard, only: [:show]
  resources :scheduled_jobs, only: [:create, :update, :delete]
end
