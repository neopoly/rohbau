desc "Run examples"
task :examples do
  FileList["examples/**/*.rb"].each do |file|
    puts file
    system "ruby -Ilib:examples #{file}"
    puts
  end
end
