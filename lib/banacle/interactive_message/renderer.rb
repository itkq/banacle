require 'banacle/slack'
require 'banacle/slash_command/command'

module Banacle
  module InteractiveMessage
    class Renderer
      def self.render(params, command)
        new(params, command).render
      end

      def initialize(params, command)
        @params = params
        @command = command
      end

      attr_reader :params, :command

      def render
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

      protected

      # override
      def authenticated_user?
        true
      end

      private

      def render_approved_message(payload, command)
        unless valid_approver?
          return render_error("you cannot approve the request by yourself")
        end

        if authenticated_user?
          result = command.execute

          text = original_message_text
          text += ":white_check_mark: *<@#{actioner_id}> approved this request*\n"
          text += "Result:\n"
          text += "```\n"
          text += result
          text += "```"

          render_replacing_message(text)
        else
          render_error("you are not permitted to approve the request")
        end
      end

      def render_rejected_message(payload, command)
        unless valid_rejector?
          return render_error("you cannot reject the request by yourself")
        end

        if authenticated_user?
          text = original_message_text
          text += ":no_entry_sign: *<@#{actioner_id}> rejected this request*"

          render_replacing_message(text)
        else
          render_error("you are not permitted to reject the request")
        end
      end

      def render_cancelled_message(payload, command)
        unless valid_canceller?
          return render_error("you cannot cancel the request by other than the requester")
        end

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

      def render_error(error)
        Slack::Response.new(
          response_type: "ephemeral",
          replace_original: false,
          text: "An error occurred: #{error}",
        ).to_json
      end

      def valid_approver?
        ENV['BANACLE_SKIP_VALIDATION'] || !self_actioned?
      end

      def valid_rejector?
        ENV['BANACLE_SKIP_VALIDATION'] || !self_actioned?
      end

      def valid_canceller?
        ENV['BANACLE_SKIP_VALIDATION'] || self_actioned?
      end

      def self_actioned?
        requester_id == actioner_id
      end

      def requester_id
        original_message_text.match(/\A<@([^>]+)>/)[1]
      end

      def actioner_id
        payload[:user][:id]
      end

      def original_message_text
        payload[:original_message][:text]
      end

      def payload
        @payload ||= JSON.parse(params["payload"], symbolize_names: true)
      end
    end
  end
end
