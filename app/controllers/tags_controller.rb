class TagsController < ApplicationController
  
  respond_to :html, :json

  def index
    if params[:query].present?
      @tags = Tag.search(params[:query], page: params[:page], limit:25)
    else
      @tags = Tag.all
    end
    respond_with(@tags)
  end

  def autocomplete
    render json: Tag.search(params[:query], fields: [{name: :text_start}], limit: 15).map(&:name)
  end

end