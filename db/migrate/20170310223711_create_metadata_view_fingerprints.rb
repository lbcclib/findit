class CreateMetadataViewFingerprints < ActiveRecord::Migration
  def change
    create_table :metadata_view_fingerprints do |t|
      t.text :document_id
      t.text :database_code
      t.timestamp :timestamp

      t.timestamps null: false
    end
  end
end
