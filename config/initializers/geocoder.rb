Geocoder.configure(
  # Geocoding options
  # timeout: 3,                 # geocoding service timeout (secs)
  timeout: 3,
  # lookup: :nominatim,         # name of geocoding service (symbol)
  lookup: :google,
  # ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  # language: :en,              # ISO-639 language code
  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # api_key: nil,               # API key for geocoding service
  api_key: ENV.fetch("GOOGLE_MAPS_API_TOKEN", nil),

  # cache: nil,                 # cache object (must respond to #[], #[]=, and #del)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],
  # Raise in development and test environments to help debugging
  always_raise: (Rails.env.production? ? [] : :all),

  # Calculation options
  # units: :km                  # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear
  units: :km
)
