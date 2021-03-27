#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

exporter = OpenTelemetry::Exporter::OTLP::Exporter.new(
  endpoint: 'https://otlp.uptrace.dev/v1/traces',
  # Set the Uptrace DSN here or use UPTRACE_DSN env var.
  headers: { 'uptrace-dsn': ENV.fetch('UPTRACE_DSN') },
  compression: 'gzip'
)
span_processor = OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
  exporter,
  max_queue_size: 1000,
  max_export_batch_size: 1000
)

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'myservice'
  c.service_version = '1.0.0'

  c.add_span_processor(span_processor)
end

tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '1.0.0')

tracer.in_span('main') do |span|
  tracer.in_span('child1') do |child1|
    child1.set_attribute('key1', 'value1')
    child1.record_exception(ArgumentError.new('error1'))
  end

  tracer.in_span('child2') do |child2|
    child2.set_attribute('key2', '24')
    child2.set_attribute('key3', 123.456)
  end

  puts("trace id: #{span.context.hex_trace_id}")
end

# Send buffered spans.
span_processor.shutdown
