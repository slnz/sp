class DragonflyOnSpProject < ActiveRecord::Migration
  def self.up
    remove_column :sp_projects, :picture_updated_at
    remove_column :sp_projects, :picture_file_size
    remove_column :sp_projects, :picture_content_type
    remove_column :sp_projects, :picture_file_name
    add_column :sp_projects, :picture_uid, :string
    add_column :sp_projects, :logo_uid, :string
  end

  def self.down
    remove_column :sp_projects, :picture_uid
    remove_column :sp_projects, :logo_uid
    add_column :sp_projects, :picture_file_name,    :string
    add_column :sp_projects, :picture_content_type, :string
    add_column :sp_projects, :picture_file_size,    :integer
    add_column :sp_projects, :picture_updated_at,   :datetime
  end
end