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

      begin
        @cfg.dsno
      rescue ArgumentError => e
        Uptrace.logger.error(e.message)
        @cfg.disabled = true

        @cfg.dsn = 'https://TOKEN@api.uptrace.dev/PROJECT_ID'
      end

      setup_tracing
    end

    # @param [optional Numeric] timeout An optional timeout in seconds.
    def shutdown(timeout: nil)
      OpenTelemetry.tracer_provider.shutdown(timeout: timeout)
    end

    # @return [OpenTelemetry::Trace::Span]
    def trace_url(span)
      dsn = @cfg.dsno
      host = dsn.host.delete_prefix('api.')
      trace_id = span.context.hex_trace_id
      "#{dsn.scheme}://#{host}/#{dsn.project_id}/search?q=#{trace_id}"
    end

    private

    def setup_tracing
      exp = Uptrace::Trace::Exporter.new(@cfg)

      OpenTelemetry::SDK.configure do |c|
        bsp = OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(exporter: exp, max_queue_size: 1000, max_export_batch_size: 1000, schedule_delay: 5_000)
        c.add_span_processor(bsp)

        c.service_name = @cfg.service_name
        c.service_version = @cfg.service_version
      end
    end
  end
end
