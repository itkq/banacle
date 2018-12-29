require 'sinatra/base'
require 'sinatra/reloader'
require 'banacle/handler'

module Banacle
  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    post '/slack/command' do
      content_type :json
      Handler.handle_slash_command(request)
    end

    post '/slack/message' do
      content_type :json
      Handler.handle_interactive_message(request)
    end
  end
end
