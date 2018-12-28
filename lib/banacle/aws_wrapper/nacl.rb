require 'aws-sdk-ec2'
require 'banacle/aws_wrapper/error'
require 'banacle/aws_wrapper/result'

module Banacle
  module AwsWrapper
    class Nacl
      class EntryDuplicatedError < AwsWrapper::Error; end
      class EntryNotFoundError < AwsWrapper::Error; end

      def self.create_network_acl_ingress_entries(region:, vpc_id:, cidr_blocks:)
        new(region, vpc_id, cidr_blocks).create_network_acl_ingress_entries
      end

      def self.delete_network_acl_entries(region:, vpc_id:, cidr_blocks:)
        new(region, vpc_id, cidr_blocks).delete_network_acl_entries
      end

      def initialize(region, vpc_id, cidr_blocks)
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

      def delete_network_acl_entries
        cidr_blocks.map do |cidr_block|
          result = begin
                     delete_network_acl_entry(cidr_block)
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

        duplicated_rule = ingress_rules.select { |e|
          e.cidr_block == cidr_block
        }.first

        if duplicated_rule
          raise EntryDuplicatedError.new("entry already exists (rule_number: #{duplicated_rule.rule_number})")
        end

        next_min_rule_number = nil
        (0..ingress_rule_numbers.size - 1).each do |i|
          if ingress_rule_numbers[i + 1] - ingress_rule_numbers[i] > 1
            next_min_rule_number = ingress_rule_numbers[i] + 1
            break
          end
        end
        next_min_rule_number = 100 unless next_min_rule_number

        ec2.create_network_acl_entry(
          cidr_block: cidr_block,
          egress: false,
          network_acl_id: network_acl_id,
          protocol: "-1", # all protocols
          rule_action: "deny",
          rule_number: next_min_rule_number,
        )
      end

      def delete_network_acl_entry(cidr_block)
        target = ingress_rules.select { |e| !e.egress && e.cidr_block == cidr_block }.first
        if target
          ec2.delete_network_acl_entry(
            egress: false,
            network_acl_id: network_acl_id,
            rule_number: target.rule_number,
          )
        else
          raise EntryDuplicatedError.new("not found")
        end
      end

      def network_acl_id
        acl.network_acl_id
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
