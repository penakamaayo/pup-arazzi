Rails.application.routes.draw do
  root 'dog_breeds#index'

  resources :dog_breeds, only: [:index] do
    collection do
      post :fetch_image
    end
  end
end