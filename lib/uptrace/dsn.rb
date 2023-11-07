# frozen_string_literal: true

module Uptrace
  # Uptrace DSN
  class DSN
    attr_reader :dsn, :scheme, :host, :http_port, :token

    def initialize(dsn)
      raise ArgumentError, "DSN can't be empty" if dsn.empty?

      begin
        uri = URI.parse(dsn)
      rescue URI::InvalidURIError => e
        raise ArgumentError, %(can't parse DSN=#{dsn.inspect}: #{e})
      end

      @dsn = dsn
      @scheme = uri.scheme
      @host = uri.host
      @http_port = uri.port
      @token = uri.user

      %w[scheme host].each do |k|
        v = public_send(k)
        raise ArgumentError, %(DSN=#{dsn.inspect} does not have a #{k}) if v.nil? || v.empty?
      end

      @host = 'uptrace.dev' if @host == 'api.uptrace.dev'
    end

    def to_s
      @dsn
    end

    def site_url
      return 'https://app.uptrace.dev' if @host == 'uptrace.dev'
      return "#{@scheme}://#{@host}:#{@http_port}" if @http_port != 443

      "#{@scheme}://#{@host}"
    end

    def otlp_http_endpoint
      return 'https://otlp.uptrace.dev' if @host == 'uptrace.dev'
      return "#{@scheme}://#{@host}:#{@http_port}" if @http_port != 443

      "#{@scheme}://#{@host}"
    end
  end
end
