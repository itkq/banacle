require 'banacle/slack'

module Banacle
  module InteractiveMessage
    class Renderer
      def self.render(request, command, config)
        new(request, command, config).render
      end

      def self.render_unauthenticated
        self.render_error("you are not authorized to perform this action")
      end

      def self.render_error(error)
        Slack::Response.new(
          response_type: "ephemeral",
          replace_original: false,
          text: "An error occurred: #{error}",
        ).to_json
      end

      def initialize(request, command, config)
        @request = request
        @command = command
        @config = config
      end

      attr_reader :request, :command # TODO

      def render
        action = Slack::Action.new(request.action)

        if action.approved?
          render_approved_message
        elsif action.rejected?
          render_rejected_message
        elsif action.cancelled?
          render_cancelled_message
        else
          # Do nothing
        end
      end

      private

      def render_approved_message
        unless valid_approver?
          return self.render_error("you cannot approve the request by yourself")
        end

        result = command.execute

        text = original_message_text
        text += ":white_check_mark: *<@#{actioner_id}> approved this request*\n"
        text += "Result:\n"
        text += "```\n"
        text += result
        text += "```"

        render_replacing_message(text)
      end

      def render_rejected_message
        unless valid_rejector?
          return self.render_error("you cannot reject the request by yourself")
        end

        text = original_message_text
        text += ":no_entry_sign: *<@#{actioner_id}> rejected this request*"

        render_replacing_message(text)
      end

      def render_cancelled_message
        unless valid_canceller?
          return self.render_error("you cannot cancel the request by other than the requester")
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
        request.self_actioned?
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
