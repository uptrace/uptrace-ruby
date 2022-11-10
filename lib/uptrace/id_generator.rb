# frozen_string_literal: true

module Uptrace
  # Uptrace client that configures OpenTelemetry SDK to use Uptrace exporter.
  module IdGenerator
    extend self

    # Random number generator for generating IDs. This is an object that can
    # respond to `#bytes` and uses the system PRNG. The current logic is
    # compatible with Ruby 2.5 (which does not implement the `Random.bytes`
    # class method) and with Ruby 3.0+ (which deprecates `Random::DEFAULT`).
    # When we drop support for Ruby 2.5, this can simply be replaced with
    # the class `Random`.
    #
    # @return [#bytes]
    RANDOM = Random.respond_to?(:bytes) ? Random : Random::DEFAULT

    # Generates a valid trace identifier, a 16-byte string with at least one
    # non-zero byte.
    #
    # @return [String] a valid trace ID.
    def generate_trace_id
      time = (Time.now.to_f * 1_000_000_000).to_i
      high = [time >> 32, time & 0xFFFFFFFF].pack('NN')
      low = RANDOM.bytes(8)
      high << low
    end

    # Generates a valid span identifier, an 8-byte string with at least one
    # non-zero byte.
    #
    # @return [String] a valid span ID.
    def generate_span_id
      time = (Time.now.to_f * 1000).to_i
      high = [time].pack('N')
      low = RANDOM.bytes(4)
      high << low
    end
  end
end
