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
    'deployment.environment.name' => ENV.fetch('RACK_ENV', 'development'),
  )
end

# Ensure logs are flushed even if the program exits unexpectedly.
at_exit { OpenTelemetry.logger_provider.shutdown }

# Obtain a logger from the OpenTelemetry logger provider.
logger = OpenTelemetry.logger_provider.logger(name: 'my_app_or_gem', version: '0.1.0')

# Emit a simple info log.
logger.on_emit(
  timestamp: Time.now,
  severity_text: 'INFO',

  body: 'Processing user request for Thuja plicata.',
  attributes: {
    'user.id' => 123,
    'operation' => 'fetch_data',
    'plant_type' => 'cedar',
    'is_evergreen' => true
  },
)

# Emit a warning log with different attributes.
logger.on_emit(
  timestamp: Time.now,
  severity_text: 'WARN',
  severity_number: OpenTelemetry::Logs::SeverityNumber::SEVERITY_NUMBER_WARN,
  body: 'Database connection is slow.',
  attributes: {
    'component' => 'database',
    'latency_ms' => 500,
  },
)

# Emit an error log.
begin
  raise StandardError, "Failed to write to disk"
rescue => e
  logger.on_emit(
    timestamp: Time.now,
    severity_text: 'ERROR',
    severity_number: OpenTelemetry::Logs::SeverityNumber::SEVERITY_NUMBER_ERROR,
    body: "An error occurred: #{e.message}",
    attributes: {
      'exception.type' => e.class.name,
      'exception.message' => e.message,
      'exception.stacktrace' => e.backtrace.join("\n"),
    },
  )
end
