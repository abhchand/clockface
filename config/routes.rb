Clockface::Engine.routes.draw do
  root to: "dashboards#show"

  resource :dashboard, only: [:show]
  resources :scheduled_jobs, only: [:create, :update, :destroy]
end
