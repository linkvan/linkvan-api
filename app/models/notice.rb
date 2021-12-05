# frozen_string_literal: true

class Notice < ApplicationRecord
  has_rich_text :content

  enum notice_type: {
    general: "general",
    covid19: "covid19",
    warming_center: "warming_center",
    cooling_center: "cooling_center"
  }

  validates :title, :content, :slug, presence: true
  validates :slug, uniqueness: true
  # Disable ability to add attachments to ActionText (needed because ActiveStorage is not currently setup.
  validates :content, no_attachments: true

  before_validation :set_slug

  scope :timeline, -> { order(updated_at: :desc) }
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }

  private

  def set_slug
    self.slug = title.to_s.parameterize
  end
end
