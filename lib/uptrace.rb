# frozen_string_literal: true

require 'logger'

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
  # Specifically it configures and registers Uptrace span exporter.
  #
  # @param [optional String] dsn
  # @yieldparam [OpenTelemetry::SDK::Configurator] c Yields a configurator to the
  #   provided block
  def configure_opentelemetry(dsn: '')
    OpenTelemetry::SDK.configure do |c|
      @client = Client.new(dsn: dsn) unless dsn.empty?
      c.add_span_processor(client.span_processor) unless client.disabled?

      yield c if block_given?
    end
  end
end

require 'uptrace/version'
require 'uptrace/dsn'
require 'uptrace/client'
require 'uptrace/trace'
