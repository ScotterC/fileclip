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

ActiveRecord::Schema.define :version => 0 do
  create_table "delayed_images", :force => true do |t|
    t.string  :attachment_file_name
    t.string  :attachment_content_type
    t.integer :attachment_updated_at
    t.integer :attachment_file_size
    t.boolean :attachment_processing, default: false
    t.string  :filepicker_url
  end
end

ActiveRecord::Schema.define :version => 0 do
  create_table "assets", :force => true do |t|
    t.string  :attachment_file_name
    t.string  :attachment_content_type
    t.integer :attachment_updated_at
    t.integer :attachment_file_size
  end
end
