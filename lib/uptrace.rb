# frozen_string_literal: true

require 'logger'

require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

require 'opentelemetry-metrics-sdk'
require 'opentelemetry-exporter-otlp-metrics'

require 'opentelemetry-logs-sdk'
require 'opentelemetry/exporter/otlp_logs'

# Uptrace provides Uptrace exporters for OpenTelemetry.
module Uptrace
  extend self

  attr_accessor :logger

  self.logger = Logger.new($stdout)

  # @param [optional OpenTelemetry::Trace::Span] span
  # @return [String]
  def trace_url(span = nil)
    @client.trace_url(span)
  end

  # ConfigureOpentelemetry configures OpenTelemetry to export data to Uptrace.
  # Specifically it configures and registers Uptrace span exporter.
  #
  # @param [optional String] dsn
  # @yieldparam [OpenTelemetry::SDK::Configurator] c Yields a configurator to the
  #   provided block
  def configure_opentelemetry(dsn: '')
    @client = Client.new(dsn: dsn)
    return if @client.disabled?

    OpenTelemetry::SDK.configure do |c|
      # Set default IdGenerator and let users override
      c.id_generator = Uptrace::IdGenerator
      c.add_span_processor(span_processor(@client.dsn))

      yield c if block_given?

      # Merge resource
      current_resource = c.instance_variable_get(:@resource)
      current_resource ||= OpenTelemetry::SDK::Resources::Resource.create

      host_resource = OpenTelemetry::SDK::Resources::Resource.create(
        'host.name' => Socket.gethostname,
      )
      c.resource = current_resource.merge(host_resource)
    end

    me = metric_exporter(@client.dsn)
    OpenTelemetry.meter_provider.add_metric_reader(me)

    le = log_exporter(@client.dsn)
    processor = OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(le)
    OpenTelemetry.logger_provider.add_log_record_processor(processor)
  end

  private

  def span_processor(dsn)
    exporter = OpenTelemetry::Exporter::OTLP::Exporter.new(
      endpoint: "#{dsn.otlp_http_endpoint}/v1/traces",
      headers: { 'uptrace-dsn': dsn.to_s },
      compression: 'gzip'
    )
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      exporter,
      max_queue_size: 1000,
      max_export_batch_size: 1000,
      schedule_delay: 5_000
    )
  end

  def metric_exporter(dsn)
    OpenTelemetry::Exporter::OTLP::Metrics::MetricsExporter.new(
      endpoint: "#{dsn.otlp_http_endpoint}/v1/metrics",
      headers: { 'uptrace-dsn': dsn.to_s },
      compression: 'gzip'
    )
  end

  def log_exporter(dsn)
    OpenTelemetry::Exporter::OTLP::Logs::LogsExporter.new(
      endpoint: "#{dsn.otlp_http_endpoint}/v1/logs",
      headers: { 'uptrace-dsn': dsn.to_s },
      compression: 'gzip'
    )
  end
end

require 'uptrace/version'
require 'uptrace/dsn'
require 'uptrace/client'
require 'uptrace/id_generator'
