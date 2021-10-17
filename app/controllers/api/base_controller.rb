# frozen_string_literal: true

class Api::BaseController < ApplicationController
  private

  def base_result
    site_stats
  end

  def site_stats
    { site_stats: SiteStatsSerializer.call(SiteStats.new).data }
  end
end
