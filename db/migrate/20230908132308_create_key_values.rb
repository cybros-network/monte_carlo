class CreateKeyValues < ActiveRecord::Migration[7.1]
  def change
    create_table :key_values do |t|
      t.string :key, index: true
      t.boolean :visible
      t.decimal :decimal_value
      t.integer :integer_value
      t.string :string_value
      t.datetime :datetime_value
      t.string :json_value

      t.timestamps
    end
  end
end
