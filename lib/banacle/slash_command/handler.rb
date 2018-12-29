require 'banacle/handler'
require 'banacle/slash_command/error'
require 'banacle/slash_command/parser'
require 'banacle/slash_command/renderer'

module Banacle
  module SlashCommand
    class Handler < Banacle::Handler
      def handle_request
        begin
          command = SlashCommand::Parser.parse(request_text)
        rescue SlashCommand::Error => e
          return SlashCommand::Renderer.render_error(e)
        end

        SlashCommand::Renderer.render(request.params, command)
      end

      private

      def request_text
        request.params["text"]
      end
    end
  end
end
