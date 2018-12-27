require 'base64'
require 'openssl'

module Banacle
  class SlackValidator
    SLACK_SIGNING_SECRET_VERSION = 'v0'.freeze

    def self.valid_signature?(request)
      new.valid_signature?(request)
    end

    def valid_signature?(request)
      body = request.env["rack.request.form_vars"]
      slack_signature = request.env["HTTP_X_SLACK_SIGNATURE"]
      slack_timestamp = request.env["HTTP_X_SLACK_REQUEST_TIMESTAMP"]

      # https://api.slack.com/docs/verifying-requests-from-slack#verification_token_deprecation
      if (slack_timestamp.to_i - Time.now.to_i).abs > 60 * 5
        return false
      end

      sig_basestring = "#{SLACK_SIGNING_SECRET_VERSION}:#{slack_timestamp}:#{body}"
      digest = OpenSSL::HMAC.hexdigest("SHA256", signing_secret, sig_basestring)

      slack_signature == "#{SLACK_SIGNING_SECRET_VERSION}=#{digest}"
    end

    def signing_secret
      ENV.fetch('BANACLE_SLACK_SIGNING_SECRET')
    end
  end
end
