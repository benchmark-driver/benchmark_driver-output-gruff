require 'gruff'
require 'benchmark_driver/output/gruff/version'

class BenchmarkDriver::Output::Gruff
  GRAPH_PATH = 'graph.png'

  # @param [BenchmarkDriver::Metrics::Type] metrics_type
  attr_writer :metrics_type

  # @param [Array<BenchmarkDriver::*::Job>] jobs
  # @param [Array<BenchmarkDriver::Config::Executable>] executables
  def initialize(jobs:, executables:)
    @jobs = jobs
    @executables = executables
    @value_by_exec_by_job = Hash.new { |h, k| h[k] = {} }
  end

  def with_warmup(&block)
    # noop
    puts "warming up..."
    block.call
  end

  def with_benchmark(&block)
    @with_benchmark = true
    puts "running benchmark..."
    result = block.call

    print "rendering graph..."
    g = Gruff::SideBar.new
    g.theme = {
      colors: ['#3285e1', '#489d32', '#e2c13e', '#12a702', '#aedaa9'],
      marker_color: '#dddddd',
      font_color: 'black',
      background_colors: 'white'
    }
    g.x_axis_label = @metrics_type.unit
    g.minimum_value = 0
    g.maximum_value = (@value_by_exec_by_job.values.map(&:values).flatten.max * 1.2).to_i
    if @value_by_exec_by_job.keys.size == 1
      # Use Ruby version for base axis
      job = @value_by_exec_by_job.keys.first
      g.labels = Hash[@executables.map.with_index { |exec, index| [index, exec.name] } ]
      g.data job, @executables.map { |exec| @value_by_exec_by_job[job][exec.name] }
    else
      # Use benchmark name for base axis, use different colors for different Ruby versions
      jobs = @value_by_exec_by_job.keys
      g.labels = Hash[jobs.map.with_index { |job, index| [index, job] }]
      @executables.each do |executable|
        g.data executable.name, jobs.map { |job| @value_by_exec_by_job[job][executable.name] }
      end
    end
    g.bar_spacing = 0.6
    g.write(GRAPH_PATH)
    puts ": #{GRAPH_PATH}"

    result
  end

  def with_job(job, &block)
    @job = job
    block.call
  end

  # @param [BenchmarkDriver::Metrics] metrics
  def report(metrics)
    if @with_benchmark
      @value_by_exec_by_job[@job.name][metrics.executable.name] = metrics.value
    end
  end
end
