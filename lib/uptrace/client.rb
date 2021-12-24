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

    # @param [optional OpenTelemetry::Trace::Span] span
    # @return [String]
    def trace_url(span = nil)
      span = OpenTelemetry::Trace.current_span if span.nil?
      trace_id = span.context.hex_trace_id
      "#{@dsn.app_addr}/traces/#{trace_id}"
    end
  end
end
