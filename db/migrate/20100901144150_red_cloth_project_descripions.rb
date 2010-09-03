class RedClothProjectDescripions < ActiveRecord::Migration
  def self.up
    SpProject.all.each do |p|
      description = RedCloth.new(p.description.to_s).to_html
      SpProject.connection.update("UPDATE sp_projects set description = '#{description}' where id = #{p.id}")
    end
  end

  def self.down
  end
end
