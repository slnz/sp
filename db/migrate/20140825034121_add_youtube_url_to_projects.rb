class AddYoutubeUrlToProjects < ActiveRecord::Migration
  def change

    add_column :sp_projects, :youtube_video_id, :string
  end
end
