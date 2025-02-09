class DashboardBaseController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  layout "dashboard"

  private

  def user_not_authorized
    flash[:alert] = "No tienes permiso para realizar esta acción."
    redirect_back(fallback_location: root_path)
  end
end
