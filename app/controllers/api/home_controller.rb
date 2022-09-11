# frozen_string_literal: true

class Api::HomeController < Api::BaseController
  # skip_before_action :authenticate_user!

  def index
    result = base_result

    alert = Alert.active.timeline.first
    result[:alert] = AlertSerializer.call(alert).data
    result[:notices] = compute_notices

    render json: result.as_json, status: :ok
  end

  def last_updated; end

  private

  def compute_notices
    result = {}

    Notice.notice_types.each_key do |type|
      result[type] = Notice.published.exists?(notice_type: type)
    end

    result
  end
end
