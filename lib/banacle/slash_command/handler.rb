require 'banacle/handler'
require 'banacle/slash_command/error'
require 'banacle/slash_command/parser'
require 'banacle/slash_command/renderer'
require 'banacle/slash_command/request'

module Banacle
  module SlashCommand
    class Handler < Banacle::Handler
      def handle_request
        unless authenticated?
          return Renderer.render_unauthenticated
        end

        request = Request.new(@request)

        begin
          command = Parser.parse(request.text)
        rescue Error => e
          return Renderer.render_error(e)
        end

        Renderer.render(request, command, config)
      end
    end
  end
end
