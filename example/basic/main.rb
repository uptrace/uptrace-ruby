#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'uptrace'

# Configure OpenTelemetry with sensible defaults.
# Copy your project DSN here or use UPTRACE_DSN env var.
Uptrace.configure_opentelemetry(dsn: '') do |c|
  # c is OpenTelemetry::SDK::Configurator
  c.service_name = 'myservice'
  c.service_version = '1.0.0'

  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    'deployment.environment' => 'production'
  )
end

# Create a tracer. Usually, tracer is a global variable.
tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '0.1.0')

# Create a root span (a trace) to measure some operation.
tracer.in_span('main-operation', kind: :client) do |main|
  tracer.in_span('GET /posts/:id') do |child1|
    child1.set_attribute('http.method', 'GET')
    child1.set_attribute('http.route', '/posts/:id')
    child1.set_attribute('http.url', 'http://localhost:8080/posts/123')
    child1.set_attribute('http.status_code', 200)
    child1.record_exception(ArgumentError.new('error1'))
  end

  tracer.in_span('SELECT') do |child2|
    child2.set_attribute('db.system', 'mysql')
    child2.set_attribute('db.statement', 'SELECT * FROM posts LIMIT 100')
  end

  puts("trace URL: #{Uptrace.trace_url(main)}")
end

# Send buffered spans and free resources.
OpenTelemetry.tracer_provider.shutdown
