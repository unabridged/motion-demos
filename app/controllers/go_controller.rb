class GoController < ApplicationController
  before_action :enforce_valid_game_key, only: [:show, :join]

  helper_method :key

  layout "go"

  def create
    key = SecureRandom.hex(5)

    redirect_to go_path(id: key)
  end

  def join
    redirect_to go_path(id: key)
  end

  private

  def key
    @key ||= params[:id]
  end

  def enforce_valid_game_key
    unless /\A[A-Za-z\d]{10}\z/.match? key
      redirect_to go_index_path, error: "Invalid key" and return false
    end
  end
end
