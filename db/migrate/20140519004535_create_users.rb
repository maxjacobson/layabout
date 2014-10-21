class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid
      t.boolean :active

      t.timestamps
    end
  end
end

