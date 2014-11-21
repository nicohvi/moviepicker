Rails.application.routes.draw do

  root 'movies#new'
  get 'movies/list', to: 'movies#list'
  get 'movies/similar/:tomato_id', to: 'movies#similar'

end
