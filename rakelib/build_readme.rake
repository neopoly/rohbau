desc 'Generate README.md from README.md.template'
task :build_readme do
  root = Pathname.new(File.dirname(__FILE__)).join('..')

  template = root.join(ENV.fetch('TEMPLATE', 'README.md.template'))
  output = root.join(ENV.fetch('OUTPUT', 'README.md'))

  content = File.read(template)
  content.gsub!(/include_example '(.*?)'/) do |match|
    example = $1
    file = root.join('examples').join("#{example}.rb")
    if File.exist?(file)
      File.read(file)
    else
      warn "#{file} is missing" unless example =~ /example_file_name/
      match
    end
  end

  File.open(output, 'wb') do |file|
    file.write(content)
  end
end
