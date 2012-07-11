class UserSession < Authlogic::Session::Base
  
  logout_on_timeout true

  # Included for formtastic patch where fields are disabled if they are not
  # accessible by the current user.
  def self.accessible_attributes role = nil
    [:email, :password]
  end
end
