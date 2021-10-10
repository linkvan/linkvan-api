# frozen_string_literal: true

class Service < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def code
    # name.split.underscore.join('_')
    name.underscore
  end
end
