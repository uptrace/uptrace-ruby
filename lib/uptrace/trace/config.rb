# frozen_string_literal: true

module Uptrace
  module Trace
    # Config is a configuration for Uptrace span exporter.
    class Config
      # @return [String] a data source name to connect to uptrace.dev.
      # @api public
      attr_accessor :dsn
    end
  end
end
