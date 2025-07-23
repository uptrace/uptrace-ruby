#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'uptrace'

# Configure OpenTelemetry with sensible defaults.
# Copy your project DSN here or use UPTRACE_DSN env var.
Uptrace.configure_opentelemetry(dsn: '') do |c|
  # c is an instance of OpenTelemetry::SDK::Configurator

  # Set your service metadata
  c.service_name = 'myservice'
  c.service_version = '1.0.0'

  # Add environment information
  c.resource = OpenTelemetry::SDK::Resources::Resource.create(
    'deployment.environment.name' => ENV.fetch('RACK_ENV', 'development')
  )
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
