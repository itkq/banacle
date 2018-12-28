require 'aws-sdk-ec2'
require 'banacle/aws_wrapper/error'
require 'banacle/aws_wrapper/result'

module Banacle
  module AwsWrapper
    class Nacl
      class EntryDuplicatedError < AwsWrapper::Error; end

      def self.create_network_acl_ingress_entries(action:, region:, vpc_id:, cidr_blocks:)
        new(action, region, vpc_id, cidr_blocks).create_network_acl_ingress_entries
      end

      def initialize(action, region, vpc_id, cidr_blocks)
        @action = action
        @region = region
        @vpc_id = vpc_id
        @cidr_blocks = cidr_blocks
      end

      attr_reader :action, :region, :vpc_id, :cidr_blocks
      attr_accessor :current_rule_number

      def create_network_acl_ingress_entries
        cidr_blocks.map do |cidr_block|
          result = begin
                     create_network_acl_ingress_entry(cidr_block)
                     AwsWrapper::Result.new(status: true)
                   rescue AwsWrapper::Error => e
                     AwsWrapper::Result.new(status: false, error: e)
                   end
          [cidr_block, result]
        end.to_h
      end

      private

      def create_network_acl_ingress_entry(cidr_block)
        ingress_rule_numbers = ingress_rules.map(&:rule_number)

        p ingress_rules

        duplicated_rule = ingress_rules.select { |e|
          e.cidr_block == cidr_block
        }.first
        p duplicated_rule

        if duplicated_rule
          raise EntryDuplicatedError.new("entry already exists (#{duplicated_rule.rule_number}: #{action} #{cidr_block})")
        end

        network_acl_id = acl.network_acl_id

        next_min_rule_number = nil
        (0..ingress_rule_numbers.size - 1).each do |i|
          if ingress_rule_numbers[i + 1] - ingress_rule_numbers[i] > 1
            next_min_rule_number = ingress_rule_numbers[i] + 1
            break
          end
        end
        next_min_rule_number = 1 unless next_min_rule_number

        arg_entry = {
          cidr_block: cidr_block,
          egress: false,
          network_acl_id: network_acl_id,
          protocol: "-1", # all protocols
          rule_action: action,
          rule_number: next_min_rule_number,
        }

        ec2.create_network_acl_entry(arg_entry)
      end

      def ingress_rules
        @ingress_rules ||= acl.entries.select { |e| !e.egress }
      end

      def acl
        @acl ||= ec2.describe_network_acls(
          filters: [
            { name: 'vpc-id', values: [vpc_id] },
          ],
        ).network_acls.first
      end

      def ec2
        @ec2 ||= ::Aws::EC2::Client.new(region: region)
      end
    end
  end
end
