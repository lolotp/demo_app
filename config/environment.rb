# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
DemoApp::Application.initialize!

#custom environment variables
ENV["PUSH_APPID"] = 'F0000010'
ENV["PUSH_USERNAME"] = 'foxtwo'
ENV["PUSH_PASSWORD"] = 'foxtwo'
ENV["PUSH_URL"]='https://mpush.foxcradle.com/push/singlepush.php'
