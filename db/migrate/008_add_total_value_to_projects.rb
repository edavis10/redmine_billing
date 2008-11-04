class AddTotalValueToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :total_value, :decimal, :precision => 15, :scale => 2
  end

  def self.down
    remove_column :projects, :total_value
  end
end
