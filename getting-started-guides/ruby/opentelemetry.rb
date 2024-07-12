# frozen_string_literal: true

require 'opentelemetry/sdk'
require 'opentelemetry-metrics-sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/exporter/otlp_metrics'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  # c.use_all() # enables all instrumentation!
  c.use 'OpenTelemetry::Instrumentation::Sinatra'
  c.use 'OpenTelemetry::Instrumentation::Rack'
  c.use 'OpenTelemetry::Instrumentation::Net::HTTP'
end

ENV['OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE'] = 'delta'
ENV['OTEL_METRICS_EXPORTER'] = 'console'
ENV['OTEL_TRACES_EXPORTER'] = 'console'
ENV['OTEL_SERVICE_NAME'] = 'fibonacci-metrics-test'
ENV['OTEL_EXPORTER_OTLP_ENDPOINT'] = 'https://staging-otlp.nr-data.net'
ENV['OTEL_EXPORTER_OTLP_HEADERS'] = "api-key=#{ENV['NEW_RELIC_STAGING_KEY']}"

APP_TRACER = OpenTelemetry.tracer_provider.tracer('AppTracer')

OTLP_METRICS_EXPORTER = OpenTelemetry::Exporter::OTLP::MetricsExporter.new
OpenTelemetry.meter_provider.add_metric_reader(OTLP_METRICS_EXPORTER)
APP_METER = OpenTelemetry.meter_provider.meter('AppMeter')

histogram = APP_METER.create_histogram('http.server.request.duration', unit: 's', description: 'Duration of HTTP server requests.')

OpenTelemetry.meter_provider.add_view('http.server.request.duration', aggregation: OpenTelemetry::SDK::Metrics::Aggregation::ExplicitBucketHistogram.new(boundaries: [0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1, 2.5, 5, 7.5, 10]))

histogram_2 = APP_METER.create_histogram('test', unit: 's', description: 'smiles')

OpenTelemetry.meter_provider.add_view('test', aggregation: OpenTelemetry::SDK::Metrics::Aggregation::ExplicitBucketHistogram.new(boundaries: [1, 2, 3, 4, 5]))
OpenTelemetry.meter_provider.add_view('test', aggregation: OpenTelemetry::SDK::Metrics::Aggregation::ExplicitBucketHistogram.new(boundaries: [0.5, 1, 1.5, 2, 2.5]))

histogram_2.record(2)
histogram_2.record(2)
histogram_2.record(1)

histogram.record(0.005, attributes: {'http.request.method' => 'GET', 'http.route' => '/users'})
histogram.record(0.1, attributes: {'http.request.method' => 'POST', 'http.route' => '/users'})
histogram.record(0.006, attributes: {'http.request.method' => 'GET', 'http.route' => '/users'})

OpenTelemetry.meter_provider.metric_readers.each(&:pull)
OpenTelemetry.meter_provider.shutdown
