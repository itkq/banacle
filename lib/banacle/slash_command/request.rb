module Banacle
  module SlashCommand
    class Request
      def initialize(request)
        @request = request
      end

      attr_reader :request

      def user_id
        params["user_id"]
      end

      def text
        params["text"]
      end

      def params
        request.params
      end
    end
  end
end
