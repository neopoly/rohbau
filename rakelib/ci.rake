run_on_ci = [:spec]
run_on_ci << 'examples:verify' unless defined?(JRUBY_VERSION)

desc 'Run tests etc. on CI'
task :ci => run_on_ci
