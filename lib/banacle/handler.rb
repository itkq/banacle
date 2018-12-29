require 'banacle/slack_validator'

module Banacle
  class Handler
    class InvalidAuthenticatorError < StandardError; end

    attr_reader :request, :auth

    def handle(request)
      @request = request

      unless skip_validation? || SlackValidator.valid_signature?(request)
        return [401, {}, "invalid request"]
      end

      if auth && !auth.authenticate(request)
        return [402, {}, "unauthenticated"]
      end

      handle_request
    end

    # override
    def handle_request
    end

    private

    def skip_validation?
      request.params["skip_validation"] || ENV["BANACLE_SKIP_VALIDATION"]
    end

    def set_authenticator!
      unless auth.is_a?(Banacle::Authentication)
        raise InvalidAuthenticatorError.new(auth.inspect)
      end

      @auth = auth
    end
  end
end
