require 'banacle/slack_validator'
require 'banacle/interactive_message/authenticator'
require 'banacle/interactive_message/parser'
require 'banacle/interactive_message/renderer'
require 'banacle/interactive_message/request'

module Banacle
  module InteractiveMessage
    class Handler
      def initialize(config, auth: nil)
        @config = config
        @auth = auth
      end

      attr_reader :config, :auth
      attr_accessor :request

      def handle(raw_request)
        unless slack_validator.valid_signature?(raw_request)
          return [401, {}, "invalid signagure"]
        end

        self.request = Request.new(raw_request)

        json = if request.action.approved?
                 handle_approval
               elsif request.action.rejected?
                 handle_reject
               elsif request.action.cancelled?
                 handle_cancellation
               end
        puts json

        json
      end

      private

      def handle_approval
        begin
          authenticate_approver!
        rescue Authenticator::Error => e
          return Renderer.render_error(e)
        end

        result = Parser.parse(request.payload).execute
        renderer.render_approved_message(result)
      end

      def handle_reject
        begin
          authenticate_rejector!
        rescue Authenticator::Error => e
          return Renderer.render_error(e)
        end

        renderer.render_rejected_message
      end

      def handle_cancellation
        begin
          authenticate_canceller!
        rescue Authenticator::Error => e
          return Renderer.render_error(e)
        end

        renderer.render_cancelled_message
      end

      def renderer
        Renderer.new(request, config)
      end

      def slack_validator
        @slack_validator ||= SlackValidator.new(config[:slack_signing_secret])
      end

      def authenticate_approver!
        auth.authenticate_approver!(request)
      end

      def authenticate_rejector!
        auth.authenticate_rejector!(request)
      end

      def authenticate_canceller!
        auth.authenticate_canceller!(request)
      end

      def auth
        config.dig(:interactive_message, :authenticator) || Authenticator.new
      end
    end
  end
end
