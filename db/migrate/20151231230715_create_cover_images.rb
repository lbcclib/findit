class CreateCoverImages < ActiveRecord::Migration
  def change
    create_table :cover_images do |t|
      t.string :isbn
      t.string :thumbnail_url
      t.string :full_url
      t.string :solr_id
      t.string :oclc_number
      t.string :lccn

      t.timestamps null: false
    end
  end
end
