#!/usr/bin/ruby
template = $stdin.read
examples = template.scan(/include_example (.*)/)[0]

examples.each do |example|
  replacement = File.read("examples/#{example}.rb")
  template.gsub!(/include_example #{example}/, replacement)
end

$stdout.print template
