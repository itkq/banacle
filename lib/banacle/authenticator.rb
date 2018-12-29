module Banacle
  class Authenticator
    def self.authenticate(request)
      new(request).authenticate
    end

    def initialize(request)
      @request = request
    end

    attr_reader :request

    # override
    def authenticate
    end
  end
end
