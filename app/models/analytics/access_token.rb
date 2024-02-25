class Analytics::AccessToken
  COOKIE_PREFIX = "_linkvanapi_tokens".freeze
  MAPPING = {
    uuid: 'uuid',
    session_token: 'session-token'
  }.freeze

  attr_reader :uuid, :session_token, :data

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
    value = params_or_cookie[COOKIE_PREFIX].presence || params_or_cookie

    result = case value
             when String
               # Cookies are usually a json string.
               JSON.parse(value, symbolize_names: true)
             when ActionController::Parameters
               # Rails parameters ask to explicitly permit
               value.permit(*MAPPING.values).to_h
             else
               value.to_h
             end

    result.with_indifferent_access.slice(*MAPPING.values)
  end

  def initialize(uuid:, session_token:)
    @uuid = uuid || SecureRandom.hex
    @session_token = session_token

    decoded_data, _decoded_header = JSONWebToken.decode(session_token)
    @data = decoded_data.to_h.with_indifferent_access
    # If session_id is not present, set it to a new random value
    @data[:session_id] ||= SecureRandom.hex
  end

  def refresh
    File.open("fabio.txt", "a") do |f|
      f.puts data.to_json
    end
    # Update session_token with the latest data and expiration
    @session_token = JSONWebToken.encode(data, 30.minutes.from_now)
  end

  def session_id
    @data[:session_id]
  end

  def save_to_cookies(cookies)
    cookies[COOKIE_PREFIX] = to_json
  end

  def as_json(options=nil)
    result = {}
    MAPPING.each_pair do |method_name, external_key|
      result[external_key] = self.send(method_name)
    end

    result.as_json(options)
  end
end
