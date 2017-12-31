Clockface::Engine.routes.draw do
  root to: redirect("/clockface/events")
  resources :events, except: [:show] do
    get :delete, to: "events#delete"
  end
end
