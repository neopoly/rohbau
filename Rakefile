require 'bundler/gem_tasks'
require "rake/testtask"

Rake::TestTask.new(:spec) do |t|
  t.libs += ['spec', 'lib']
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task :default => :spec
