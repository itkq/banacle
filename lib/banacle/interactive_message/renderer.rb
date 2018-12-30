require 'banacle/slack'

module Banacle
  module InteractiveMessage
    class Renderer
      def self.render_error(error)
        Slack::Response.new(
          response_type: "ephemeral",
          replace_original: false,
          text: "An error occurred: #{error}",
        ).to_json
      end

      def initialize(request, config)
        @request = request
        @config = config
      end

      attr_reader :request, :config

      def render_approved_message(result)
        text = original_message_text
        text += ":white_check_mark: *<@#{actioner_id}> approved this request*\n"
        text += "Result:\n"
        text += "```\n"
        text += result
        text += "```"

        render_replacing_message(text)
      end

      def render_rejected_message
        text = original_message_text
        text += ":no_entry_sign: *<@#{actioner_id}> rejected this request*"

        render_replacing_message(text)
      end

      def render_cancelled_message
        text = original_message_text
        text += "\nThe request was cancelled."

        render_replacing_message(text)
      end

      def render_replacing_message(text)
        Slack::Response.new(
          response_type: "in_channel",
          replace_original: true,
          text: text,
        ).to_json
      end

      def original_message_text
        request.original_message_text
      end

      def actioner_id
        request.actioner_id
      end
    end
  end
end
