require 'banacle/slash_command/command'

module Banacle
  module InteractiveMessage
    class Parser
      def self.parse(payload)
        new.parse(payload)
      end

      def parse(payload)
        original_message = payload["original_message"]["text"]
        SlashCommand::Command.new_from_original_message(original_message)
      end
    end
  end
end
