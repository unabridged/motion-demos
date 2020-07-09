class GoGameCleanupJob < ApplicationJob
  queue_as :default

  def perform(key:)
    ::Go::Game.delete(key: key)
  end
end
