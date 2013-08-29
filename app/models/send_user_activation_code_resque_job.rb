require 'open-uri'
require 'resque-retry'

class SendUserActivationCodeResqueJob
  extend Resque::Plugins::Retry
  @queue = "user_login"
  
  @retry_limit = 3

  def self.perform(user_id, phone_number)
    phone_number = phone_number.to_s
    relevant_country_codes = ["886","65"]
    relevant_country_codes.each do |code|
      puts "processing code " + code.to_s
      if phone_number.start_with?(code + "0")
        phone_number = code + phone_number[code.length + 1, phone_number.length - code.length - 1]
        puts "new phone number is " + phone_number.to_s
        break
      end      
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
