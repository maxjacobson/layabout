class User < ActiveRecord::Base
  # TODO add some kind of auto-generated password
  # so we can prevent cookie hijacking or something like that :)
  # add some validations, like uniqueness of uid and maybe presence

  has_many :folders

  def refresh_folders!
    #folders.destroy_all
    #HTTParty.post(
    #  'https://instapaper.com/api/1.1/folders/list',
    #  body: {
    #    user_id: uid,
    #    consumer_key: Rails.application.secrets.instapaper['consumer_key'],
    #    consumer_secret: Rails.application.secrets.instapaper['consumer_secret']
    #  }
    #)
  end
end
