$:.push File.expand_path("../lib", __FILE__)
require "fileclip/version"

Gem::Specification.new do |s|
  s.name          = "fileclip"
  s.version       = FileClip::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Scott Carleton"]
  s.summary       = "A FilePicker / PaperClip mashup."
  s.description   = "A FilePicker / PaperClip mashup.  Use Filepicker for uploads and paperclip to process them."
  s.email         = "scott@artsicle.com"
  s.license       = "MIT"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.homepage      = "http://github.com/ScotterC/fileclip"

  s.rubygems_version = "2.0.3"

  s.add_dependency 'rest-client'

  s.add_development_dependency "rspec", ["2.14.1"]
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency "rails"
  s.add_development_dependency 'resque'
  s.add_development_dependency 'sidekiq'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'appraisal'

  s.add_runtime_dependency(%q<railties>, [">= 3.0"])
  s.add_runtime_dependency "paperclip", [">= 3.3"]
end

