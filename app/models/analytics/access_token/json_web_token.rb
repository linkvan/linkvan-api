module Analytics
  class AccessToken
    module JSONWebToken
      class << self
        def encode(payload, expires_at)
          payload[:exp] = expires_at.to_i
          JWT.encode(payload, jwt_secret_key)
        end

        def decode(token)
          return {} if token.blank?

          JWT.decode(token, jwt_secret_key)
        rescue JWT::DecodeError
          {}
        end

        def jwt_secret_key
          ENV.fetch("JWT_KEY")
        end
      end
    end
  end
end
