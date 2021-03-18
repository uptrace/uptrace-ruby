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

  def trace_url(span)
    client.trace_url(span)
  end

  def configure_tracing(c, dsn: '')
    upclient = if dsn.empty?
                 client
               else
                 Client.new(dsn: dsn)
               end

    c.add_span_processor(upclient.span_processor) unless upclient.disabled?
  end
end

require 'uptrace/version'
require 'uptrace/dsn'
require 'uptrace/client'
require 'uptrace/trace'
