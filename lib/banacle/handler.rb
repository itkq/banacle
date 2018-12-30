require 'banacle/authenticator'
require 'banacle/slack_validator'

module Banacle
  class Handler
    class InvalidAuthenticatorError < StandardError; end

    def initialize(config)
      @config = config
    end

    attr_reader :config, :request, :auth

    def handle(request)
      @request = request

      unless skip_validation? || SlackValidator.valid_signature?(request)
        return [401, {}, "invalid request"]
      end

      handle_request
    end

    # override
    def handle_request
    end

    def set_authenticator!(auth)
      unless auth.is_a?(Banacle::Authenticator)
        raise InvalidAuthenticatorError.new(auth.inspect)
      end

      @auth = auth
    end

    private

    def authenticated?
      !auth || auth.authenticate(request)
    end

    def skip_validation?
      request.params["skip_validation"] || ENV["BANACLE_SKIP_VALIDATION"]
    end
  end
end
