# frozen_string_literal: true

require 'test_helper'

describe Uptrace::DSN do
  DSN = Uptrace::DSN

  let(:dsn) do
    DSN.new(
      'https://TOKEN@api.uptrace.dev/PROJECT_ID'
    )
  end

  it 'is parsed' do
    _(dsn.project_id).must_equal('PROJECT_ID')
    _(dsn.token).must_equal('TOKEN')

    _(dsn.scheme).must_equal('https')
    _(dsn.host).must_equal('uptrace.dev')
    _(dsn.port).must_equal(443)

    _(dsn.to_s).must_equal('https://TOKEN@api.uptrace.dev/PROJECT_ID')
    _(dsn.app_addr).must_equal('https://app.uptrace.dev')
    _(dsn.otlp_addr).must_equal('https://otlp.uptrace.dev')
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

    it 'rejects DSN without a token' do
      err = _(proc { DSN.new('https://api.uptrace.dev/PROJECT_ID') }).must_raise(ArgumentError)
      _(err.message).must_match(%r{DSN="https://api.uptrace.dev/PROJECT_ID" does not have a token})
    end
  end
end
