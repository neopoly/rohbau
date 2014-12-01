require 'simplecov-rcov'

SimpleCov.coverage_dir "tmp/coverage"
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter if ENV['CI']
SimpleCov.start do
  add_filter '/spec'
end
