# frozen_string_literal: true

require 'test_helper'

describe Uptrace::Trace::Exporter do
  let(:exporter) do
    cfg = Uptrace::Trace::Config.new
    cfg.dsn = 'https://TOKEN@api.uptrace.dev/PROJECT_ID'
    Uptrace::Trace::Exporter.new(cfg)
  end

  describe '#export' do
    it 'exists' do
      _(exporter).must_respond_to :export
    end
  end
end
