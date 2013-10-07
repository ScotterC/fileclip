require 'rubygems' unless defined? Gem
require 'bundler'
Bundler.setup

# Prepare activerecord
# require "active_record"
require 'rails/all'

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


class Image < ActiveRecord::Base

  has_attached_file :attachment,
    :storage => :filesystem,
    :path => "./spec/tmp/:style/:id.:extension",
    :url => "./spec/tmp/:style/:id.extension"

  fileclip :attachment

end

class Asset < ActiveRecord::Base

  has_attached_file :attachment,
    :storage => :filesystem,
    :path => "./spec/tmp/:style/:id.:extension",
    :url => "./spec/tmp/:style/:id.extension"

end
