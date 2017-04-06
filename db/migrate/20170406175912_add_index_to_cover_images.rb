class AddIndexToCoverImages < ActiveRecord::Migration
  def change
    add_index :cover_images, :solr_id, :unique => true
  end
end
