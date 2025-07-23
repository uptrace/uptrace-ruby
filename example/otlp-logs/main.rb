#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'opentelemetry/sdk'
require 'opentelemetry-exporter-otlp'
require 'opentelemetry-logs-sdk'
require 'opentelemetry/exporter/otlp_logs'

# Ensure DSN is set
dsn = ENV.fetch('UPTRACE_DSN', nil)
abort('Missing UPTRACE_DSN environment variable') unless dsn

# Configure OpenTelemetry (for traces, metrics, and logs if desired)
OpenTelemetry::SDK.configure

# Configure log exporter
log_exporter = OpenTelemetry::Exporter::OTLP::Logs::LogsExporter.new(
  endpoint: 'https://api.uptrace.dev/v1/logs',
  headers: { 'uptrace-dsn': dsn },  # Uptrace auth
  compression: 'gzip',              # Reduce bandwidth
  timeout: 10 # Seconds
)

# Attach batch processor (buffers + exports logs)
processor = OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(log_exporter)
OpenTelemetry.logger_provider.add_log_record_processor(processor)

# Ensure we flush logs on shutdown
at_exit { OpenTelemetry.logger_provider.shutdown }

# Create a logger (can be reused globally)
LOGGER = OpenTelemetry.logger_provider.logger(name: 'my_app', version: '1.0.0')

# Helper for structured logging
def log_info(message, attrs = {})
  LOGGER.on_emit(
    timestamp: Time.now.utc,
    severity_text: 'INFO',
    body: message,
    attributes: attrs
  )
end

# Example usage
log_info('Application started', service: 'user-service', region: 'eu-west-1')
log_info('Thuja plicata event', cedar: true)
