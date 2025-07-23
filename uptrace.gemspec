# frozen_string_literal: true

# Copyright 2020 Uptrace Authors
#
# SPDX-License-Identifier: BSD-2-Clause

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uptrace/version'

Gem::Specification.new do |spec|
  spec.name        = 'uptrace'
  spec.version     = Uptrace::VERSION
  spec.authors     = ['Uptrace Authors']
  spec.email       = ['support@uptrace.dev']

  spec.summary     = 'Uptrace wrapper for OpenTelemetry Ruby'
  spec.description = 'Configures OpenTelemetry Ruby to export data to Uptrace'
  spec.homepage    = 'https://github.com/uptrace/uptrace-ruby'
  spec.license     = 'BSD-2-Clause'

  spec.files = Dir.glob('lib/**/*.rb') +
               Dir.glob('*.md') +
               ['LICENSE', '.yardopts']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 3.0'

  spec.add_dependency 'logger', '~> 1.7.0'

  spec.add_dependency 'opentelemetry-sdk', '~> 1.8.0'
  spec.add_dependency 'opentelemetry-exporter-otlp', '~> 0.30.0'

  spec.add_dependency 'opentelemetry-metrics-sdk', '~> 0.7.3'
  spec.add_dependency 'opentelemetry-exporter-otlp-metrics', '~> 0.5.0'

  spec.add_dependency 'opentelemetry-logs-sdk', '~> 0.2.0'
  spec.add_dependency 'opentelemetry-exporter-otlp-logs', '~> 0.2.0'

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.60.2'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.34.5'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yard-doctest', '~> 0.1.6'
  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
