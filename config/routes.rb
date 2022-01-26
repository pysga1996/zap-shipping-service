Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/api/shipment', to: 'shipment#index'

  post '/api/unit/import', to: 'unit#import'

  post '/api/test', to: 'shipment#read_data'
  # Almost every application defines a route for the root path ("/") at the top of this file.
  root "home#index"
end
