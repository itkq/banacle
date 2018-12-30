module Banacle
  class Config
    def initialize(hash)
      @hash = hash
    end

    def [](k)
      @hash[k]
    end

    def fetch(*args)
      @hash.fetch(*args)
    end

    def dig(*args)
      @hash.dig(*args)
    end
  end
end
