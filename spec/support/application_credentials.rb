require 'ostruct'

module ApplicationCredentials
  def config_jwt(jwt_params = {})
    jwt_credentials = OpenStruct.new({
      secret_key: 'a_secret_key'
    }.merge(jwt_params))

    allow(Rails.application.credentials).to receive(:jwt).and_return(jwt_credentials)
  end
end

RSpec.configure do |c|
  c.include ApplicationCredentials
end
