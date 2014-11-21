class MoviesController < ApplicationController
  before_filter :set_tomato_adapter, except: :new

  def new

  end

  def list # TODO rename search
    json = @tomato_adapter.search(params[:movie])
    render json: JSON.parse(json)
  end

  def similar
    json = @tomato_adapter.similar(params[:tomato_id])
    render json: JSON.parse(json)
  end

  private

  def set_tomato_adapter
    @tomato_adapter = TomatoAdapter.new
  end

end
