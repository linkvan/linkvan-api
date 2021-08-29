# frozen_string_literal: true

class UsersZones < ApplicationRecord
  belongs_to :user
  belongs_to :zone
end
