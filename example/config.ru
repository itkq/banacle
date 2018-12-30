require 'banacle'
require 'banacle/slash_command/handler'
require 'banacle/interactive_message/handler'

class CommandAuthenticator < Banacle::SlashCommand::Authenticator
  def authenticate_requester!(request)
    super
    if request.user_id != "U0XXXXXXX"
      raise NotAuthenticatedError.new("you are not authorized to perform this command")
    end
  end
end

config = Banacle::Config.new(
  slack_signing_secret: ENV.fetch('BANACLE_SLACK_SIGNING_SECRET'),
  slash_command: {
    authenticator: CommandAuthenticator.new,
  },
  approval_request: {
    attachment: {
      text: "*Approval Request* (can be approved by only SRE members except the requester)",
    },
  },
)

run Banacle.app(config)
