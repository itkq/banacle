require 'aws-sdk-ec2'
require 'banacle/aws_wrapper/error'

module Banacle
  module AwsWrapper
    class Vpc
      class InvalidRegionError < AwsWrapper::Error; end

      def self.resolve_vpc_id(region, vpc_id_or_name)
        new(region, vpc_id_or_name).resolve_vpc_id
      end

      def initialize(region, vpc_id_or_name)
        @region = region
        @vpc_id_or_name = vpc_id_or_name
      end

      attr_reader :region, :vpc_id_or_name

      def resolve_vpc_id
        begin
          vpc_list = ec2.describe_vpcs.each.flat_map(&:vpcs).map do |vpc|
            name_tag = vpc.tags.find { |t| t.key == "Name" }
            [
              name_tag.value,
              vpc.vpc_id,
            ]
          end.sort_by { |e| e[0] }.to_h
        rescue Aws::Errors::NoSuchEndpointError
          raise InvalidRegionError.new("region: #{region} is invalid")
        end

        vpc_id = nil
        if vpc_list.values.include?(vpc_id_or_name)
          vpc_id = vpc_id_or_name
        else
          vpc_id = vpc_list[vpc_id_or_name]
        end

        vpc_id
      end

      private

      def ec2
        @ec2 ||= ::Aws::EC2::Client.new(region: region)
      end
    end
  end
end
