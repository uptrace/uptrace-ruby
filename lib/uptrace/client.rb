# frozen_string_literal: true

require 'opentelemetry/sdk'

module Uptrace
  # Uptrace client that configures OpenTelemetry SDK to use Uptrace exporter.
  class Client
    attr_reader :dsn

    # @param [string] dsn
    def initialize(dsn: '')
      dsn = ENV.fetch('UPTRACE_DSN', '') if dsn.empty? || dsn == '<FIXME>'

      begin
        @dsn = DSN.new(dsn)
      rescue ArgumentError => e
        Uptrace.logger.error("Uptrace is disabled: #{e.message}")
        @disabled = true

        @dsn = DSN.new('https://project_secret@api.uptrace.dev?grpc=4317')
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
      span_id = span.context.hex_span_id
      "#{@dsn.site_url}/traces/#{trace_id}?span_id=#{span_id}"
    end
  end
end
