# frozen_string_literal: true

require 'uptrace/dsn'

module Uptrace
  module Trace
    # Config is a configuration for Uptrace span exporter.
    class Config
      # @return [string] a data source name to connect to uptrace.dev.
      attr_accessor :dsn

      # @return [string] `service.name` resource attribute.
      attr_accessor :service_name

      # @return [string] `service.name` resource attribute.
      attr_accessor :service_version

      # @return [boolean] disables the exporter.
      attr_accessor :disabled

      def initialize
        @dsn = ENV.fetch('UPTRACE_DSN', '')
      end

      def dsno
        @dsno ||= DSN.new(@dsn)
      end
    end
  end
end
