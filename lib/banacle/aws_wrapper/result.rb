module Banacle
  module AwsWrapper
    Result = Struct.new(:status, :error, keyword_init: true) do
    end
  end
end
