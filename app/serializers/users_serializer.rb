class UsersSerializer < ApplicationCollectionSerializer
  def as_json
    build.as_json
  end

  def build
    @users.map do |user|
      UserSerializer.new(user)
    end
  end
end #/UsersSerializer
