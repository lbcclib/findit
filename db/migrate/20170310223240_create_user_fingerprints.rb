class CreateUserFingerprints < ActiveRecord::Migration
  def change
    create_table :user_fingerprints do |t|
      t.boolean :on_campus
      t.boolean :in_district
      t.boolean :localhost
      t.boolean :bot_visitor
      t.text :postal_code

      t.timestamps null: false
    end
  end
end
