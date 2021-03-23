# frozen_string_literal: true

require 'opentelemetry/sdk'

module Uptrace
  # Uptrace client that configures OpenTelemetry SDK to use Uptrace exporter.
  class Client
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

      host = @dsn.host.delete_prefix('api.')
      trace_id = span.context.hex_trace_id
      "#{@dsn.scheme}://#{host}/search/#{@dsn.project_id}?q=#{trace_id}"
    end

    # @return [OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor]
    def span_processor
      exp = Uptrace::Trace::Exporter.new(@dsn)
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
        exp,
        max_queue_size: 1000,
        max_export_batch_size: 1000,
        schedule_delay: 5_000
      )
    end
  end
end
