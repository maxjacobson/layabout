class User < ActiveRecord::Base
  # TODO add some kind of auto-generated password
  # so we can prevent cookie hijacking or something like that :)
  # add some validations, like uniqueness of uid and maybe presence

  has_many :folders

  def ever_synced?
    !last_synced_at.nil?
  end

  def refresh_folders!
    folders.destroy_all
    instapaper.folders_list.each do |folder|
      folders << Folder.from_api(folder)
    end
    save!
  end

  # TODO make this method private, probably
  #
  def instapaper
    @instapaper ||= InstapaperFull::API.new(
      consumer_key: Rails.application.secrets.instapaper['consumer_key'],
      consumer_secret: Rails.application.secrets.instapaper['consumer_secret'],
      oauth_token: token,
      oauth_token_secret: secret
    )
  end

end
