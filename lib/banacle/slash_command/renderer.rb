require 'banacle/slack'

module Banacle
  module SlashCommand
    class Renderer
      def self.render_error(error)
        Slack::Response.new(
          response_type: "ephemeral",
          text: "An error occurred: #{error}",
        ).to_json
      end

      def initialize(request, command, config)
        @request = request
        @command = command
        @config = config
      end

      attr_reader :request, :command, :config

      def render_approval_request
        text = <<-EOS
<@#{user_id}> wants to *#{command.action} NACL DENY entry* under the following conditions:
#{command.to_code_block}
        EOS

        Slack::Response.new(
          response_type: "in_channel",
          text: text,
          attachments: [
            Slack::Attachment.new(
              text: config.dig(:approval_request, :attachment, :text) || "*Approval Request*",
              fallback: "TBD",
              callback_id: "banacle_approval_request",
              color: "#3AA3E3",
              attachment_type: "default",
              actions: [
                Slack::Action.approve_button,
                Slack::Action.reject_button,
                Slack::Action.cancel_button,
              ]
            ),
          ],
        ).to_json
      end

      def user_id
        request.user_id
      end
    end
  end
end
