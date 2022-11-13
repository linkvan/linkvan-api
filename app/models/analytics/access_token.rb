class Analytics::AccessToken
  COOKIE_PREFIX = "_linkvanapi_".freeze
  MAPPING = {
    uuid: 'uuid',
    session_token: 'session-token'
  }.freeze

  attr_reader :uuid, :session_token, :session_id, :data

  def self.load(params)
    params = params.to_h.with_indifferent_access

    parameters = {}
    MAPPING.each_pair do |to_key, from_key|
      # Tries both symbol and string variations
      parameters[to_key] = params[from_key]
    end

    new(**parameters)
  end

  def self.extract_tokens_from(params_or_cookie)
    result = case params_or_cookie
             when String
               # Cookies are usually a json string.
               JSON.parse(params_or_cookie, symbolize_names: true)
             when ActionController::Parameters
               # Rails parameters ask to explicitly permit
               params_or_cookie.permit(*MAPPING.values).to_h
             else
               params_or_cookie.to_h
             end

    result.with_indifferent_access.slice(*MAPPING.values)
  end

  def initialize(uuid:, session_token:)
    @uuid = uuid || SecureRandom.hex
    @session_token = session_token

    decoded_data, _decoded_header = JSONWebToken.decode(session_token)
    @data = decoded_data.to_h.with_indifferent_access
    @session_id = @data[:session_id] || SecureRandom.hex
  end

  def refresh
    # Update session_token with the latest data and expiration
    @session_token = JSONWebToken.encode(data, 30.minutes.from_now)
  end

  def as_json(options=nil)
    result = {}
    MAPPING.each_pair do |method_name, external_key|
      result[external_key] = self.send(method_name)
    end

    result.as_json(options)
  end
end
