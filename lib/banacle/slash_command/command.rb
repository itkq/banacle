require 'banacle/aws_wrapper/nacl'
require 'banacle/aws_wrapper/vpc'

module Banacle
  module SlashCommand
    class Command
      CREATE_ACTION = 'create'.freeze
      DELETE_ACTION = 'delete'.freeze

      PERMITTED_ACTIONS = [CREATE_ACTION, DELETE_ACTION].freeze

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

      def to_h
        {
          action: action,
          region: region,
          vpc_id: vpc_id,
          cidr_blocks: cidr_blocks,
        }
      end

      private

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
