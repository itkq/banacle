require 'ipaddr'

require 'banacle/aws'
require 'banacle/slash_command/error'
require 'banacle/slash_command/command'

module Banacle
  module SlashCommand
    class Builder
      class InvalidActionError < Error; end
      class InvalidRegionError < Error; end
      class InvalidVpcError < Error; end
      class InvalidCidrBlockError < Error; end

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

        if action == Command::LIST_VPC_ACTION
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

        if action == Command::ALLOW_ACTION || action == Command::DENY_ACTION
          validate_critical_operation!
        end
      end

      def validate_action!
        if !action || action.empty?
          raise InvalidActionError.new("action is required")
        end

        unless Command::PERMITTED_ACTIONS.include?(action)
          raise InvalidActionError.new("permitted actions are: (#{Command::PERMITTED_ACTIONS.join("|")})")
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
        cidr_blocks.each do |cidr_block|
          begin
            IPAddr.new(cidr_block)
          rescue IPAddr::InvalidAddressError
            raise InvalidCidrBlockError.new("#{cidr_block} is invalid address")
          end
        end
      end

      def validate_critical_operation!
        unless vpc_id
          raise InvalidVpcError.new("vpc_id is required with #{action} action")
        end

        if cidr_blocks.empty?
          raise InvalidVpcError.new("at least one cidr_block is required with #{action} action")
        end
      end

      def aws
        @aws = Aws.new
      end
    end
  end
end
