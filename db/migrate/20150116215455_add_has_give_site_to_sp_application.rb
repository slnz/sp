class AddHasGiveSiteToSpApplication < ActiveRecord::Migration
  def change
    add_column :sp_applications, :has_give_site, :boolean, default: false
  end
end
