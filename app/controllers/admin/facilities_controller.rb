# frozen_string_literal: true

class Admin::FacilitiesController < Admin::BaseController
  # before_action :set_default_request_format
  before_action :load_facilities, only: [:index]
  before_action :load_facility, only: %i[edit show destroy]

  def index
    # flash.now[:notice] = "notice test"
    # flash.now[:alert] = "error test"
  end

  def show; end

  def edit; end

  private

  def load_facilities
    facilities = Facility.all
    @pagy, @facilities = pagy(facilities)
  end

  def load_facility
    @facility = Facility.find_by(id: params[:id])
  end

  # def set_default_request_format
  # request.format = :json unless params[:fomat]
  # end
end
