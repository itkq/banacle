module Banacle
  module SlashCommand
    class Command
      ALLOW_ACTION = 'allow'.freeze
      DENY_ACTION = 'deny'.freeze
      LIST_VPC_ACTION = 'listvpc'.freeze

      PERMITTED_ACTIONS = [ALLOW_ACTION, DENY_ACTION, LIST_VPC_ACTION].freeze

      def initialize(action:, region:, vpc_id:, cidr_blocks:)
        @action = action
        @region = region
        @vpc_id = vpc_id
        @cidr_blocks = cidr_blocks
      end

      attr_reader :action, :region, :vpc_id, :cidr_blocks

      def to_h
        {
          action: action,
          region: region,
          vpc_id: vpc_id,
          cidr_blocks: cidr_blocks,
        }
      end
    end
  end
end
