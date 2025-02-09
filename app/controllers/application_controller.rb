class ApplicationController < ActionController::Base
  include Pundit::Authorization
  allow_browser versions: :modern

  def after_sign_in_path_for(resource)
    dashboard_path
  end
end
