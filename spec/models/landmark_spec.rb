require 'spec_helper'

describe Landmark do
  let(:user) { FactoryGirl.create(:user) }
  before do
    user.admin = true
    @landmark = user.landmarks.build(description: "sample landmark", latitude: 120.0, longitude: 120.0, rating: 5)
  end

  subject {@landmark}

  it { should respond_to(:description) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) } 
  it { should respond_to(:posts) }
  it { should respond_to(:file_url) }
end
