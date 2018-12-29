require 'sinatra/base'
require 'banacle/authenticator'
require 'banacle/slash_command/handler'
require 'banacle/interactive_message/handler'

class App < Sinatra::Base
  include Banacle

  helpers do
    def command_handler
      @command_handler ||= SlashCommand::Handler.new.tap do |h|
        h.set_authenticator!(CommandAuthenticator.new)
        h
      end
    end

    def message_handler
      @message_handler ||= InteractiveMessage::Handler.new.tap do |h|
        h.set_authenticator!(MessageAuthenticator.new)
        h
      end
    end
  end

  post '/slack/command' do
    content_type :json
    command_handler.handle(request)
  end

  post '/slack/message' do
    content_type :json
    message_handler.handle(request)
  end
end

class CommandAuthenticator < Banacle::Authenticator
  def authenticate(request)
    params = request.params

    team_id = params["team_id"]
    # user_id = params["user_id"]

    if team_id != "T0XXXXXXX"
      return false
    end

    true
  end
end

class MessageAuthenticator < Banacle::Authenticator
  attr_reader :request
  def authenticate(request)
    payload = JSON.parse(request.params["payload"])
    # team_id = payload["team"]["id"]
    # user_id = payload["user"]["id"]

    true
  end
end

run App
