#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'uptrace'

# Create Uptrace client which configures OpenTemetry SDK to export spans to Uptrace.

_client = Uptrace::Client.new do |c|
  # copy your project DSN here or use UPTRACE_DSN env var
  # c.dsn = ''
  c.service_name = 'myservice'
  c.service_version = '1.0.0'
end

# Create a tracer.

tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '0.1.0')

# Start a span and set some attributes.

tracer.in_span('main') do |span|
  span.set_attribute('key1', 'value1')
  span.set_attribute('key1', 123.456)

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

# Active span logic.
puts('------------------------------------------------------------')

tracer.in_span('main') do |main|
  raise ArgumentError, 'not reached' unless OpenTelemetry::Trace.current_span == main

  puts('main is active')

  tracer.in_span('main') do |child|
    raise ArgumentError, 'not reached' unless OpenTelemetry::Trace.current_span == child

    puts('child is active')
  end

  raise ArgumentError, 'not reached' unless OpenTelemetry::Trace.current_span == main

  puts('main is active again')
end

# Start a span and activate it manually. Don't forget to finish the span.
puts('------------------------------------------------------------')

main = tracer.start_span(
  'main',
  kind: OpenTelemetry::Trace::SpanKind::SERVER,
  attributes: {
    foo: 'bar'
  }
)

OpenTelemetry::Trace.with_span(main) do |span|
  puts(span == main)
end

main.finish
