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
        normalize_cidr_blocks!

        Command.new(action: action, region: region, vpc_id: vpc_id, cidr_blocks: cidr_blocks)
      end

      def validate!
        validate_action!
        validate_region!
        validate_vpc_id!
        validate_cidr_blocks!
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

        # TODO: remove aws dependency
        regions = aws.fetch_regions
        unless regions.include?(region)
          raise InvalidRegionError.new("avaliable regions are: (#{regions.join("|")})")
        end
      end

      def validate_vpc_id!
        unless vpc_id
          raise InvalidVpcError.new("vpc_id is required with #{action} action")
        end

        vpcs = aws.fetch_vpcs(region)
        unless vpcs.values.include?(vpc_id)
          raise InvalidVpcError.new("vpc_id: #{vpc_id} not found")
        end
      end

      def validate_cidr_blocks!
        if !cidr_blocks || cidr_blocks.empty?
          raise InvalidVpcError.new("at least one cidr_block is required with #{action} action")
        end

        cidr_blocks.each do |cidr_block|
          begin
            IPAddr.new(cidr_block)
          rescue IPAddr::InvalidAddressError
            raise InvalidCidrBlockError.new("#{cidr_block} is invalid address")
          end
        end
      end

      def normalize_cidr_blocks!
        cidr_blocks.map! do |c|
          ip = IPAddr.new(c)
          "#{ip}/#{ip.prefix}"
        end
      end

      def aws
        @aws = Aws.new
      end
    end
  end
end
