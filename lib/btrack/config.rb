module Btrack
  class Config
    class << self

      attr_writer :namespace

      def namespace
        @namespace ||= "btrack"
      end

    end
  end
end