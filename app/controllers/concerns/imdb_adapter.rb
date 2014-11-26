require 'nokogiri'

class IMDBAdapter
  include HTTParty
  include AsyncCaller
  base_uri 'http://www.imdb.com/'
  headers 'Accept-language' => 'en-US'
    
  
  def initialize
  end 
  
  def search(movie)
    raise ArgumentError, "You must pass a movie to search" if movie.blank?
    options = { query: { q: movie } }
    api_response = call_async('/find', options)
    sanitize_list(api_response)
  end

  def similar(movie_id)
    raise ArgumentError, "You must pass a movie to search" if movie_id.blank?
    sanitize_single(call_async("http://www.imdb.com/title/#{movie_id}/?ref_=fn_al_tt_8"))
  end

  private

  def sanitize_list(html)
    doc = Nokogiri::HTML(html)
    
    doc.css('.findList')[0].css('td.result_text a').map { |movie_href|
      { imdb_id: movie_href.attributes['href'].value.split('/')[2],
        title: movie_href.text
      }
    }
  end

  def sanitize_single(html)
    doc = Nokogiri::HTML(html)
    
    doc.css('.rec-jaw-upper').map { |similar_movie| 
      { 
        title:        similar_movie.css('.rec-title a').text,
        imdb_rating:  similar_movie.css('.value').text
      }
    }
  end

end
