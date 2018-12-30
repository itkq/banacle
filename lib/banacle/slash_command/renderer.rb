require 'banacle/slack'
require 'banacle/slash_command/builder'
require 'banacle/slash_command/command'

module Banacle
  module SlashCommand
    class Renderer
      def self.render(params, command, config)
        new(params, command, config).render
      end

      def self.render_unauthenticated
        render_error("you are not authorized to perform this command")
      end

      def self.render_error(error)
        Slack::Response.new(
          response_type: "ephemeral",
          text: "An error occurred: #{error}",
        ).to_json
      end

      def initialize(params, command, config)
        @params = params
        @command = command
        @config = config
      end

      attr_reader :params, :command, :config

      def render
        render_approval_request
      end

      def render_approval_request
        text = <<-EOS
<@#{user_id}> wants to *#{command.action} NACL DENY entry* under the following conditions:
```
#{JSON.pretty_generate(command.to_h)}
```
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
        params["user_id"]
      end
    end
  end
end
