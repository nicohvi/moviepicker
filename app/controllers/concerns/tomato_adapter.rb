class TomatoAdapter
  include HTTParty
  include AsyncCaller
  base_uri 'http://api.rottentomatoes.com/api/public/v1.0/'
  default_params apikey: ENV['rt_api_key']
  
  def initialize
  end

  def search(movie)
    raise ArgumentError, "You must pass a movie to search" if movie.blank?
    options = { query: { q: movie } }
    api_response = call_async('/movies.json', options)
    sanitize JSON.parse(api_response)['movies']
  end

  def similar(movie_id)
    raise ArgumentError, "You need to pass a movie id to find similar" if movie_id.blank?
    api_response = call_async("/movies/#{movie_id}/similar.json")
    sanitize JSON.parse(api_response)['movies']
  end

  private

  def sanitize(json)
    json.map { |movie|
      { tomato_id:      movie['id'],
        title:          movie['title'],
        release_year:   movie['release_dates']['theatre'],
        image:          movie['posters']['original'],
        tomato_rating:
          { critics:      movie['ratings']['critics_score'] || nil,
            audience:     movie['ratings']['audience_score'] || nil
          }
      } 
    }
  end
 
end
