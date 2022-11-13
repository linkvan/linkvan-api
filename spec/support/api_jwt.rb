module ApiJwt
  def config_jwt(jwt_params = {})
    jwt_credentials = double('jwt_credentials', **{
      secret_key: 'a_secret_key'
    }.merge(jwt_params))

    allow(Rails.application.credentials).to receive(:jwt).and_return(jwt_credentials)
  end
end

RSpec.configure do |c|
  c.include ApiJwt
end
