# frozen_string_literal: true

class Api::BaseController < ApplicationController
  before_action :handle_tokens

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

  def access_token
    @access_token ||= AccessToken.load(token_params)
  end

  def token_params
    # @note: parameters take precedence over cookies.
    AccessToken.extract_tokens_from(cookies['_linkvan_tokens'])
      .merge(AccessToken.extract_tokens_from(params))
  end
end
