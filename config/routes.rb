Clockface::Engine.routes.draw do
  root to: redirect("/jobs")
  resources :jobs
end
