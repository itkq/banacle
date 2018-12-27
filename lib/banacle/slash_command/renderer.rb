require 'banacle/slash_command/builder'
require 'banacle/slash_command/command'

module Banacle
  module SlashCommand
    class Renderer
      def self.render(params, command)
        new.render(params, command)
      end

      def self.render_error(error)
        new.render_error(error)
      end

      def render(params, command)
        case command.action
        when Command::LIST_VPC_ACTION
          render_list_vpc(command)
        else
          render_approval_request(params, command)
        end
      end

      def render_error(error)
        Slack::Response.new(
          response_type: "ephemeral",
          text: "An error occurred: #{error}",
        ).to_json
      end

      def render_list_vpc(command)
        vpcs = aws.fetch_vpcs(command.region)
        text = "VPCs in #{command.region} are:\n"
        text += "```\n"
        text += vpcs.map { |name, id| "- #{id} (#{name})" }.join("\n")
        text += "```"

        Slack::Response.new(
          response_type: "in_channel",
          text: text,
        ).to_json
      end

      def render_approval_request(params, command)
        text = <<-EOS
<@#{params["user_id"]}> wants to *#{command.action}* CIDRs under the following conditions:
```
#{JSON.pretty_generate(command.to_h)}
```
        EOS

        Slack::Response.new(
          response_type: "in_channel",
          text: text,
          attachments: [
            Slack::Attachment.new(
              text: "*Approval Request*",
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

      private

      def aws
        @aws = Aws.new
      end
    end
  end
end
