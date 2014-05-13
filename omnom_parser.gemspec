Gem::Specification.new do |s|
  s.name        = 'omnom_parser'
  s.version     = '0.0.1'
  s.date        = '2014-05-13'
  s.summary     = "Recipe parsing"
  s.description = "Recipe parsing"
  s.authors     = ["Rob Esris", "Ashe Avenue"]
  s.files       = ["lib/omnom_parser.rb"]

  s.add_runtime_dependency 'ingreedy'
  s.add_runtime_dependency 'numbers_in_words'
  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'actionview'
end