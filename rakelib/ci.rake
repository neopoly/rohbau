desc 'Run tests etc. on CI'
task :ci => [:spec, 'examples:verify']
