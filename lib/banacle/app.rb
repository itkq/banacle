require 'sinatra/base'
require 'sinatra/reloader'
require 'banacle/slash_command/handler'
require 'banacle/interactive_message/handler'

module Banacle
  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    helpers do
      def command_handler
        @command_handler ||= SlashCommand::Handler.new
      end

      def message_handler
        @message_handler ||= InteractiveMessage::Handler.new
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
end
