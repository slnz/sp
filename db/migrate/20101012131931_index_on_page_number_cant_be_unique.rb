class IndexOnPageNumberCantBeUnique < ActiveRecord::Migration
  def self.up
    # remove_index Page.table_name, :name => :page_number
    add_index Page.table_name, [:question_sheet_id, :number], :name => "page_number", :unique => false
  end

  def self.down
    # remove_index Page.table_name, :name => :page_number
    # add_index Page.table_name, [:question_sheet_id, :number], :name => "page_number", :unique => true
  end
end