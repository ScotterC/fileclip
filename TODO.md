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