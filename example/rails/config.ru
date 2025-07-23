# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'rubygems'
require 'bundler/setup'
require 'rails'
require 'action_controller/railtie'
require 'opentelemetry-instrumentation-rails'
require 'uptrace'

# copy your project DSN here or use UPTRACE_DSN env var
Uptrace.configure_opentelemetry(dsn: '') do |c|
  c.use_all

  c.service_name = 'myservice'
  c.service_version = '1.0.0'
end

# TraceRequestApp is a minimal Rails application
class TraceRequestApp < Rails::Application
  config.root = __dir__
  config.secret_key_base = 'secret_key_base'
  config.eager_load = false

  config.logger = Logger.new($stdout)
  Rails.logger = config.logger

  # Tell Rails we don't use a standard config/routes.rb
  config.paths['config/routes.rb'] = []
end

# ExampleController
class ExampleController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    trace_url = Uptrace.trace_url
    render inline: <<~HTML
      <html>
        <p>Here are some routes for you:</p>
        <ul>
          <li><%= link_to 'Hello world', hello_path(username: 'world') %></li>
          <li><%= link_to 'Hello foo-bar', hello_path(username: 'foo-bar') %></li>
        </ul>
        <p>View trace: <a href="#{trace_url}" target="_blank">#{trace_url}</a></p>
      </html>
    HTML
  end

  def hello
    trace_url = Uptrace.trace_url
    render inline: <<~HTML
      <html>
        <h3>Hello #{params[:username]}</h3>
        <p>View trace: <a href="#{trace_url}" target="_blank">#{trace_url}</a></p>
      </html>
    HTML
  end
end

# Initialize Rails
Rails.application.initialize!

# Draw routes AFTER initialization so Rails doesn’t override them
Rails.application.routes.draw do
  get '/', to: 'example#index'
  get '/hello/:username', to: 'example#hello', as: 'hello'
end

run Rails.application
