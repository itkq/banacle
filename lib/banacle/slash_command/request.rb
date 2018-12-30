module Banacle
  module SlashCommand
    class Request
      def initialize(request)
        @request = request
      end

      attr_reader :request

      def user_id
        request.params["user_id"]
      end

      def text
        request.params["text"]
      end
    end
  end
end
