# frozen_string_literal: true

require 'test_helper'

describe Uptrace::Trace::Exporter do
  let(:exporter) do
    dsn = Uptrace::DSN.new('https://TOKEN@api.uptrace.dev/PROJECT_ID')
    Uptrace::Trace::Exporter.new(dsn)
  end

  describe '#export' do
    it 'exists' do
      _(exporter).must_respond_to :export
    end
  end
end
