class AddBlogToSpProject < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :blog_url, :string
    add_column :sp_projects, :blog_title, :string
    change_column_default :sp_projects, :max_student_men_applicants, 60
    change_column_default :sp_projects, :max_student_women_applicants, 60
  end

  def self.down
    remove_column :sp_projects, :blog_title
    remove_column :sp_projects, :blog_url
  end
end
