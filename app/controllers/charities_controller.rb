class CharitiesController < ApplicationController
  before_action :set_charity, only: [:show]

  respond_to :html, :json


  def show
    respond_with(@charity)
  end

  def find_by_tag
    if params[:tag].present?
      tag_array = params[:tag]
      tag_array = tag_array.lines.to_a if tag_array.is_a? String #convert to array
      charities = Charity.joins(:tags).where(tag_id: tag_array)
    end
    respond_with(@charities)
  end

  private
    def set_charity
      @charity = Charity.where("(njalo_id=? OR slug=?)", params[:id], params[:id]).last
    end
end
