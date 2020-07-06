class CreateClickerPlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :clicker_players do |t|
      t.references :clicker_game, null: false
      t.string :name
      t.integer :score, default: 0

      t.timestamps
    end
  end
end
