require 'erb'

@name = "Sonam"
template = File.read('../form_letter.erb')
renderer = ERB.new(template)
result = renderer.result(binding)
puts result
