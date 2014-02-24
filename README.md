FileClip [![Build Status](https://travis-ci.org/ScotterC/fileclip.png?branch=master)](https://travis-ci.org/ScotterC/fileclip) [![Coverage Status](https://coveralls.io/repos/ScotterC/fileclip/badge.png?branch=master)](https://coveralls.io/r/ScotterC/fileclip?branch=master)
========

A FilePicker / PaperClip mashup.  Use Filepicker for uploads and paperclip to process them.

### What FileClip Does

FileClip saves a filepicker url to your image table which is then
processed by paperclip after the object is saved.

#### Note: Breaking Changes when upgrading to 0.5

### Pros:
* Filepicker URLs with paperclip styles as fallback
* Seamless image handling while images are processed
* Easy background processing with no risk of losing files
* Unobtrusive, Paperclip uploads still work.

## Minimal Viable Setup

### Add to Paperclip table

````ruby
# column prefix needs to be paperclip attachment name
class AddFileClipToImages < ActiveRecord::Migration
  def up
    add_column :images, :attachment_filepicker_url, :string
    add_column :images, :attachment_processing, :boolean
  end

  def down
    remove_column :images, :attachment_filepicker_url
    remove_column :images, :attachment_processing
  end
end
````

### In Initializer

````ruby
# config/initializers/fileclip.rb
# Defaults shown
FileClip.configure do |config|
  config.filepicker_key        = 'XXXXXXXXXXXXXXXXXXX'
  config.services              = ["COMPUTER"]
  config.max_size              = 20
  config.storage_path          = "/fileclip/"
  config.mime_types            = "images/*"
  config.file_access           = "public"
  config.excluded_environments = ["test"]
  config.default_service       = "COMPUTER"
end
````

### In Model

````ruby
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

 # provides a button that can be styled any way you choose

<%= form_for(Image.new) do |f| %>

  <%= f.fileclip :attachment, "Choose a File" %>

  <%= f.submit %>
<% end %>

# Specify a callback function that gets called when Filepicker completes
<%= f.fileclip :attachment, "Choose a File", :callback => 'window.MyApp.filepickerCallback' %>
````

### More Control

````
# For more control you can disable automatic JS initialization.
# You'll need to add event handlers to the button manually.
<%= f.fileclip :attachment, "Choose a File", :class => ".my-fileclip", :activate => false %>

# Javascript

# Using FileClip's JS work
fileclip = new Fileclip(false)
fileclip.setupButton(".my-fileclip", myCallbackFunction)

# Or completely custom
$(document).on("click", ".my-fileclip", function() {
  // filepicker.pickAndStore ...
  // handle setting the value to the input
})
````

#### Current FilePicker options hardcoded
* container modal
* location is S3


#### Upgrading from < 0.5
* Upgrade filepicker_url columns to use paperclip column prefixes
* {attachment_name}_processing boolean column is now required
* Change views to use formhelper `f.fileclip` instead of `link_to_fileclip`
* Option of `js: false` is now `activate: false`
* Custom code hooked into fileclip.js needs to be evaluated carefully

#### Contributing
If you'd like to contribute a feature or bugfix: Thanks!
Run tests with `rake`.  Post a pull request and make sure there are tests!

#### Gotchas

These validations will return errors even if the filepicker url is present:

````
validates :attachment, :presence => true
validates_attachment_presence :attachment
````

However, this will work fine.  It'll skip the attachment check if a filepicker url is present and validate if it's not. There's a pending test to fix this.

````
validates :attachment, :attachment_presence => true
validates_attachment :attachment, :attachment_presence => true
````
