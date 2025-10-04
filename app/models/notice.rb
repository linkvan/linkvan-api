# frozen_string_literal: true

class Notice < ApplicationRecord
  has_rich_text :content

  enum :notice_type,
    general: "general",
    covid19: "covid19",
    warming_center: "warming_center",
    cooling_center: "cooling_center",
    water_fountain: "water_fountain"

  validates :title, :content, :slug, presence: true
  validates :slug, uniqueness: true
  # Disable ability to add attachments to ActionText (needed because ActiveStorage is not currently setup.
  validates :content, no_attachments: true

  before_validation :set_slug

  scope :timeline, -> { order(updated_at: :desc) }
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }

  def self.notice_types_for_display
    result = {}.with_indifferent_access
    notice_types.each_key do |k|
      result[k] = k.to_s.titleize
    end
    result
  end

  def content_html
    content.to_s
  end

  private

  def set_slug
    self.slug = title.to_s.parameterize
  end
end
