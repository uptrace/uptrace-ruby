# frozen_string_literal: true

require 'logger'

require 'opentelemetry/exporter/otlp'
require 'opentelemetry-metrics-sdk'
require 'opentelemetry-exporter-otlp-metrics'

# Uptrace provides Uptrace exporters for OpenTelemetry.
module Uptrace
  extend self

  attr_accessor :logger
  attr_writer :client

  self.logger = Logger.new($stdout)

  # @return [Object, Client] registered client or a default no-op implementation of the client.
  def client
    @client ||= Client.new
  end

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
    OpenTelemetry::SDK.configure do |c|
      @client = Client.new(dsn: dsn) unless dsn.empty?
      c.add_span_processor(span_processor(@client.dsn)) unless client.disabled?
      c.id_generator = Uptrace::IdGenerator

      yield c if block_given?
    end

    OpenTelemetry.meter_provider.add_metric_reader(metric_exporter(@client.dsn))
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
end

require 'uptrace/version'
require 'uptrace/dsn'
require 'uptrace/client'
require 'uptrace/id_generator'
