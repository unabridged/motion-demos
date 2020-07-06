class CreateClickerGames < ActiveRecord::Migration[6.0]
  def change
    create_table :clicker_games do |t|
      t.string :key

      t.timestamps
    end
  end
end
