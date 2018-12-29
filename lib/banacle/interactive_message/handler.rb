require 'banacle/handler'
require 'banacle/interactive_message/parser'
require 'banacle/interactive_message/renderer'

module Banacle
  module InteractiveMessage
    class Handler < Banacle::Handler
      def handle_request
        command = InteractiveMessage::Parser.parse(JSON.parse(request_payload))
        InteractiveMessage::Renderer.render(request.params, command)
      end

      private

      def request_payload
        request.params["payload"]
      end
    end
  end
end
