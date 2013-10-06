FileClip [![Build Status](https://travis-ci.org/ScotterC/fileclip.png?branch=master)](https://travis-ci.org/ScotterC/fileclip)
========

A FilePicker / PaperClip mashup.  Use Filepicker for uploads and paperclip to process them.

### What FileClip Does

FileClip saves a filepicker url to your image table which is then
processed by paperclip after the object is saved.  This allows filepicker urls with paperclip styles while the image is being processed and the possibility for seamless image handling without having to process anything on your rails servers.

## Minimum Viable Setup

### Add to Paperclip table
````
class AddFileClipToImages < ActiveRecord::Migration
  def up
    add_column :images, :filepicker_url, :string
  end

  def down
    remove_column :images, :filepicker_url
  end
end
````

### In Initializer
````
# config/initializers/fileclip.rb
FileClip.configure do |config|
  config.filepicker_key = 'XXXXXXXXXXXXXXXXXXX'
end
````

### In Model
````
# models/image.rb
class Image << ActiveRecord::Base

  has_attached_file :attachment

  fileclip :attachment
end
````

### In View
````
# Loads Filepicker js, and FileClip js
<%= fileclip_js_include_tag %>

<%= form_for(Image.new) do |f| %>

  # provides a link that can be styled any way you choose
  # launches filepicker dialog and saves link to hidden field
  <%= link_to_fileclip "Choose a File", f %>

  <%= f.submit %>
<% end %>

````

#### Current FilePicker options hardcoded
* mimetypes are image/*
* container modal
* service Computer
* maxsize is 20 mb
* location is S3
* path is "/fileclip"
* access is public

Features:
* Unobtrusive.  Normal paperclip uploads still work


#### Gotchas

This paperclip validation will return errors even if filepicker url is present:
````
  validates :attachment, :attachment_presence => true
````

However, this will work fine.  It'll skip the attachment check if a filepicker url is present and validate if it's not.
````
  validates_attachment :attachment, :size => { :in => 0..1000 }, :presence => true
````
