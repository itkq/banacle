require 'banacle/handler'
require 'banacle/interactive_message/request'
require 'banacle/interactive_message/parser'
require 'banacle/interactive_message/renderer'

module Banacle
  module InteractiveMessage
    class Handler < Banacle::Handler
      def handle_request
        unless authenticated?
          return Renderer.render_unauthenticated
        end

        request = Request.new(@request)
        command = Parser.parse(request.payload)
        Renderer.render(request, command, config)
      end
    end
  end
end
