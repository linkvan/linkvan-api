# frozen_string_literal: true

class SiteStatsSerializer < ApplicationSerializer
  def as_json(response = nil)
    result = super(response)

    result.merge({ site_stats: build })
  end

  def build
    site_stats
  end

  private

  def site_stats
    @site_stats ||= SiteStats.new
  end
end
