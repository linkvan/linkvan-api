# frozen_string_literal: true

class SiteStats
  include ActiveModel::Attributes
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON

  attribute :last_updated, :datetime, default: -> { compute_last_updated }

  class << self
    def facilities
      Facility.order(updated_at: :desc)
    end

    def notices
      Notice.order(updated_at: :desc)
    end

    private

    def compute_last_updated
      [last_facility&.updated_at, last_notice&.updated_at].reject(&:nil?).max
    end

    def last_facility
      facilities.first
    end

    def last_notice
      notices.first
    end
  end
end
