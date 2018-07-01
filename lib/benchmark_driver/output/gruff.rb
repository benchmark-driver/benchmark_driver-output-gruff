require 'gruff'
require 'benchmark_driver'

class BenchmarkDriver::Output::Gruff < BenchmarkDriver::BulkOutput
  GRAPH_PATH = 'graph.png'

  # @param [Array<String>] job_names
  # @param [Array<String>] context_names
  def initialize(job_names:, context_names:)
    @context_names = context_names
  end

  # @param [Hash{ BenchmarkDriver::Job => Hash{ BenchmarkDriver::Context => { BenchmarkDriver::Metric => Float } } }] result
  # @param [Array<BenchmarkDriver::Metric>] metrics
  def bulk_output(result:, metrics:)
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
    g.maximum_value = (result.values.map(&:values).flatten.map(&:values).flatten.max * 1.2).to_i
    if result.keys.size == 1
      # Use Ruby version for base axis
      job = result.keys.first
      g.labels = Hash[result[job].keys.map.with_index { |context, index| [index, context.name] } ]
      g.data job.name, result[job].map { |_, metric_value| metric_value[metric] }
    else
      # Use benchmark name for base axis, use different colors for different Ruby versions
      jobs = result.keys
      g.labels = Hash[jobs.map.with_index { |job, index| [index, job.name] }]
      @context_names.each do |context_name|
        context = @result[jobs.first].keys.find { |c| c.name == context_name }
        g.data context.executable.description, jobs.map { |job|
          _, metric_value = @result[job].find { |context, _| context.name == context_name }
          metric_value[metric]
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
