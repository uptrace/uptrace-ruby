# frozen_string_literal: true

require 'uri'

require 'msgpack'
require 'lz4-ruby'

module Uptrace
  module Trace
    # @!visibility private
    ExpoSpan = Struct.new(
      :id,
      :parentId,
      :name,
      :kind,
      :startTime,
      :endTime,
      :statusCode,
      :statusMessage,
      :attrs,
      :events,
      :links,
      :resource
    )

    # Exporter is a span exporter for OpenTelemetry.
    class Exporter
      ##
      # @param [Config] cfg
      #
      def initialize(cfg)
        @cfg = cfg

        begin
          @uri = URI.parse(cfg.dsn)
        rescue URI::InvalidURIError => e
          @disabled = true
          Uptrace.logger.error("can't parse dsn=#{cfg.dsn}: #{e}")
        else
          @endpoint = "#{@uri.scheme}://#{@uri.host}/api/v1/tracing#{@uri.path}/spans"
        end
      end

      def export(spans)
        return if @disabled

        traces = {}

        spans.each do |span|
          trace = traces[span.trace_id]

          if trace.nil?
            trace = []
            traces[span.trace_id] = trace
          end

          expose = expo_span(span)
          trace.push(expose)
        end
      end

      private

      def send(traces)
        req = build_request(traces: traces)
        connection.request(req)
      end

      ##
      # @return [ExpoSpan]
      #
      def expo_span(span)
        expose = ExpoSpan.new

        expose.id = span.id
        expose.parentId = span.parent_span_id

        expose.name = span.name
        expose.kind = span.kind
        expose.startTime = span.start_timestamp.to_i
        expose.endTime = span.end_timestamp.to_i
        expose.statusCode = span.status.canonical_code
        expose.statusMessage = span.status.description
        expose.attrs = span.attributes

        expose
      end

      ##
      # @return [Net::HTTP]
      #
      def connection
        unless @conn
          @conn = Net::HTTP.new(@uri.host, @uri.port)
          @conn.use_ssl = @uri.is_a?(URI::HTTPS)
          @conn.open_timeout = 5
          @conn.read_timeout = 5
          @conn.keep_alive_timeout = 30
        end

        @conn
      end

      ##
      # @param [Hash] data
      # @return [Net::HTTP::Post]
      #
      def build_request(data)
        data = data.to_msgpack
        data = LZ4.compress data

        req = Net::HTTP::Post.new(@endpoint)
        req['Authorization'] = @uri.user
        req['Content-Type'] = 'application/msgpack'
        req['Content-Encoding'] = 'lz4'
        req['Connection'] = 'keep-alive'
        req.body = data

        req
      end
    end
  end
end
