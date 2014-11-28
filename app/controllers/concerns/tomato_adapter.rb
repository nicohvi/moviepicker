class TomatoAdapter
  include HTTParty
  include AdapterBridge
  base_uri 'http://api.rottentomatoes.com/api/public/v1.0/'
  default_params apikey: ENV['rt_api_key']
  
  def initialize
  end

  def search(movie)
    return [] if movie.blank?
    options = { query: { q: movie } }
    api_response = call_async('/movies.json', options)
    sanitize JSON.parse(api_response)['movies']
  end

  def similar(movie_id)
    return [] if movie_id.blank?
    api_response = call_async("/movies/#{movie_id}/similar.json")
    sanitize JSON.parse(api_response)['movies']
  end

  private

  def sanitize(json)
    json.map { |movie|
      movie['release_dates']['theater'] ||= ''
      { tomato_id:      movie['id'],
        title:          movie['title'],
        release_year:   movie['release_dates']['theater'].split('-')[0],
        image:          movie['posters']['original'],
        tomato_rating:
          { critics:      movie['ratings']['critics_score'] || nil,
            audience:     movie['ratings']['audience_score'] || nil
          }
      } 
    }.reject { |movie| movie[:tomato_rating][:critics_rating] == -1 }
  end
 
end
