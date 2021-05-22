# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

require 'opentelemetry/sdk'
require 'msgpack'
require 'zstd-ruby'

module Uptrace
  module Trace
    # Exporter is a span exporter for OpenTelemetry.
    class Exporter
      SUCCESS = OpenTelemetry::SDK::Trace::Export::SUCCESS
      FAILURE = OpenTelemetry::SDK::Trace::Export::FAILURE
      TIMEOUT = OpenTelemetry::SDK::Trace::Export::TIMEOUT
      private_constant(:SUCCESS, :FAILURE, :TIMEOUT)

      ##
      # @param [Config] cfg
      #
      def initialize(dsn)
        @dsn = dsn
        @endpoint = "/api/v1/tracing/#{@dsn.project_id}/spans"

        @http = Net::HTTP.new(@dsn.host, 443)
        @http.use_ssl = true
        @http.open_timeout = 5
        @http.read_timeout = 5
        @http.keep_alive_timeout = 30
      end

      # Called to export sampled {OpenTelemetry::SDK::Trace::SpanData} structs.
      #
      # @param [Enumerable<OpenTelemetry::SDK::Trace::SpanData>] spans the
      #   list of recorded {OpenTelemetry::SDK::Trace::SpanData} structs to be
      #   exported.
      # @param [optional Numeric] timeout An optional timeout in seconds.
      # @return [Integer] the result of the export.
      def export(spans, timeout: nil)
        return SUCCESS if @disabled
        return FAILURE if @shutdown

        out = []

        spans.each do |span|
          out.push(uptrace_span(span))
        end

        send({ spans: out }, timeout: timeout)
      end

      # Called when {OpenTelemetry::SDK::Trace::TracerProvider#force_flush} is called, if
      # this exporter is registered to a {OpenTelemetry::SDK::Trace::TracerProvider}
      # object.
      #
      # @param [optional Numeric] timeout An optional timeout in seconds.
      def force_flush(timeout: nil) # rubocop:disable Lint/UnusedMethodArgument
        SUCCESS
      end

      # Called when {OpenTelemetry::SDK::Trace::Tracer#shutdown} is called, if
      # this exporter is registered to a {OpenTelemetry::SDK::Trace::Tracer}
      # object.
      #
      # @param [optional Numeric] timeout An optional timeout in seconds.
      def shutdown(timeout: nil) # rubocop:disable Lint/UnusedMethodArgument
        @shutdown = true
        @http.finish if @http.started?
        SUCCESS
      end

      private

      ##
      # @return [hash]
      #
      def uptrace_span(span)
        out = {
          id: span.span_id.unpack1('Q'),
          traceId: span.trace_id,

          name: span.name,
          kind: kind_as_str(span.kind),
          startTime: span.start_timestamp,
          endTime: span.end_timestamp,

          resource: uptrace_resource(span.resource),
          attrs: span.attributes
        }

        out[:parentId] = span.parent_span_id.unpack1('Q') if span.parent_span_id

        out[:events] = uptrace_events(span.events) unless span.events.nil?
        out[:links] = uptrace_links(span.links) unless span.links.nil?

        status = span.status
        out[:statusCode] = status_code_as_str(status.code)
        out[:statusMessage] = status.description unless status.description.empty?

        il = span.instrumentation_library
        out[:tracerName] = il.name
        out[:tracerVersion] = il.name unless il.version.empty?

        out
      end

      def send(data, timeout: nil) # rubocop:disable Lint/UnusedMethodArgument
        req = build_request(data)

        begin
          resp = @http.request(req)
        rescue Net::OpenTimeout, Net::ReadTimeout
          return FAILURE
        end

        case resp
        when Net::HTTPOK
          resp.body # Read and discard body
          SUCCESS
        when Net::HTTPBadRequest
          data = JSON.parse(resp.body)
          Uptrace.logger.error("status=#{data['status']}: #{data['message']}")
          FAILURE
        when Net::HTTPInternalServerError
          resp.body
          FAILURE
        else
          @http.finish
          FAILURE
        end
      end

      ##
      # @param [Hash] data
      # @return [Net::HTTP::Post]
      #
      def build_request(data)
        data = MessagePack.pack(data)
        data = Zstd.compress(data, 3)

        req = Net::HTTP::Post.new(@endpoint)
        req.add_field('Authorization', "Bearer #{@dsn.token}")
        req.add_field('Content-Type', 'application/msgpack')
        req.add_field('Content-Encoding', 'zstd')
        req.add_field('Connection', 'keep-alive')
        req.body = data

        req
      end

      # @param [SpanKind] kind
      # @return [String]
      def kind_as_str(kind)
        case kind
        when OpenTelemetry::Trace::SpanKind::SERVER
          'server'
        when OpenTelemetry::Trace::SpanKind::CLIENT
          'client'
        when OpenTelemetry::Trace::SpanKind::PRODUCER
          'producer'
        when OpenTelemetry::Trace::SpanKind::CONSUMER
          'consumer'
        else
          'internal'
        end
      end

      ##
      # @param [Integer] code
      # @return [String]
      #
      def status_code_as_str(code)
        case code
        when OpenTelemetry::Trace::Status::OK
          'ok'
        when OpenTelemetry::Trace::Status::ERROR
          'error'
        else
          'unset'
        end
      end

      ##
      # @param [OpenTelemetry::SDK::Resources::Resource] resource
      # @return [Hash]
      #
      def uptrace_resource(resource)
        out = {}
        resource.attribute_enumerator.map { |key, value| out[key] = value }
        out
      end

      def uptrace_events(events)
        out = []
        events.each do |event|
          out.push(
            {
              name: event.name,
              attrs: event.attributes,
              time: event.timestamp
            }
          )
        end
        out
      end

      def uptrace_links(links)
        out = []
        links.each do |link|
          out.push(
            {
              trace_id => link.span_context.trace_id,
              span_id => link.span_context.span_id.unpack1('Q'),
              attrs => link.attributes
            }
          )
        end
        out
      end
    end
  end
end
