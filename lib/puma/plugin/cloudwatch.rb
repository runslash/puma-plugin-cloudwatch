require 'puma/plugin'
require 'puma/plugin/cloudwatch/version'

module Puma
  class Plugin
    module Cloudwatch
      class PumaStats
        def initialize(stats)
          @stats = stats
        end

        def clustered?
          @stats.has_key?(:workers)
        end

        def workers
          @stats.fetch(:workers, 1)
        end

        def booted_workers
          @stats.fetch(:booted_workers, 1)
        end

        def running
          if clustered?
            @stats[:worker_status].map { |s| s[:last_status].fetch(:running, 0) }.inject(0, &:+)
          else
            @stats.fetch(:running, 0)
          end
        end

        def backlog
          if clustered?
            @stats[:worker_status].map { |s| s[:last_status].fetch(:backlog, 0) }.inject(0, &:+)
          else
            @stats.fetch(:backlog, 0)
          end
        end

        def pool_capacity
          if clustered?
            @stats[:worker_status].map { |s| s[:last_status].fetch(:pool_capacity, 0) }.inject(0, &:+)
          else
            @stats.fetch(:pool_capacity, 0)
          end
        end

        def max_threads
          if clustered?
            @stats[:worker_status].map { |s| s[:last_status].fetch(:max_threads, 0) }.inject(0, &:+)
          else
            @stats.fetch(:max_threads, 0)
          end
        end
      end
    end
  end
end

Puma::Plugin.create do
  def start(launcher)
    hostname = Socket.gethostname
    cw_client = Aws::CloudWatch::Client.new
    sleep_duration = ENV.fetch('PUMA_CLOUDWATCH_INTERVAL', 60).to_i
    dimensions = [
      { name: 'Host', value: hostname }
    ]
    ENV.fetch('PUMA_CLOUDWATCH_DIMENSIONS', '').split(';').each do |item|
      dim_name, dim_value = item.split('=')
      dimensions.push({ name: dim_name, value: dim_value })
    end

    excluded_metrics = ENV.fetch('PUMA_CLOUDWATCH_EXCLUDE', '').split(',')
    allowed_metrics = [
      'PumaWorkers', 'PumaBootedWorkers', 'PumaBacklog', 'PumaPoolCapacity'
    ].reject do |item|
      excluded_metrics.include?(item.slice(4, item.length - 4))
    end

    dimension_inspect = dimensions.collect do |dim|
      "#{dim[:name]}=#{dim[:value]}"
    end

    in_background do
      launcher.events.log \
        "- CloudWatch plugin enabled, reporting every #{sleep_duration} seconds"
      launcher.events.log \
        "- CloudWatch plugin enabled metrics: #{allowed_metrics.join(', ')}"
      launcher.events.log \
        "- CloudWatch plugin dimensions: #{dimension_inspect.join(', ')}"
      loop do
        sleep(sleep_duration)

        puma_statistics = Puma::Plugin::Cloudwatch::PumaStats.new(
          JSON.parse(Puma.stats, symbolize_names: true)
        )
        cw_params = {
          namespace: ENV.fetch('PUMA_CLOUDWATCH_NAMESPACE', 'puma'),
          metric_data: [
            {
              metric_name: 'PumaWorkers',
              value: puma_statistics.workers,
              unit: 'Count',
              dimensions: dimensions
            },
            {
              metric_name: 'PumaBootedWorkers',
              value: puma_statistics.booted_workers,
              unit: 'Count',
              dimensions: dimensions
            },
            {
              metric_name: 'PumaBacklog',
              value: puma_statistics.backlog,
              unit: 'Count',
              dimensions: dimensions
            },
            {
              metric_name: 'PumaPoolCapacity',
              value: puma_statistics.pool_capacity,
              unit: 'Count',
              dimensions: dimensions
            }
          ].reject do |item|
            !allowed_metrics.include?(item[:metric_name])
          end
        }

        cw_client.put_metric_data(cw_params)
      end
    end
  end
end
