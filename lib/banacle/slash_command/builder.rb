require 'banacle/aws'
require 'banacle/slash_command/error'
require 'banacle/slash_command/command'

module Banacle
  module SlashCommand
    class Builder
      ALLOW_ACTION = 'allow'.freeze
      DENY_ACTION = 'deny'.freeze
      LIST_VPC_ACTION = 'listvpc'.freeze

      PERMITTED_ACTIONS = [ALLOW_ACTION, DENY_ACTION, LIST_VPC_ACTION].freeze

      class InvalidActionError < Error; end
      class InvalidRegionError < Error; end
      class InvalidVpcError < Error; end

      def self.build(action:, region:, vpc_id:, cidr_blocks:)
        new(action: action, region: region, vpc_id: vpc_id, cidr_blocks: cidr_blocks).build
      end

      def initialize(action:, region:, vpc_id:, cidr_blocks:)
        @action = action
        @region = region
        @vpc_id = vpc_id
        @cidr_blocks = cidr_blocks
      end

      attr_reader :action, :region, :vpc_id, :cidr_blocks

      def build
        validate!

        if action == LIST_VPC_ACTION
          Command.new(action: action, region: region, vpc_id: nil, cidr_blocks: [])
        else
          Command.new(action: action, region: region, vpc_id: vpc_id, cidr_blocks: cidr_blocks)
        end
      end

      def validate!
        validate_action!
        validate_region!
        validate_vpc_id! if vpc_id
        validate_cidr_blocks! unless cidr_blocks.empty?
      end

      def validate_action!
        if !action || action.empty?
          raise InvalidActionError.new("action is required")
        end

        unless PERMITTED_ACTIONS.include?(action)
          raise InvalidActionError.new("permitted actions are: (#{PERMITTED_ACTIONS.join("|")})")
        end
      end

      def validate_region!
        if !region || region.empty?
          raise InvalidRegionError.new("region is required")
        end

        regions = aws.fetch_regions
        unless regions.include?(region)
          raise InvalidRegionError.new("avaliable regions are: (#{regions.join("|")})")
        end
      end

      def validate_vpc_id!
        vpcs = aws.fetch_vpcs(region)
        unless vpcs.values.include?(vpc_id)
          raise InvalidVpcError.new("vpc_id: #{vpc_id} not found")
        end
      end

      def validate_cidr_blocks!
        # TODO
      end

      def aws
        @aws = Aws.new
      end
    end
  end
end
