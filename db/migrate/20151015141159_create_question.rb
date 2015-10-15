class CreateQuestion < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :poll_id, null: false
      t.text :text

      t.timestamps
    end

    add_index :questions, :poll_id
  end
end
