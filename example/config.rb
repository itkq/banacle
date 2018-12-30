require 'banacle/config'

module Banacle
  def self.config
    Config.new(
      approval_request: {
        attachment: {
          text: "*Approval Request* (can be approved by only SRE members except the requester)",
        },
      },
    )
  end
end
