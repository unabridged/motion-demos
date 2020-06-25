class CreateSignups < ActiveRecord::Migration[6.0]
  def change
    create_table :signups do |t|
      t.string :name
      t.string :email
      t.string :favorite_color
      t.integer :plan
      t.boolean :terms
      t.date :birthday
      t.string :country
      t.string :state
      t.text :comments

      t.timestamps
    end
  end
end
