require 'banacle/aws'
require 'banacle/aws_wrapper/nacl'

module Banacle
  module SlashCommand
    class Command
      CREATE_ACTION = 'create'.freeze
      DELETE_ACTION = 'delete'.freeze
      LIST_VPC_ACTION = 'listvpc'.freeze

      PERMITTED_ACTIONS = [CREATE_ACTION, DELETE_ACTION, LIST_VPC_ACTION].freeze

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
        when LIST_VPC_ACTION
          execute_list_vpc_action
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

        results.map do |cidr_block, result|
          t = "DENY #{cidr_block} => "
          if result.status
            t += "#{action} succeeded"
          else
            t += result.error.to_s
          end
        end.join("\n")
      end

      def delete_nacl
        results = AwsWrapper::Nacl.delete_network_acl_entries(
          region: region,
          vpc_id: vpc_id,
          cidr_blocks: cidr_blocks,
        )

        results.map do |cidr_block, result|
          t = "DENY #{cidr_block} => "
          if result.status
            t += "#{action} succeeded"
          else
            t += result.error.to_s
          end
        end.join("\n")
      end

      def execute_nacl_operation
        results = AwsWrapper::Nacl.create_network_acl_ingress_entries(
          action: action,
          region: region,
          vpc_id: vpc_id,
          cidr_blocks: cidr_blocks,
        )

        results.map do |cidr_block, result|
          t = "#{cidr_block} => "
          if result.status
            t += "#{action} succeeded"
          else
            t += result.error.to_s
          end
        end.join("\n")
      end

      def execute_list_vpc_action
        aws.fetch_vpcs(region)
      end

      def aws
        @aws = Aws.new
      end
    end
  end
end
