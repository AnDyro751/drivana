class DashboardController < DashboardBaseController
  def index
    @cars = Car.status_available
    authorize :dashboard, :index?
  end
end
