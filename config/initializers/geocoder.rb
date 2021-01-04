Geocoder.configure(
  # geocoding options
  :timeout      => 20,           # geocoding service timeout (secs)
  :lookup       => :google,     # name of geocoding service (symbol)
  :ip_lookup    => :freegeoip,     # IP address geocoding service
  freegeoip: { host: "freegeoip.app" },
  use_https: true,
  :language     => :en,         # ISO-639 language code  :http_proxy   => nil,         # HTTP proxy server (user:pass@host:port)
  :https_proxy  => nil,         # HTTPS proxy server (user:pass@host:port)
  :cache        => nil,         # cache object (must respond to #[], #[]=, and #keys)
  :cache_prefix => 'geocoder:', # prefix (string) to use for all cache keys
  :api_key      => ENV['GOOGLE_MAP_API'],

  # exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and TimeoutError
  # :always_raise => [],

  # calculation options
  :units     => :mi,       # :km for kilometers or :mi for miles
  :distances => :linear    # :spherical or :linear
)
