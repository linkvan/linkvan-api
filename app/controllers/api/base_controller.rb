# frozen_string_literal: true

class Api::BaseController < ApplicationController
  before_action :handle_tokens
  before_action :handle_analytics_event

  def not_found
    render json: { error: 'not_found' }
  end

  private

  def base_result
    site_stats.merge(tokens: access_token)
  end

  def site_stats
    { site_stats: SiteStatsSerializer.call(SiteStats.new).data }
  end

  def handle_tokens
    access_token.refresh
    cookies['_linkvan_tokens'] = access_token.to_json
  end

  def handle_analytics_event
    # loads/creates proper Analytics::Visit and Analytics::Event data.
    event
  end

  def event
    @event ||= Analytics.register_event(analytics,
                                        controller_name: params[:controller],
                                        action_name: params[:action],
                                        request_url: request.url,
                                        request_params: request.params,
                                        request_ip: request.ip,
                                        request_user_agent: request.user_agent,
                                        lat: nil,
                                        long: nil)
  end

  def analytics
    @analytics ||= Analytics.find_or_create_visit_from(access_token)
  end

  def access_token
    @access_token ||= Analytics::AccessToken.load(token_params)
  end

  def token_params
    # @note: parameters take precedence over cookies.
    Analytics::AccessToken.extract_tokens_from(cookies['_linkvan_tokens'])
      .merge(Analytics::AccessToken.extract_tokens_from(params))
  end
end
