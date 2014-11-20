json.movies @movies do |movie|
  json.name         movie.name
  json.rating       movie.rating
  json.release_year movie.release_year
end
