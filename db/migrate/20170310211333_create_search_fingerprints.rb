class CreateSearchFingerprints < ActiveRecord::Migration
  def change
    create_table :search_fingerprints do |t|
      t.text :query_string
      t.text :facets_used
      t.boolean :known_item
      t.timestamp :timestamp
      t.references :session, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
