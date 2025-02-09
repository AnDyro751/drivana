module Dashboard
  class BookingsController < DashboardBaseController
    before_action :set_booking, only: [ :show, :cancel, :extend_booking, :ticket ]
    before_action :set_car, only: [ :create ]
    layout false, only: [ :ticket ]
    layout "dashboard", only: [ :index, :show, :extend_booking ]

    def ticket
      authorize @booking, :ticket?
    end

    def index
      authorize Booking, :index?
      @bookings = current_user.bookings.order(created_at: :desc)
    end

    def show
      authorize @booking, :show?
    end

    def create
      @booking = current_user.bookings.build(booking_params)
      authorize @booking, :create?

      if @booking.save
        redirect_to [ :dashboard, @booking ], notice: "Reservación creada exitosamente."
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace("booking_form",
              partial: "form",
              locals: { booking: @booking }
            )
          end
        end
      end
    end

    def cancel
      authorize @booking, :cancel?

      @booking.cancelled!
      redirect_to [ :dashboard, @booking ], notice: "Reservación cancelada exitosamente."
    rescue => _e
      redirect_to [ :dashboard, @booking ], alert: "No se pudo cancelar la reservación."
    end

    def extend_booking
      authorize @booking, :extend?
    end

    private

    def set_booking
      @booking = current_user.bookings.find(params[:id])
    end

    def set_car
      @car = Car.find(params[:car_id]) if params[:car_id]
    end

    def booking_params
      params.require(:booking).permit(:car_id, :start_date, :end_date)
    end
  end
end
