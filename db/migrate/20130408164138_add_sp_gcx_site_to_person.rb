class AddSpGcxSiteToPerson < ActiveRecord::Migration
  def self.up
    add_column :ministry_person, :sp_gcx_site, :string
  end

  def self.down
    remove_column :ministry_person, :sp_gcx_site
  end
end
