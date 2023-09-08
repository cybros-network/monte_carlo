class CreateGlossaries < ActiveRecord::Migration[7.1]
  def change
    create_table :glossaries do |t|
      t.string :name, null: false
      t.string :description
      t.references :user, null: true, foreign_key: true, index: true

      t.timestamps
    end
  end
end
