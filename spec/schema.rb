ActiveRecord::Schema.define :version => 0 do
  create_table "images", :force => true do |t|
    t.string  :attachment_file_name
    t.string  :attachment_content_type
    t.integer :attachment_updated_at
    t.integer :attachment_file_size
    t.string  :attachment_meta
    t.string  :filepicker_url
  end
end
