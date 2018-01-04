Clockface::Engine.routes.draw do
  root to: redirect("/clockface/events")
  resources :events, except: [:show] do
    # Rails routes don't include a visible deletion page, only a `#destroy`
    # endpoint. Define a custom one
    get :delete, to: "events#delete"
  end
end
