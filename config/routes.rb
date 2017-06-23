Clockface::Engine.routes.draw do
  root to: redirect("/clockface/jobs")
  resources :jobs, except: [:show] do
    get :delete, to: "jobs#delete"
  end
end
