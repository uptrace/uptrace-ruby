#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'opentelemetry/sdk'
require 'opentelemetry-metrics-sdk'
require 'opentelemetry-metrics-api'
require 'opentelemetry-exporter-otlp-metrics'

dsn = ENV.fetch('UPTRACE_DSN')
puts("using dsn: #{dsn}")

OpenTelemetry::SDK.configure

metric_exporter = OpenTelemetry::Exporter::OTLP::Metrics::MetricsExporter.new(
  endpoint: 'https://api.uptrace.dev/v1/metrics',
  # Set the Uptrace DSN here or use UPTRACE_DSN env var.
  headers: { 'uptrace-dsn': dsn },
  compression: 'gzip'
)
metric_reader = OpenTelemetry::SDK::Metrics::Export::PeriodicMetricReader.new(
  exporter: metric_exporter,
  export_interval_millis: 5000,
  export_timeout_millis: 10_000
)
OpenTelemetry.meter_provider.add_metric_reader(metric_reader)

meter = OpenTelemetry.meter_provider.meter('SAMPLE_METER_NAME')

histogram = meter.create_histogram('histogram', unit: 'smidgen', description: 'desscription')
loop do
  histogram.record(123, attributes: { 'foo' => 'bar' })
  sleep 1
end

OpenTelemetry.meter_provider.shutdown
