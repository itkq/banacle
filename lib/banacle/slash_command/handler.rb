require 'banacle/slack_validator'
require 'banacle/slash_command/authenticator'
require 'banacle/slash_command/error'
require 'banacle/slash_command/parser'
require 'banacle/slash_command/renderer'
require 'banacle/slash_command/request'

module Banacle
  module SlashCommand
    class Handler
      def initialize(config)
        @config = config
      end

      attr_reader :config

      def handle(raw_request)
        unless slack_validator.valid_signature?(raw_request)
          return [401, {}, "invalid signagure"]
        end

        request = Request.new(raw_request)

        begin
          authenticate_requester!(request)
          command = Parser.parse(request.text)
        rescue Error => e
          return Renderer.render_error(e)
        end

        json = Renderer.new(request, command, config).render_approval_request
        puts json

        json
      end

      private

      def slack_validator
        @slack_validator ||= SlackValidator.new(config[:slack_signing_secret])
      end

      def authenticate_requester!(request)
        auth.authenticate_requester!(request)
      end

      def auth
        config.dig(:slash_command, :authenticator) || Authenticator.new
      end
    end
  end
end
