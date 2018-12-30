require 'sinatra/base'
require 'banacle/config'
require 'banacle/slash_command/handler'
require 'banacle/interactive_message/handler'

module Banacle
  def self.app(*args)
    App.rack(*args)
  end

  class App < Sinatra::Base
    CONTEXT_RACK_ENV_NAME = 'banacle.ctx'

    def self.rack(config={})
      klass = App

      context = initialize_context(config)
      lambda { |env|
        env[CONTEXT_RACK_ENV_NAME] = context
        klass.call(env)
      }
    end

    def self.initialize_context(config)
      {
        config: config,
      }
    end

    helpers do
      def context
        request.env[CONTEXT_RACK_ENV_NAME]
      end

      def config
        context[:config]
      end

      def command_handler
        @command_handler ||= SlashCommand::Handler.new(config)
      end

      def message_handler
        @message_handler ||= InteractiveMessage::Handler.new(config)
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
