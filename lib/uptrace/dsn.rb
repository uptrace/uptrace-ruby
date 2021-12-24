# frozen_string_literal: true

module Uptrace
  # Uptrace DSN
  class DSN
    attr_reader :dsn, :scheme, :host, :port, :project_id, :token

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
      @port = uri.port
      @project_id = uri.path.delete_prefix('/')
      @token = uri.user

      %w[scheme host].each do |k|
        v = public_send(k)
        raise ArgumentError, %(DSN=#{dsn.inspect} does not have a #{k}) if v.nil? || v.empty?
      end

      @host = 'uptrace.dev' if @host == 'api.uptrace.dev'
      return if @host != 'uptrace.dev'

      %w[project_id token].each do |k|
        v = public_send(k)
        raise ArgumentError, %(DSN=#{dsn.inspect} does not have a #{k}) if v.nil? || v.empty?
      end
    end

    def to_s
      @dsn
    end

    def app_addr
      return 'https://app.uptrace.dev' if @host == 'uptrace.dev'

      "#{@scheme}://#{@host}:#{@port}"
    end

    def otlp_addr
      return 'https://otlp.uptrace.dev' if @host == 'uptrace.dev'

      "#{@scheme}://#{@host}:#{@port}"
    end
  end
end
