require 'aws-sdk-ec2'

module Banacle
  class Aws
    # TODO: implement cache
    def fetch_regions
      ::Aws::EC2::Client.new.describe_regions.regions.map(&:region_name)
    end

    # TODO: implement cache
    def fetch_vpcs(region)
      ec2(region).describe_vpcs.each.flat_map(&:vpcs).map do |vpc|
        name_tag = vpc.tags.find { |t| t.key == "Name" }
        [
          name_tag.value,
          vpc.vpc_id,
        ]
      end.sort_by { |e| e[0] }.to_h
    end

    def ec2(region)
      @ec2 ||= {}
      @ec2[region] ||= ::Aws::EC2::Client.new(region: region)
    end
  end
end
