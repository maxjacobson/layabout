module UserFinder
  def self.for(request)
    auth = request.env['omniauth.auth']
    User.find_or_initialize_by(uid: auth.uid.to_s).tap do |user|
      user.active = auth.extra.raw_info.subscription_is_active == '1'
      user.email = auth.extra.raw_info.username
      user.token, user.secret = auth.credentials.values
      user.last_synced_at = Time.now
    end
  end
end

