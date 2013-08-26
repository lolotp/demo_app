require 'open-uri'
require 'resque-retry'

class SendUserActivationCodeResqueJob
  extend Resque::Plugins::Retry
  @queue = "user_activation"
  
  @retry_limit = 3

  def self.perform(user_id, phone_number)
    phone_number = phone_number.to_s
    if phone_number.start_with?("880") or phone_number.start_with?("650")
      phone_number = phone_number[0,2] + phone_number[3, phone_number.length - 3]
      puts "new phone number is " + phone_number.to_s
    end
    user = User.find(user_id)
    params = {:app_id => ENV["HOIIO_APP_ID"],
              :access_token => ENV["HOIIO_ACCESS_TOKEN"],
              :sender_name => "Memcap",
              :msg => "Your account activation code is " + user.confirmation_code.to_s + ".",
              :dest => phone_number }
    url = "https://secure.hoiio.com/open/sms/send?" + params.to_query
    json = ActiveSupport::JSON.decode( open url )
    if json["status"] != "success_ok"
      raise "job error can't send sms to " + phone_number.to_s + " reason " + json.to_s
    end
  end

end
