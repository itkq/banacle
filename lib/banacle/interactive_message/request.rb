module Banacle
  module InteractiveMessage
    class Request
      REQUESTER_ID_REGEX = /\A<@([^>]+)>/.freeze

      def initialize(request)
        @request = request
      end

      attr_reader :request

      def action
        Slack::Action.new(payload["actions"].first)
      end

      def self_actioned?
        requester_id == actioner_id
      end

      def requester_id
        original_message_text.match(REQUESTER_ID_REGEX)[1]
      end

      def actioner_id
        payload["user"]["id"]
      end

      def original_message_text
        payload["original_message"]["text"]
      end

      def payload
        @payload ||= JSON.parse(request.params["payload"])
      end
    end
  end
end
