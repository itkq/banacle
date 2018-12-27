require 'banacle/slash_command/command'

module Banacle
  module InteractiveMessage
    class Parser
      def self.parse(payload)
        new.parse(payload)
      end

      def parse(payload)
        original_text = payload["original_message"]["text"]
        original_json = JSON.parse(
          original_text.match(command_json_regex)[1].strip, symbolize_names: true,
        )
        command = SlashCommand::Command.new(**original_json)
      end

      # TODO: sync slash_command/renderer
      def command_json_regex
        /```([^`]+)```/.freeze
      end
    end
  end
end
