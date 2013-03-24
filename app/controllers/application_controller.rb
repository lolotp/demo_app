class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  def is_mobile?
    mobile_flag = params[:is_mobile]
    (mobile_flag and mobile_flag == "1")
  end
end
