require 'banacle/slash_command/builder'
require 'banacle/slash_command/parser'

module Banacle
  class Cli
    def self.start
      new.start
    end

    def start
      begin
        command = SlashCommand::Parser.parse(ARGV.join(" "))
        puts command.execute
      rescue SlashCommand::Error => e
        $stderr.puts "error: #{e.message}"
        $stderr.puts "help: #{SlashCommand::Parser.help}"
      end
    end
  end
end
