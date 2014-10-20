Rails.application.config.middleware.use OmniAuth::Builder do
  provider :instapaper,
           Rails.application.secrets.instapaper['consumer_key'],
           Rails.application.secrets.instapaper['consumer_secret']
end

