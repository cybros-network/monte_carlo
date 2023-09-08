class CreateVocabularies < ActiveRecord::Migration[7.1]
  def change
    create_table :vocabularies do |t|
      t.string :text, null: false
      t.references :glossary, null: false, foreign_key: true, index: true
    end
  end
end
