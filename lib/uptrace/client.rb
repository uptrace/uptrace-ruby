# frozen_string_literal: true

require 'opentelemetry/sdk'

module Uptrace
  # Uptrace client that configures OpenTelemetry SDK to use Uptrace exporter.
  class Client
    attr_reader :dsn

    # @param [string] dsn
    def initialize(dsn: '')
      dsn = ENV.fetch('UPTRACE_DSN', '') if dsn.empty?

      begin
        @dsn = DSN.new(dsn)
      rescue ArgumentError => e
        Uptrace.logger.error("Uptrace is disabled: #{e.message}")
        @disabled = true

        @dsn = DSN.new('https://TOKEN@api.uptrace.dev/PROJECT_ID')
      end
    end

    def disabled?
      @disabled
    end
  end
end
