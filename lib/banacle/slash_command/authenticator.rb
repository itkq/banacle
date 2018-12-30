require 'banacle/slash_command/error'

module Banacle
  module SlashCommand
    class Authenticator
      class NotAuthenticatedError < Error; end

      # override to implement the original validation
      def authenticate_requester!(request)
      end
    end
  end
end
