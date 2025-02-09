module Dashboard
  class BookingExtensionsController < DashboardBaseController
    before_action :set_booking

    def create
      @booking_extension = @booking.booking_extensions.build(booking_extension_params)
      authorize @booking_extension

      if @booking_extension.save
        redirect_to dashboard_booking_path(@booking), notice: "Reservación extendida exitosamente."
      else
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace("booking_extension_form",
              partial: "dashboard/bookings/extension_form",
              locals: { booking: @booking, booking_extension: @booking_extension }
            )
          end
        end
      end
    end

    private

    def set_booking
      @booking = current_user.bookings.find(params[:booking_id])
    end

    def booking_extension_params
      params.require(:booking_extension).permit(:start_date, :end_date)
    end
  end
end
