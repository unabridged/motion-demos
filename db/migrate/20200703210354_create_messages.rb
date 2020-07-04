class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.references :from, foreign_key: {to_table: "users"}
      t.references :to, foreign_key: {to_table: "users"}
      t.text :content
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
