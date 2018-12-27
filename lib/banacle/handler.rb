require 'banacle/slash_command/error'
require 'banacle/slash_command/parser'
require 'banacle/slash_command/renderer'
require 'banacle/slack_validator'

module Banacle
  class Handler
    def handle_slash_command(request)
      unless request.params["skip_validation"] # for debug
        unless SlackValidator.valid_signature?(request)
          return [401, {}, "invalid request"]
        end
      end

      begin
        command = SlashCommand::Parser.parse(request.params["text"])
      rescue SlashCommand::Error => e
        return SlashCommand::Renderer.render_error(e)
      end

      SlashCommand::Renderer.render(command)
    end

    def handle_interactive_message(text)
      unless SlackValidator.valid_signature?(request)
        return [401, {}, "invalid request"]
      end

      # TODO: implement
    end
  end
end
