desc 'Run examples'
task :examples do
  examples = FileList['examples/**/*.rb'].exclude('examples/**/*_spec.rb')
  examples.each do |example|
    puts example
    system %{ruby -Ilib:examples #{example} 2>&1}
    puts
  end
end

desc 'Verify examples'
Rake::TestTask.new('examples:verify') do |t|
  t.libs << 'lib'
  t.test_files = FileList['examples/verify/*_spec.rb']
  t.verbose = true
end
