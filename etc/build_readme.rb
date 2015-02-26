#!/usr/bin/ruby
template = $stdin.read
examples = template.scan(/include_example (.*)/)[0]

examples.each do |example|
  file = "examples/#{example}.rb"
    if File.exists?(file)
    replacement = File.read(file)
    template.gsub!(/include_example #{example}/, replacement)
  end
end

$stdout.print template
