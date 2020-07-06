class ClickerGame < ApplicationRecord
  has_many :clicker_players, dependent: :destroy
end
