# frozen_string_literal: true

class UsersSerializer < ApplicationCollectionSerializer
  delegate :as_json, to: :build

  def build
    @users.map do |user|
      UserSerializer.new(user)
    end
  end
end
