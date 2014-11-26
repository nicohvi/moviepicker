Rails.application.routes.draw do

  root 'movies#new'
  get 'movies/search', to: 'movies#search'
  get 'movies/similar', to: 'movies#similar'

end
