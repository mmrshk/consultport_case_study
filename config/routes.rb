Rails.application.routes.draw do
  resources :currencies, only: [] do
    member do
      post :convert
    end
  end
end
