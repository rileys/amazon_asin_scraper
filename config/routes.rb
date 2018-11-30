Rails.application.routes.draw do
  root 'products#search'

  resources :products, only: [] do
    collection do
      get 'search(/:asin)', action: :search, as: :search
    end
  end
end
