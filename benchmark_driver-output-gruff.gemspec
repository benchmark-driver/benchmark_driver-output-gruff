
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "benchmark_driver/output/gruff/version"

Gem::Specification.new do |spec|
  spec.name          = "benchmark_driver-output-gruff"
  spec.version       = BenchmarkDriver::Output::Gruff::VERSION
  spec.authors       = ["Takashi Kokubun"]
  spec.email         = ["takashikkbn@gmail.com"]

  spec.summary       = %q{Show graph on benchmark_driver using gruff.gem}
  spec.description   = %q{Show graph on benchmark_driver using gruff.gem}
  spec.homepage      = "https://github.com/benchmark-driver/benchmark_driver-output-gruff"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "benchmark_driver", ">= 0.10.12"
  spec.add_dependency "gruff"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
