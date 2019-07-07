require 'ipaddr'

require 'banacle/aws_wrapper/vpc'
require 'banacle/slash_command/error'
require 'banacle/slash_command/command'

module Banacle
  module SlashCommand
    class Builder
      class InvalidActionError < Error; end
      class InvalidRegionError < Error; end
      class InvalidVpcError < Error; end
      class InvalidCidrBlockError < Error; end

      def self.build(action:, region:, vpc_id_or_name:, cidr_blocks:)
        new(action: action, region: region, vpc_id_or_name: vpc_id_or_name, cidr_blocks: cidr_blocks).build
      end

      def initialize(action:, region:, vpc_id_or_name:, cidr_blocks:)
        @action = action
        @region = region
        @vpc_id_or_name = vpc_id_or_name
        @cidr_blocks = cidr_blocks
      end

      attr_reader :action, :region, :vpc_id_or_name, :cidr_blocks
      attr_accessor :vpc_id

      def build
        validate!
        set_vpc_id!
        normalize_cidr_blocks!

        Command.new(action: action, region: region, vpc_id: vpc_id, cidr_blocks: cidr_blocks)
      end

      def validate!
        validate_action!
        validate_region!
        validate_vpc_id_or_name!

        if Command::CHANGE_ACTIONS.include?(action)
          validate_cidr_blocks!
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
      end

      def validate_vpc_id_or_name!
        unless vpc_id_or_name
          raise InvalidVpcError.new("vpc_id or vpc_name is required with #{action} action")
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

      def set_vpc_id!
        begin
          self.vpc_id = AwsWrapper::Vpc.resolve_vpc_id(region, vpc_id_or_name)
        rescue AwsWrapper::Vpc::InvalidRegionError
          raise InvalidRegionError.new("specified region: #{region} is invalid")
        end

        unless vpc_id
          raise InvalidVpcError.new("specified vpc: #{vpc_id_or_name} in #{region} not found")
        end
      end

      def normalize_cidr_blocks!
        cidr_blocks.map! do |c|
          ip = IPAddr.new(c)
          "#{ip}/#{ip.prefix}"
        end
      end
    end
  end
end
