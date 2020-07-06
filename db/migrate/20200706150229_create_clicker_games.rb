class CreateClickerGames < ActiveRecord::Migration[6.0]
  def change
    create_table :clicker_games do |t|
      t.string :key, null: false

      t.timestamps
    end

    add_index :clicker_games, :key, unique: true
  end
end
