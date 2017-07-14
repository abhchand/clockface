class CreateUser < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.timestamps null: false

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :ability, null: true
    end

    add_index :users, :email, unique: true
  end
end
