require 'banacle/slash_command/error'
require 'banacle/slash_command/parser'
require 'banacle/slash_command/renderer'

require 'banacle/interactive_message/parser'
require 'banacle/interactive_message/renderer'

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

      SlashCommand::Renderer.render(request.params, command)
    end

    def handle_interactive_message(request)
      unless request.params["skip_validation"] # for debug
        unless SlackValidator.valid_signature?(request)
          return [401, {}, "invalid request"]
        end
      end

      command = InteractiveMessage::Parser.parse(JSON.parse(request.params["payload"]))
      InteractiveMessage::Renderer.render(request.params, command)
    end
  end
end
