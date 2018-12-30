module Banacle
  module InteractiveMessage
    class Authenticator
      class Error < StandardError; end
      class NotAuthenticatedError < Error; end

      # override to implement your own validation
      def authenticate_approver!(request)
        if request.self_actioned?
          raise NotAuthenticatedError.new("you cannot approve the request by yourself")
        end
      end

      # override to implement your own validation
      def authenticate_rejector!(request)
        if request.self_actioned?
          raise NotAuthenticatedError.new("you cannot reject the request by yourself")
        end
      end

      # override to implement your own validation
      def authenticate_canceller!(request)
        unless request.self_actioned?
          raise NotAuthenticatedError.new("you cannot cancel the request by other than the requester")
        end
      end

    end
  end
end
