class User < ActiveRecord::Base
  # TODO add some kind of auto-generated password
  # so we can prevent cookie hijacking or something like that :)
  # add some validations, like uniqueness of uid and maybe presence
end
