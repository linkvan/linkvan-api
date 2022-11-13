# frozen_string_literal: true

class Api::NoticesController < Api::BaseController
  # skip_before_action :authenticate_user!
  before_action :load_notices

  # GET /notices
  def index
    result = base_result

    result[:notices] = @notices.to_a
    # result[:notices] = []
    # @notices.each do |notices|
    #   serializer = FacilitySerializer.call(facility, complete: false)
    #   result[:notices] << notices.as_json
    # end

    render json: result.as_json, status: :ok
  end

  # GET /notices/:slug
  def show
    @notice = Notice.find_by!(slug: params[:slug])
    result = base_result
    result[:notice] = @notice.as_json(methods: :content_html)

    render json: result, status: :ok
  end

  private

  def load_notices
    @notices = if search_params[:type].present?
      Notice.where(notice_type: search_params[:type])
    else
      Notice.all
    end
  end

  def search_params
    params.permit(:type)
  end
end
