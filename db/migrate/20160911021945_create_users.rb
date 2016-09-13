class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :phone_number, null: false
      t.string :name
      t.string :last_context

      t.timestamps(null: false)
    end
  end
end
