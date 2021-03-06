# frozen_string_literal: true

class UsersSerializer < ApplicationCollectionSerializer
  def as_json
    @users.map do |user|
      UserSerializer.new(user).as_json
    end
  end
end # /UsersSerializer
