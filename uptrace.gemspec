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

  spec.summary     = 'Uptrace Ruby exporter for OpenTelemetry'
  spec.description = 'Uptrace Ruby exporter for OpenTelemetry'
  spec.homepage    = 'https://github.com/uptrace/uptrace-ruby'
  spec.license     = 'BSD-2-Clause'

  spec.files = ::Dir.glob('lib/**/*.rb') +
               ::Dir.glob('*.md') +
               ['LICENSE', '.yardopts']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'msgpack', '~> 1.4.2'
  spec.add_dependency 'opentelemetry-sdk', '~> 0.17.0'
  spec.add_dependency 'zstd-ruby', '~> 1.4.9.0'

  spec.add_development_dependency 'bundler', '~> 2.1.4'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '~> 1.10.0'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.10.2'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5.1'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yard-doctest', '~> 0.1.6'
end
