#!/usr/bin/env ruby
# frozen_string_literal: true

# This example demonstrates how to configure OpenTelemetry to send traces to Uptrace.
# Docs: https://uptrace.dev/get/opentelemetry-ruby

require 'bundler/setup'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry-propagator-xray'
require 'opentelemetry/instrumentation/all'

# Fetch Uptrace DSN from environment (required)
dsn = ENV['UPTRACE_DSN']
abort('Missing UPTRACE_DSN environment variable') unless dsn

puts "Using Uptrace DSN: #{dsn}"

# Configure OTLP exporter to send data to Uptrace
exporter = OpenTelemetry::Exporter::OTLP::Exporter.new(
  endpoint: 'https://api.uptrace.dev/v1/traces',
  headers: { 'uptrace-dsn': dsn }, # Uptrace authentication
  compression: 'gzip'
)

# Use a batch span processor for better performance
span_processor = OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
  exporter,
  max_queue_size: 1000,
  max_export_batch_size: 512 # smaller batch size helps avoid large payloads
)

# Configure the global OpenTelemetry SDK
OpenTelemetry::SDK.configure do |c|
  c.service_name = 'myservice'         # Customize your service name
  c.service_version = '1.0.0'          # Optional: version for observability
  c.id_generator = OpenTelemetry::Propagator::XRay::IDGenerator # Optional: AWS X-Ray style IDs

  c.add_span_processor(span_processor)

  c.use_all
end

# Get a tracer for your app
tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '1.0.0')

# Create a sample trace
tracer.in_span('main-operation') do |span|
  puts "Trace ID: #{span.context.hex_trace_id}"
end

# Ensure all spans are flushed before exiting
OpenTelemetry.tracer_provider.shutdown
