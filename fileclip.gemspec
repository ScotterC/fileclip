Gem::Specification.new do |s|
  s.name = "fileclip"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Carleton"]
  s.date = "2013-07-26"
  s.description = "NO CODE WRITTEN YET: A FilePicker / PaperClip mashup.  Use Filepicker for uploads and paperclip to process them.  Works with Resque & Delayed Paperclip"
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
    "VERSION",
    "fileclip.gemspec",
    "lib/fileclip.rb",
    "lib/fileclip/version.rb"
  ]
  s.homepage = "http://github.com/ScotterC/fileclip"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "A FilePicker / PaperClip mashup."

  s.add_dependency(%q<rake>, [">= 0"])
end

