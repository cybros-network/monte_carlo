class CreatePromptElements < ActiveRecord::Migration[7.1]
  def change
    create_table :prompt_elements do |t|
      t.references :prompting_plan, null: false, foreign_key: true
      t.boolean :negative, null: false, default: false
      t.integer :order

      t.string :text

      t.references :glossary, null: true, foreign_key: true
      t.integer :frequency

      t.string :type, null: false

      t.timestamps
    end
  end
end
