Rails.application.routes.default_url_options[:host] = "XXX"

Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'hello#index'
  post '/aws/auth',
        to: 'users#aws_auth',
        defaults: {format: 'json'},
        as: 'aws_auth'
end
