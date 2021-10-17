# frozen_string_literal: true

class SiteStatsSerializer < ApplicationService
  def initialize(site_stats = nil)
    super()

    @site_stats = site_stats || SiteStats.new
  end

  def call
    Result.new(data: @site_stats.as_json)
  end
end
