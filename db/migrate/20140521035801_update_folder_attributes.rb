class UpdateFolderAttributes < ActiveRecord::Migration
  def change
    remove_column :folders, :name
    add_column :folders, :title, :string
    add_column :folders, :fid, :string
    add_column :folders, :slug, :string
  end
end
