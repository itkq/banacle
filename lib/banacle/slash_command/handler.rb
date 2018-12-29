require 'banacle/handler'
require 'banacle/slash_command/error'
require 'banacle/slash_command/parser'
require 'banacle/slash_command/renderer'

module Banacle
  module SlashCommand
    class Handler < Banacle::Handler
      def handle_request
        unless authenticated?
          return Renderer.render_unauthenticated
        end

        begin
          command = Parser.parse(request_text)
        rescue Error => e
          return Renderer.render_error(e)
        end

        Renderer.render(request.params, command)
      end

      private

      def request_text
        request.params["text"]
      end
    end
  end
end
