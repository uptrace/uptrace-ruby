#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'uptrace'

# Configure OpenTelemetry with sensible defaults.
# DSN can be set via UPTRACE_DSN environment variable.
# Example: export UPTRACE_DSN="https://<project_secret>@uptrace.dev?grpc=4317"
Uptrace.configure_opentelemetry(dsn: '') do |c|
  # c is an instance of OpenTelemetry::SDK::Configurator

  # Configure service metadata (helps identify this service in Uptrace).
  c.service_name = 'myservice'
  c.service_version = '1.0.0'

  # Add environment information
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    'deployment.environment.name' => ENV.fetch('RACK_ENV', 'development'),
  )
end

# Ensure spans are flushed even if the program exits unexpectedly.
at_exit { OpenTelemetry.tracer_provider.shutdown }

# Register a tracer (usually stored globally).
TRACER = OpenTelemetry.tracer_provider.tracer('my_app', '0.1.0')

# Example trace with nested spans.
TRACER.in_span('main-operation', kind: :server) do |main_span|
  # Simulate an HTTP request span.
  TRACER.in_span('GET /posts/:id', kind: :client) do |http_span|
    http_span.set_attribute('http.method', 'GET')
    http_span.set_attribute('http.route', '/posts/:id')
    http_span.set_attribute('http.url', 'http://localhost:8080/posts/123')
    http_span.set_attribute('http.status_code', 200)
    http_span.record_exception(ArgumentError.new('Invalid parameter'))
  end

  # Simulate a database query span.
  TRACER.in_span('SELECT posts', kind: :client) do |db_span|
    db_span.set_attribute('db.system', 'mysql')
    db_span.set_attribute('db.statement', 'SELECT * FROM posts LIMIT 100')
  end

  # Print the trace URL (clickable in console).
  puts "Trace URL: #{Uptrace.trace_url(main_span)}"
end
