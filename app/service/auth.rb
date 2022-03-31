require 'net/http'
module Auth
  module Jwt
    extend self

    JWKS_URL = ENV["JWKS_URL"]
    JWKS_CACHE_KEY = "jwks_key".freeze
    HTTP = Net::HTTP

    def call(token, audience: :web)
      JWT.decode(
        token,
        nil,
        true, # Verify the signature of this token
        algorithms: ["RS256"],
        iss: JWKS_URL,
        verify_iss: false,
        aud: audience,
        verify_aud: false,
        jwks: jwk_loader,
      )
    end

    private

    def jwk_loader
      ->(options) do
        # options[:invalidate] will be `true` if a matching `kid` was not found
        # https://github.com/jwt/ruby-jwt/blob/master/lib/jwt/jwk/key_finder.rb#L31
        jwks(force: options[:invalidate])
      end
    end

    def fetch_jwks
      response = HTTP.get_response(URI.parse(JWKS_URL))
      if response.code == "200"
        JSON.parse(response.body.to_s)
      end
    end

    def jwks(force: false)
      Rails.cache.fetch(JWKS_CACHE_KEY, force: force, skip_nil: true) do
        fetch_jwks
      end.deep_symbolize_keys
    end
  end
end