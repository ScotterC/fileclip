FileClip
========

A FilePicker / PaperClip mashup.  Use Filepicker for uploads and paperclip to process them.

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

### What FileClip Does

FileClip saves a filepicker url to your image table which is then
processed by paperclip after the object is saved.  This allows for seamless image handling without having to process it on your rails servers.


TODO:

Backend:
* It should be unobtrusive.  Normal paperclip uploads should work
* If filepicker_url is present it should process it
* If filepicker_url changes, it should process it
* First version should be minimal
* Handle skipping validations of attachment seamlessly
* handle multiple attachments on a model, prefix column with attachment name
* create generator for migration
* create generator for intializer

Frontend:
* Allow overriding of filepicker options
* Fileclip link to automatically set fields and call it
* link should act like a normal link helper
* Minimal amount of JS
* Loader for filepicker js only if needed
* Eliminate need for jQuery
* make it a form builder function that can accept a different url name

Extra features:
* Work with Delayed Paperclip
* Work with Resque
* Work with DelayedJob
* Work with Sidekiq
* Handle multiple attachments on the same model
* Fallback to filepicker url if paperclip url doesn't exist
* Filepicker converts to match paperclip styles
* Configure Filepicker options
* FilePicker droppane support

#### Current FilePicker options hardcoded
* mimetypes are image/*
* container modal
* service Computer
* maxsize is 20 mb
* location is S3
* path is "/fileclip"
* access is public