class CreateIdentities < ActiveRecord::Migration[7.1]
  def change
    create_table :identities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :extern_uid, null: false

      t.index %i[user_id provider], unique: true

      t.timestamps
    end
  end
end
