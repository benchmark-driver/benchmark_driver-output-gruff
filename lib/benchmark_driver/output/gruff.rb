require 'gruff'
require 'benchmark_driver'

class BenchmarkDriver::Output::Gruff < BenchmarkDriver::BulkOutput
  GRAPH_PATH = 'graph.png'

  # @param [Array<BenchmarkDriver::Metric>] metrics
  # @param [Array<BenchmarkDriver::Job>] jobs
  # @param [Array<BenchmarkDriver::Context>] contexts
  def initialize(contexts:, **)
    super
    @contexts = contexts
  end

  # @param [Hash{ BenchmarkDriver::Job => Hash{ BenchmarkDriver::Context => { BenchmarkDriver::Metric => Float } } }] result
  # @param [Array<BenchmarkDriver::Metric>] metrics
  def bulk_output(job_context_result:, metrics:)
    print "rendering graph..."
    g = Gruff::SideBar.new
    g.theme = {
      colors: ['#3285e1', '#e2c13e', '#489d32', '#12a702', '#aedaa9', '#6886B4', '#D1695E', '#8A6EAF', '#EFAA43'],
      marker_color: '#dddddd',
      font_color: 'black',
      background_colors: 'white'
    }
    metric = metrics.first # only one metric is supported for now
    g.x_axis_label = metric.unit
    g.legend_font_size = 10.0
    g.marker_font_size = 14.0
    g.minimum_value = 0
    results = job_context_result.values.map(&:values).flatten
    g.maximum_value = (results.map(&:values).map(&:values).flatten.max * 1.2).to_i
    if job_context_result.keys.size == 1
      # Use Ruby version for base axis
      job = job_context_result.keys.first
      g.labels = Hash[job_context_result[job].keys.map.with_index { |context, index| [index, context.name] }]
      g.data job.name, job_context_result[job].values.map { |result| result.values.fetch(metric) }
    else
      # Use benchmark name for base axis, use different colors for different Ruby versions
      jobs = job_context_result.keys
      g.labels = Hash[jobs.map.with_index { |job, index| [index, job.name] }]
      @contexts.each do |context|
        g.data context.executable.description, jobs.map { |job|
          job_context_result[job][context].values.fetch(metric)
        }
      end
    end
    g.bar_spacing = 0.6
    g.write(GRAPH_PATH)
    puts ": #{GRAPH_PATH}"
  end

  def with_job(job, &block)
    puts "* #{job.name}..."
    super
  end

  def with_context(context, &block)
    puts "  * #{context.name}..."
    super
  end
end
