class CreateSearchFingerprints < ActiveRecord::Migration
  def change
    create_table :search_fingerprints do |t|
      t.text :query_string
      t.text :facets_used
      t.boolean :known_item
      t.integer :page
      t.references :visit, type: :uuid

      t.timestamps null: false
    end
  end
end
