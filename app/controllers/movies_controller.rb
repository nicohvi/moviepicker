class MoviesController < ApplicationController
  before_filter :set_adapters, except: :new

  def new

  end

  def search
    tomato_json = @tomato_adapter.search(params[:movie]) 
    imdb_json   = @imdb_adapter.search(params[:movie]) 
    movies = merge_api_responses(tomato_json, imdb_json)
    if movies.empty?
      render json: { error: t('error.no_results') }, status: 404
    else  
      render json:  render_to_string( template: 'movies/list.json.jbuilder', 
                      locals: { movies: movies } )
    end
  end

  def similar
    tomato_json = @tomato_adapter.similar(params[:tomato_id])
    imdb_json   = @imdb_adapter.similar(params[:imdb_id])
    movies = merge_api_responses(tomato_json, imdb_json)
    render json: movies
  end

  private

  def set_adapters
    @tomato_adapter, @imdb_adapter = TomatoAdapter.new, IMDBAdapter.new  
  end

  def merge_api_responses(tomato_json, imdb_json)
    movies = tomato_json + imdb_json
    movies.group_by { |movie| movie[:title] }.map { |key, value| value.inject(:merge) }
  end

end
