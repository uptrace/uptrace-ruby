# frozen_string_literal: true

module Uptrace
  # Uptrace DSN
  class DSN
    KEYS = %w[scheme host project_id token].freeze

    attr_reader :dsn, :port, *KEYS

    def initialize(dsn)
      raise ArgumentError, "DSN can't be empty" if dsn.empty?

      begin
        uri = URI.parse(dsn)
      rescue URI::InvalidURIError => e
        raise ArgumentError, %(can't parse DSN=#{dsn.inspect}: #{e})
      end

      @dsn = dsn
      @project_id = uri.path.delete_prefix('/')
      @token = uri.user
      @host = uri.host
      @port = uri.port
      @scheme = uri.scheme

      KEYS.each do |k|
        v = public_send(k)
        raise ArgumentError, %(DSN does not have #{k} (DSN=#{dsn.inspect})) if v.nil? || v.empty?
      end
    end

    def to_s
      @dsn
    end
  end
end
