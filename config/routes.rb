Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/api/shipment', to: 'shipment#index'

  get '/view/units', to: 'unit#get_all_root_units'

  get '/view/units/:id', to: 'unit#get_unit_detail'

  post '/view/units/import/lvl/3', to: 'unit#import_lvl_3'

  get '/api/units/lvl/1', to: 'unit_rest#get_lvl_1_units'

  get '/api/units/lvl/2', to: 'unit_rest#get_lvl_2_units'

  get '/api/units/lvl/3', to: 'unit_rest#get_lvl_3_units'

  get '/api/units/:id', to: 'unit_rest#get_unit_by_id'

  get '/api/units-by-conditions', to: 'unit_rest#get_units_by_conditions'

  post '/api/units/import', to: 'unit_rest#import'

  post '/api/test', to: 'shipment#read_data'

  get "/view/error", to: 'home#error'
  # Almost every application defines a route for the root path ("/") at the top of this file.
  root "home#index"
end
