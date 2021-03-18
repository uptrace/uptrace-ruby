# frozen_string_literal: true

require 'opentelemetry/sdk'

module Uptrace
  # Uptrace client that configures OpenTelemetry SDK to use Uptrace exporter.
  class Client
    ##
    # @yieldparam config [Uptrace::Config]
    # @return [void]
    #
    def initialize
      @cfg = Uptrace::Trace::Config.new
      yield @cfg if block_given?

      @cfg.dsn = ENV.fetch('UPTRACE_DSN', '') if @cfg.dsn.nil? || @cfg.dsn.empty?

      begin
        @cfg.dsno
      rescue ArgumentError => e
        Uptrace.logger.error("Uptrace is disabled: #{e.message}")
        @cfg.disabled = true

        @cfg.dsn = 'https://TOKEN@api.uptrace.dev/PROJECT_ID'
      end
    end

    # @param [optional Numeric] timeout An optional timeout in seconds.
    def close(timeout: nil)
      return if @cfg.disabled

      OpenTelemetry.tracer_provider.shutdown(timeout: timeout)
    end

    # @return [OpenTelemetry::Trace::Span]
    def trace_url(span)
      dsn = @cfg.dsno
      host = dsn.host.delete_prefix('api.')
      trace_id = span.context.hex_trace_id
      "#{dsn.scheme}://#{host}/search/#{dsn.project_id}?q=#{trace_id}"
    end

    def span_processor
      exp = Uptrace::Trace::Exporter.new(@cfg)
      OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
        exp,
        max_queue_size: 1000,
        max_export_batch_size: 1000,
        schedule_delay: 5_000
      )
    end
  end
end
