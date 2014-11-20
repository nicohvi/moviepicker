class TomatoAdapter
  include HTTParty
  base_uri 'http://api.rottentomatoes.com/api/public/v1.0/'
  default_params apikey: ENV['rt_api_key']
  
  def initialize
  end

  def search(movie)
    raise ArgumentError, "You must pass a movie to search" if movie.blank?
    options = { query: { q: movie} }
    self.class.get "/movies.json", options
  end
 
end
