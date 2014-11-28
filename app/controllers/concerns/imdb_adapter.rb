require 'nokogiri'

class IMDBAdapter
  include HTTParty
  include AdapterBridge
  base_uri 'http://www.imdb.com/'
  headers 'Accept-language' => 'en-US'
    
  
  def initialize
  end 
  
  def search(movie)
    return [] if movie.blank?
    options = { query: { title: movie, title_type: 'feature' } }
    sanitize_list(call_async('/search/title', options))
  end

  def similar(movie_id)
    return [] if movie_id.blank?
    sanitize_single(call_async("/title/#{movie_id}/"))
  end

  private

  def sanitize_list(html)
    doc = Nokogiri::HTML(html)
    doc.css('.title')[0..4].map { |movie|
      { imdb_id:        (movie > 'a').first['href'].split('/')[2],
        title:          (movie > 'a').text,
        release_year:   (movie > '.year_type').text.delete('()')
      }
    }
  end

  def sanitize_single(html)
    doc = Nokogiri::HTML(html)
    doc.css('.rec_overview').map { |similar_movie| 
      { 
        title:        similar_movie.css('.rec-title a').text,
        release_year: similar_movie.css('.rec-title .nobr').text.delete('()'),
        image:        get_image(similar_movie.css('.rec_poster img')),
        imdb_rating:  similar_movie.css('.value').text
      }
    }.reject { |movie| movie[:imdb_rating].blank? }
  end

  def get_image(tag)
    tag.first.nil? ? '' : tag.first['loadlate']
  end

end
