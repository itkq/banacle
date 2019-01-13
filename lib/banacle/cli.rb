require 'banacle/slash_command/builder'
require 'banacle/slash_command/parser'

module Banacle
  class Cli
    SLASH_ACTION = 'slash'.freeze
    INTERACTIVE_ACTION = 'interactive'.freeze
    HELP_ACTION = 'help'.freeze
    EXIT_ACTION = 'exit'.freeze

    def self.start
      new.start
    end

    def initialize
      @store = MemoryStore.new
    end

    def start
      main_loop
    end

    def main_loop
      loop do
        print '> '
        input = STDIN.gets.chomp
        args = input.split(" ")

        case args.first
        when SLASH_ACTION
          handle_slash_action(args[1..-1].join(" "))
        when INTERACTIVE_ACTION
          handle_interactive_action(args[1..-1].join(" "))
        when EXIT_ACTION
          exit 0
        when HELP_ACTION
          print_help
        else
          print_help
        end
      end
    end

    def print_help
      puts <<-EOS
  #{SLASH_ACTION} #{SlashCommand::Parser.help}
    execute slash command
  #{INTERACTIVE_ACTION} key
    approve slash command
  #{HELP_ACTION}
    print help
      EOS
    end

    def handle_slash_action(input)
      execute_slash_command(input)
    end

    def execute_slash_command(input)
      begin
        command = SlashCommand::Parser.parse(input)
        i = @store.put(command)
        puts "stored (key=#{i}, command=#{command.to_h})"
      rescue SlashCommand::Error => e
        puts e.message
      end
    end

    def handle_interactive_action(input)
      k = input.split(" ").first.to_i
      command = @store.get(k)
      unless command
        puts "key=#{k} not found"
        return
      end
      execute_interactive_message(command)
    end

    def execute_interactive_message(command)
      puts command.execute
    end

    class MemoryStore
      def initialize
        @store = {}
        @max_key = 0
      end

      def get(k)
        @store[k]
      end

      def put(v)
        put_with_key(k: nil, v: v)
      end

      def put_with_key(k:, v:)
        if k
          @store[k] = v
          k
        else
          k = @max_key
          @store[k] = v
          @max_key += 1
          k
        end
      end

      def delete(k)
        @store.delete(k)
      end
    end
  end
end
