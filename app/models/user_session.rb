class UserSession < Authlogic::Session::Base

  # Included for formtastic patch where fields are disabled if they are not
  # accessible by the current user.
  def self.accessible_attributes role = nil
    [:email, :password]
  end
end
