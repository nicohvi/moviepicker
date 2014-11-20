Rails.application.routes.draw do

  root 'movies#new'
  get 'movies/list', to: 'movies#list'

end
