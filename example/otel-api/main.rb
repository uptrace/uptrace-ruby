#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'uptrace'

# Create Uptrace client which configures OpenTemetry SDK to export spans to Uptrace.

upclient = Uptrace::Client.new do |c|
  # copy your project DSN here or use UPTRACE_DSN env var
  # c.dsn = ''
end

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'myservice'
  c.service_version = '1.0.0'

  c.add_span_processor(upclient.span_processor)
end

tracer = OpenTelemetry.tracer_provider.tracer('app_or_gem_name', '0.1.0')

# Start a span and set some attributes.

tracer.in_span('main', kind: OpenTelemetry::Trace::SpanKind::SERVER) do |span|
  # Conditionally record some expensive data.
  if span.recording?
    span.set_attribute('key1', 'value1')
    span.set_attribute('key2', 123.456)

    span.add_event(
      name: 'log',
      attributes: {
        'log.severity': 'error',
        'log.message': 'User not found',
        'enduser.id': '123'
      }
    )

    span.record_exception(ArgumentError.new('error1'))

    span.status = OpenTelemetry::Trace::Status.new(
      OpenTelemetry::Trace::Status::ERROR,
      description: 'error description'
    )
  end
end

# Current span logic.

tracer.in_span('main') do |main|
  puts('main is active') if OpenTelemetry::Trace.current_span == main

  tracer.in_span('child') do |child|
    puts('child is active') if OpenTelemetry::Trace.current_span == child
  end

  puts('main is active again') if OpenTelemetry::Trace.current_span == main
end

# Start a span and activate it manually. Don't forget to finish the span.

main = tracer.start_span(
  'main',
  kind: OpenTelemetry::Trace::SpanKind::CLIENT,
  attributes: {
    'foo' => 'bar'
  }
)

OpenTelemetry::Trace.with_span(main) do |span|
  puts('main is active (manually)') if OpenTelemetry::Trace.current_span == span
end

main.finish
