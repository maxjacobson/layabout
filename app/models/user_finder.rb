module UserFinder
  def self.for(request)
    auth = request.env["omniauth.auth"]
    User.find_or_initialize_by(uid: auth.uid.to_s).tap do |user|
      user.assign_attributes(attributes_from_auth(auth))
    end
  end

  def self.attributes_from_auth(auth)
    {
      active: auth.extra.raw_info.subscription_is_active == "1",
      email: auth.extra.raw_info.username,
      token: auth.credentials.values[0],
      secret: auth.credentials.values[1],
      last_synced_at: Time.now
    }
  end
end
