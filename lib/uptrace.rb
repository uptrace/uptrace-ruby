# frozen_string_literal: true

require 'logger'
require 'opentelemetry'

# Uptrace provides Uptrace exporters for OpenTelemetry.
module Uptrace
  extend self

  attr_accessor :logger
  attr_writer :client

  self.logger = Logger.new($stdout)

  # @return [Object, Client] registered client or a default no-op implementation of the client.
  def client
    @client ||= Client.new
  end

  # @param [optional OpenTelemetry::Trace::Span] span
  # @return [String]
  def trace_url(span = nil)
    client.trace_url(span)
  end

  # ConfigureOpentelemetry configures OpenTelemetry to export data to Uptrace.
  # By default it:
  #   - creates tracer provider;
  #   - registers Uptrace span exporter;
  #   - sets tracecontext + baggage composite context propagator.
  #
  # @param [OpenTelemetry::SDK::Configurator] c
  def configure_opentelemetry(c, dsn: '')
    @client = Client.new(dsn: dsn) unless dsn.empty?

    c.add_span_processor(client.span_processor) unless client.disabled?

    if OpenTelemetry.propagation.nil?
      c.injectors = [
        OpenTelemetry::Trace::Propagation::TraceContext.text_map_injector,
        OpenTelemetry::Baggage::Propagation.text_map_injector
      ]
      c.extractors = [
        OpenTelemetry::Trace::Propagation::TraceContext.text_map_extractor,
        OpenTelemetry::Baggage::Propagation.text_map_extractor
      ]
    end
  end
end

require 'uptrace/version'
require 'uptrace/dsn'
require 'uptrace/client'
require 'uptrace/trace'
