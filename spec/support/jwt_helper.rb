module JwtHelper
  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {
      'Authorization' => "Bearer #{token}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include JwtHelper, type: :controller
  config.include JwtHelper, type: :request
  config.include JwtHelper, type: :feature
  config.include JwtHelper
end
