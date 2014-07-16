require 'rubygems' unless defined? Gem
require 'bundler'
Bundler.setup

if ENV["TRAVIS"]
  require 'coveralls'
  Coveralls.wear!
end

begin
  require 'byebug'
rescue LoadError
  # Byebug is not available, just ignore.
end

require 'rails/all'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each do |file|
  require file
end

# Connect to sqlite
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => ":memory:"
)

ActiveRecord::Migration.verbose = false
load(File.join(File.dirname(__FILE__), 'schema.rb'))

require 'paperclip'
ActiveRecord::Base.send(:include, Paperclip::Glue)

require 'fileclip'
ActiveRecord::Base.send(:include, FileClip::Glue)

::ActionView::Helpers::FormBuilder.send(:include, FileClip::ActionView::FormHelper)

class Image < ActiveRecord::Base
  has_attached_file :attachment,
    :storage => :filesystem,
    :path => "./spec/tmp/:style/:id.:extension",
    :url => "./spec/tmp/:style/:id.extension"

  fileclip :attachment

  has_attached_file :other_attachment,
                    :storage => :filesystem,
                    :path => "./spec/tmp/:style/:id.:extension",
                    :url => "./spec/tmp/:style/:id.extension"

  fileclip :other_attachment
end


class PlainAsset < ActiveRecord::Base
  has_attached_file :attachment,
    :storage => :filesystem,
    :path => "./spec/tmp/:style/:id.:extension",
    :url => "./spec/tmp/:style/:id.extension"

end
