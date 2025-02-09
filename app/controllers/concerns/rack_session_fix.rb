module RackSessionFix
  extend ActiveSupport::Concern

  # Este módulo es necesario porque Rails 7 no crea una sesión por defecto
  # y Devise la necesita para el sign out
  class FakeRackSession < Hash
    def enabled?
      false
    end
  end

  included do
    before_action :set_fake_rack_session_for_devise

    private

    def set_fake_rack_session_for_devise
      request.env["rack.session"] ||= FakeRackSession.new
    end
  end
end
