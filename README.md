# BenchmarkDriver::Output::Gruff

benchmark\_driver plugin to render graph using gruff.gem.

## Installation

Install rmagick.gem's dependency. See also: https://github.com/rmagick/rmagick

```bash
# macOS
brew install imagemagick@6
PKG_CONFIG_PATH=/usr/local/opt/imagemagick@6/lib/pkgconfig gem install rmagick

# Ubuntu
sudo apt-get install libmagickwand-dev
```

And install the following gem.

```ruby
gem 'benchmark_driver-output-gruff'
```

## Usage

Specify `-o gruff`/`--output gruff`. Then `graph.png` will be created.

```
bundle exec benchmark-driver examples/multi.yml -o gruff --rbenv '2.4.2;2.5.0'
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
