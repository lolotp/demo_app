class ConciergeApp < ActiveRecord::Base
  attr_accessible :iso_country_code, :category, :app_store_link, :google_play_link, :link
  def as_json(options={})
    json_obj = super
    if (options[:iso_country_code])
      if /http:\/\/itunes.apple.com\/lookup\?id=[0-9]+/.match(self.app_store_link)
        s = json_obj[:app_store_link]
        prefix = "http://itunes.apple.com/"
        json_obj[:app_store_link] = s[0..prefix.length-1] + options[:iso_country_code] + s[prefix.length..-1]
      end
    end
    json_obj
  end
end
