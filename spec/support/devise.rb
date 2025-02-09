module DeviseRequestSpecHelpers
  include Warden::Test::Helpers

  def sign_in(resource_or_scope, resource = nil)
    resource ||= resource_or_scope
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    login_as(resource, scope: scope)
  end

  def sign_out(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    logout(scope)
  end
end

RSpec.configure do |config|
  config.include DeviseRequestSpecHelpers, type: :request
  config.include DeviseRequestSpecHelpers, type: :controller

  config.before(:suite) do
    Warden.test_mode!
  end

  config.after(:each) do
    Warden.test_reset!
  end
end
