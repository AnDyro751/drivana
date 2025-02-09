module Dashboard
  class CarsController < DashboardBaseController
    before_action :set_car, only: [ :show, :reserve ]

    def index
      @cars = policy_scope(CarsQuery.for_user(current_user))
      authorize @cars
    end

    def show
      authorize @car
    end

    def new
      @car = current_user.cars.build
      authorize @car
    end

    def create
      @car = current_user.cars.build(car_params)
      authorize @car

      if @car.save
        redirect_to dashboard_car_path(@car), notice: "Carro creado exitosamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def reserve
      authorize @car, :reserve?
    end

    private

    def set_car
      @car = CarFinder.find_for_user(user: current_user, id: params[:id])
    end

    def car_params
      params.require(:car).permit(:brand, :model, :year, :daily_rate, :status)
    end
  end
end
