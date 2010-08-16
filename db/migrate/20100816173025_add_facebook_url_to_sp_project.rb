class AddFacebookUrlToSpProject < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :facebook_url, :string
    add_column :sp_projects, :picture_file_name,    :string
    add_column :sp_projects, :picture_content_type, :string
    add_column :sp_projects, :picture_file_size,    :integer
    add_column :sp_projects, :picture_updated_at,   :datetime
  end

  def self.down
    remove_column :sp_projects, :picture_updated_at
    remove_column :sp_projects, :picture_file_size
    remove_column :sp_projects, :picture_content_type
    remove_column :sp_projects, :picture_file_name
    remove_column :sp_projects, :facebook_url
  end
end