class Api::BaseController < ApplicationController
  private
    def base_result
      site_stats
    end

    def site_stats
      { site_stats: SiteStatsSerializer.new(SiteStats.new).build }
    end
end
