$:.push File.expand_path("../lib", __FILE__)
require "fileclip/version"
require 'date'

Gem::Specification.new do |s|
  s.name = "fileclip"
  s.version = FileClip::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Carleton"]
  s.date = Date.today.to_s
  s.description = "A FilePicker / PaperClip mashup.  Use Filepicker for uploads and paperclip to process them."
  s.email = "scott@artsicle.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.md",
    "Rakefile",
    "fileclip.gemspec",
    "lib/fileclip.rb",
    "lib/fileclip/version.rb"
  ]
  s.homepage = "http://github.com/ScotterC/fileclip"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "A FilePicker / PaperClip mashup."

  s.add_dependency 'paperclip', [">= 3.5.1"]
  s.add_dependency 'rest-client'

  s.add_development_dependency "rspec"
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency "rails"
  s.add_development_dependency 'resque'
  s.add_runtime_dependency(%q<railties>, [">= 3.0"])

  s.add_runtime_dependency "paperclip"
end

