#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

require 'opentelemetry-metrics-sdk'
require 'opentelemetry-exporter-otlp-metrics'

# Fetch Uptrace DSN from environment (required)
dsn = ENV['UPTRACE_DSN']
abort('Missing UPTRACE_DSN environment variable') unless dsn

puts "Using Uptrace DSN: #{dsn}"

# Configure the OTLP metrics exporter
metric_exporter = OpenTelemetry::Exporter::OTLP::Metrics::MetricsExporter.new(
  endpoint: 'https://api.uptrace.dev/v1/metrics',
  headers: { 'uptrace-dsn': dsn }, # Uptrace authentication
  compression: 'gzip'
)

# Periodic reader pushes metrics every 5 seconds
metric_reader = OpenTelemetry::SDK::Metrics::Export::PeriodicMetricReader.new(
  exporter: metric_exporter,
  export_interval_millis: 5_000,
  export_timeout_millis: 10_000
)

# Initialize the SDK with the custom metric reader
OpenTelemetry::SDK.configure do |c|
  c.add_metric_reader(metric_reader)
end

# Obtain a Meter instance
meter = OpenTelemetry.meter_provider.meter('example-meter')

# Create a histogram instrument
histogram = meter.create_histogram(
  'example_histogram',
  unit: 'items',
  description: 'Example histogram metric'
)

trap('INT') do
  puts "\nShutting down..."
  OpenTelemetry.meter_provider.shutdown
  exit
end

# Record some metric values periodically
loop do
  value = rand(100..200)
  puts "Recording histogram value: #{value}"
  histogram.record(value, attributes: { 'env' => 'dev', 'feature' => 'demo' })
  sleep 1
end
