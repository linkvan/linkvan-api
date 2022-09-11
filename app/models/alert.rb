# frozen_string_literal: true

class Alert < ApplicationRecord
  has_rich_text :content

  validates :title, :content, presence: true
  # Disable ability to add attachments to ActionText (needed because ActiveStorage is not currently setup.
  validates :content, no_attachments: true

  scope :timeline, -> { order(updated_at: :desc) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def content_html
    content.to_s
  end
end
