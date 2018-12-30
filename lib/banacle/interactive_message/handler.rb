require 'banacle/handler'
require 'banacle/interactive_message/parser'
require 'banacle/interactive_message/renderer'

module Banacle
  module InteractiveMessage
    class Handler < Banacle::Handler
      def handle_request
        unless authenticated?
          return Renderer.render_unauthenticated
        end

        command = Parser.parse(JSON.parse(request_payload))
        Renderer.render(request.params, command, config)
      end

      private

      def request_payload
        request.params["payload"]
      end
    end
  end
end
