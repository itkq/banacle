require 'banacle/slash_command/error'
require 'banacle/slash_command/builder'

module Banacle
  module SlashCommand
    class Parser
      class ParseError < Error; end

      def self.parse(text)
        new.parse(text)
      end

      def self.help
        '(create|delete) [region] [vpc_id or vpc_name] [cidr_block1,cidr_block2,...]'
      end

      def parse(text)
        elems = text.split(" ")

        if elems.size > 4
          raise ParseError.new("too many arguments")
        end

        action, region, vpc_id_or_name, cidr_blocks_str = elems

        unless action
          raise ParseError.new("action is required")
        end

        unless region
          raise ParseError.new("region is required")
        end

        cidr_blocks = []
        if cidr_blocks_str
          cidr_blocks = cidr_blocks_str.split(",")
        end

        SlashCommand::Builder.build(
          action: action,
          region: region,
          vpc_id_or_name: vpc_id_or_name,
          cidr_blocks: cidr_blocks,
        )
      end
    end
  end
end
