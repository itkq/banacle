require 'banacle/aws_wrapper/nacl'
require 'banacle/aws_wrapper/vpc'

module Banacle
  module SlashCommand
    class Command
      CREATE_ACTION = 'create'.freeze
      DELETE_ACTION = 'delete'.freeze
      PERMITTED_ACTIONS = [CREATE_ACTION, DELETE_ACTION].freeze

      CODE_BLOCK_JSON_REGEX = /```([^`]+)```/.freeze

      def self.new_from_original_message(message)
        original_json = JSON.parse(
          message.match(CODE_BLOCK_JSON_REGEX)[1].strip, symbolize_names: true,
        )
        new(**original_json)
      end

      def initialize(action:, region:, vpc_id:, cidr_blocks:)
        @action = action
        @region = region
        @vpc_id = vpc_id
        @cidr_blocks = cidr_blocks
      end

      attr_reader :action, :region, :vpc_id, :cidr_blocks

      def execute
        case action
        when CREATE_ACTION
          create_nacl
        when DELETE_ACTION
          delete_nacl
        else
          # Do nothing
        end
      end

      def to_code_block
        <<-EOS
```
#{JSON.pretty_generate(self.to_h)}
```
        EOS
      end

      def to_h
        {
          action: action,
          region: region,
          vpc_id: vpc_id,
          cidr_blocks: cidr_blocks,
        }
      end

      private

      def command_json_regex
        /```([^`]+)```/.freeze
      end

      def create_nacl
        results = AwsWrapper::Nacl.create_network_acl_ingress_entries(
          region: region,
          vpc_id: vpc_id,
          cidr_blocks: cidr_blocks,
        )

        format_results(results)
      end

      def delete_nacl
        results = AwsWrapper::Nacl.delete_network_acl_entries(
          region: region,
          vpc_id: vpc_id,
          cidr_blocks: cidr_blocks,
        )

        format_results(results)
      end

      def format_results(results)
        results.map do |result|
          t = "#{action} DENY #{result.cidr_block} => "
          if result.status
            t += "succeeded (rule number: #{result.rule_number})"
          else
            t += "error: #{result.error}"
          end
        end.join("\n")
      end
    end
  end
end
