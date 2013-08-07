require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :development)

# Prepare activerecord
require "active_record"

# Connect to sqlite
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => ":memory:"
)

ActiveRecord::Migration.verbose = false
load(File.join(File.dirname(__FILE__), 'schema.rb'))

ActiveRecord::Base.send(:include, Paperclip::Glue)

ActiveRecord::Base.send(:include, FileClip::Glue)


class Image < ActiveRecord::Base

  has_attached_file :attachment,
    :storage => :filesystem,
    :path => "./spec/tmp/:style/:id.:extension",
    :url => "./spec/tmp/:style/:id.extension"

end
