require 'open-uri'
require 'resque-retry'

class SendUserActivationCodeResqueJob
  extend Resque::Plugins::Retry
  @queue = "user_activation"
  
  @retry_limit = 3

  def self.perform(user_id, phone_number)
    user = User.find(user_id)
    params = {:app_id => ENV["HOIIO_APP_ID"],
              :access_token => ENV["HOIIO_ACCESS_TOKEN"],
              :sender_name => "Memcap",
              :msg => "Your account activation code is " + user.confirmation_code.to_s + ".",
              :dest => phone_number }
    url = "https://secure.hoiio.com/open/sms/send?" + params.to_query
    json = ActiveSupport::JSON.decode( open url )
    if json["status"] != "success_ok"
      raise "job error can't send sms"
    end
  end

end
