class Admin::FacilitiesController < Admin::BaseController
  # before_action :set_default_request_format
  before_action :load_facilities

  def index
    flash.now[:notice] = "notice test"
    flash.now[:alert] = "error test"
  end

  private
    def load_facilities
      @pagy, @facilities = pagy(Facility.all)
    end

  # def set_default_request_format
  # request.format = :json unless params[:fomat]
  # end
end
