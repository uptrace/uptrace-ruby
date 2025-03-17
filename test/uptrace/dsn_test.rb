# frozen_string_literal: true

require 'test_helper'

describe Uptrace::DSN do
  DSN = Uptrace::DSN

  let(:dsn) do
    DSN.new(
      'https://TOKEN@api.uptrace.dev'
    )
  end

  it 'is parsed' do
    _(dsn.token).must_equal('TOKEN')

    _(dsn.scheme).must_equal('https')
    _(dsn.host).must_equal('uptrace.dev')
    _(dsn.http_port).must_equal(443)

    _(dsn.to_s).must_equal('https://TOKEN@api.uptrace.dev')
    _(dsn.site_url).must_equal('https://app.uptrace.dev')
    _(dsn.otlp_http_endpoint).must_equal('https://api.uptrace.dev')
  end

  describe '.new' do
    it 'rejects empty string' do
      err = _(proc { DSN.new('') }).must_raise(ArgumentError)
      _(err.message).must_match(/DSN can't be empty/)
    end

    it 'rejects invalid DSN' do
      err = _(proc { DSN.new('_') }).must_raise(ArgumentError)
      _(err.message).must_match(/DSN="_" does not have a scheme/)
    end
  end
end
