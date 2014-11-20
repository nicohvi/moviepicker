class MoviesController < ApplicationController
  before_filter :set_tomato_adapter, only: :list

  def new

  end

  def list # rename search
    json = @tomato_adapter.search(params[:movie])
    render json: JSON.parse(json)
  end

  private

  def set_tomato_adapter
    @tomato_adapter = TomatoAdapter.new
  end

end
