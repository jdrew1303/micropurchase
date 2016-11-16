require 'concerns/user_provided_service'

class DataDotGovCredentials
  def self.api_key
    Credentials.get('data-dot-gov', 'api_key')
  end
end
