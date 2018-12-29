require 'banacle/slash_command/error'
require 'banacle/slash_command/parser'
require 'banacle/slash_command/renderer'

require 'banacle/interactive_message/parser'
require 'banacle/interactive_message/renderer'

require 'banacle/slack_validator'

module Banacle
  class Handler
    def self.handle_slash_command(request)
      new(request).handle_slash_command
    end

    def self.handle_interactive_message(request)
      new(request).handle_interactive_message
    end

    def initialize(request)
      @request = request
    end

    attr_reader :request

    def handle_slash_command
      unless skip_slack_validation? || SlackValidator.valid_signature?(request)
        return [401, {}, "invalid request"]
      end

      begin
        command = SlashCommand::Parser.parse(request_text)
      rescue SlashCommand::Error => e
        return SlashCommand::Renderer.render_error(e)
      end

      SlashCommand::Renderer.render(request.params, command)
    end

    def handle_interactive_message
      unless skip_slack_validation? || SlackValidator.valid_signature?(request)
        return [401, {}, "invalid request"]
      end

      command = InteractiveMessage::Parser.parse(JSON.parse(request_payload))
      InteractiveMessage::Renderer.render(request.params, command)
    end

    def request_text
      request.params["text"]
    end

    def request_payload
      request.params["payload"]
    end

    # for debug
    def skip_slack_validation?
      request.params["skip_validation"]
    end
  end
end
