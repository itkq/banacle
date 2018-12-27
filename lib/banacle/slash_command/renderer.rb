require 'banacle/slash_command/builder'

module Banacle
  module SlashCommand
    class Renderer
      def self.render(command)
        new.render(command)
      end

      def self.render_error(error)
        new.render_error(error)
      end

      def render(command)
        case command.action
        when Builder::LIST_VPC_ACTION
          render_list_vpc(command)
        else
          render_approval_request(command)
        end
      end

      def render_approval_request(command)
        # TODO: implement
      end

      def render_list_vpc(command)
        vpcs = aws.fetch_vpcs(command.region)
        text = "VPCs in #{command.region} are:\n"
        text += "```\n"
        text += vpcs.map { |name, id| "- #{id} (#{name})" }.join("\n")
        text += "```"

        {
          response_type: "in_channel",
          text: text,
        }.to_json
      end

      def render_error(error)
        {
          response_type: "ephemeral",
          text: "An error occurred: #{error.to_s}",
        }.to_json
      end

      private

      def aws
        @aws = Aws.new
      end
    end
  end
end
