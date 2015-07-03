Gem::Specification.new do |s|
  s.name     = "recurrence-rule-parser"
  s.version  = "0.1.1"
  s.date     = "2008-12-10"
  s.summary  = "iCalendar to Temporal Expression parser"
  s.email    = "texel1@gmail.com"
  s.homepage = "http://github.com/texel/recurrence-rule-parser"
  s.description = "Recurrence Rule Parser helps generate Temporal Expressions from iCalendar events."
  s.has_rdoc = true
  s.authors  = ["Leigh Caplan"]
  s.files    = %w(
    History.txt
    Manifest.txt
    README.txt
    Rakefile
    bin/rrule_parser
    lib/rrule_parser.rb
  )
  s.test_files = %w(
    spec/lib/rrule_parser_spec.rb
  )
  s.rdoc_options = ["--main", "README.txt"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.add_dependency("runt", [">= 0.7.1"])
  s.add_dependency("icalendar", [">= 1.0.2"])
end
