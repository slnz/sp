class ChangeCompletedToReadyOnSpApplication < ActiveRecord::Migration
  def self.up
    SpApplication.update_all("status = 'ready'", "status = 'completed'")
  end

  def self.down
    SpApplication.update_all("status = 'completed'", "status = 'ready'")
  end
end
