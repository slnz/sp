class CreateSpRegions < ActiveRecord::Migration
  def self.up
    create_table :sp_world_regions do |t|
      t.string :name
    
      t.timestamps
    end
    SpWorldRegion.connection.execute("insert into sp_world_regions(id, name) select * from aoas")
    rename_column :sp_projects, :aoa, :world_region
  end

  def self.down
    rename_column :sp_projects, :world_region, :aoa
    drop_table :sp_regions
  end
end