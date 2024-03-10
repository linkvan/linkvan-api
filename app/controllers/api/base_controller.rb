# frozen_string_literal: true

class Api::BaseController < ApplicationController
  before_action :handle_tokens
  before_action :handle_analytics_event

  def not_found
    render json: { error: 'not_found' }
  end

  private

  def base_result
    site_stats
    #  NOTE: Removed tokens from result in favour of cookies
    #  .merge(tokens: access_token)
  end

  def site_stats
    { site_stats: SiteStatsSerializer.call(SiteStats.new).data }
  end

  def handle_tokens
    access_token.refresh
    access_token.save_to_cookies(cookies)
  end

  def handle_analytics_event
    # loads/creates proper Analytics::Visit and Analytics::Event data.
    event
  end

  def event
    @event ||= Analytics.register_event(
      analytics,
      controller_name: params[:controller],
      action_name: params[:action],
      request_url: request.url,
      request_params: request.params,
      request_ip: request.ip,
      request_user_agent: request.user_agent,
      lat: location_params[:lat],
      long: location_params[:long]
    )
  end

  def analytics
    @analytics ||= Analytics.find_or_create_visit_from(access_token, visit_params)
  end

  def access_token
    @access_token ||= Analytics::AccessToken.load(token_params)
  end

  def token_params
    Analytics::AccessToken.extract_tokens_from(cookies)
  end

  def visit_params
    location_params
  end

  def location_params
    {
      lat: location_headers["lat"],
      long: location_headers["lng"]
    }
  end

  def location_headers
    user_location = request.headers["User-Location"]

    parse_user_location(user_location).with_indifferent_access
  end

  def parse_user_location(user_location)
    return {} if user_location.blank?
    return user_location if user_location.is_a?(Hash)

    JSON.parse(user_location).to_h
  rescue JSON::ParserError
    {}
  end
end
