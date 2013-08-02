fileclip
========

A FilePicker / PaperClip mashup.  Use Filepicker for uploads and paperclip to process them.  Works with Resque &amp; Delayed Paperclip

TODO:

Backend:
* It should be unobtrusive.  Normal paperclip uploads should work
* If filepicker_url is present it should process it
* If filepicker_url changes, it should process it
* First version should be minimal
* Handle skipping validations of attachment seamlessly
* Configuration accepts config key

Frontend:
* Allow overriding of filepicker options
* Fileclip link to automatically set fields and call it
* link should act like a normal link helper
* Minimal amount of JS
* Loader for filepicker js if needed

Extra features:
* Work with Delayed Paperclip
* Work with Resque
* Work with DelayedJob
* Work with Sidekiq
* Handle multiple attachments on the same model
* Fallback to filepicker url if paperclip url doesn't exist
* Filepicker converts to match paperclip styles