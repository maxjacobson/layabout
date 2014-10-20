class User < ActiveRecord::Base
  has_many :folders

  def ever_synced?
    !last_synced_at.nil?
  end

  def refresh_folders!
    folders.destroy_all
    instapaper.folders.each do |folder|
      folders << folder
    end
    save!
  end

  def instapaper
    @instapaper ||= Instapaper.for(self)
  end
end

