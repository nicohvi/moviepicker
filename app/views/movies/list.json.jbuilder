json.movies movies do |movie|
  json.tomato_id      movie[:tomato_id]
  json.imdb_id        movie[:imdb_id]
  json.title          movie[:title]
  json.release_year   movie[:release_date]
  json.image          movie[:image]
end

json.total  movies.length
