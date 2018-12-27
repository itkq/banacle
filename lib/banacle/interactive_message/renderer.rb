require 'banacle/slack'
require 'banacle/slash_command/command'

module Banacle
  module InteractiveMessage
    class Renderer
      def self.render(params, command)
        new.render(params, command)
      end

      def render(params, command)
        payload = JSON.parse(params["payload"], symbolize_names: true)
        action = Slack::Action.new(payload[:actions].first)

        if action.approved?
          render_approved_message(payload, command)
        elsif action.rejected?
          render_rejected_message(payload, command)
        elsif action.cancelled?
          render_cancelled_message(payload, command)
        else
          # Do nothing
        end
      end


      def render_approved_message(payload, command)
        if is_self_action?(payload)
          render_error("you cannot approve the request by yourself")
        else
        end
      end

      def render_rejected_message(payload, command)
        if is_self_action?(payload)
          render_error("you cannot reject the request by yourself")
        else
        end
      end

      def render_cancelled_message(payload, command)
        if is_self_action?(payload)
          text = payload[:original_message][:text]
          text += "\nThe request was cancelled."

          Slack::Response.new(
            response_type: "in_channel",
            replace_original: true,
            text: text,
          ).to_json
        else
          render_error("you cannot cancel the request by other than the requester")
        end
      end

      def render_error(error)
        Slack::Response.new(
          response_type: "ephemeral",
          replace_original: false,
          text: "An error occurred: #{error}",
        ).to_json
      end

      def is_self_action?(payload)
        payload[:user][:id] == payload[:original_message][:text].match(/\A<@([^>]+)>/)[1]
      end
    end
  end
end
