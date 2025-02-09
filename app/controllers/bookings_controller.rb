class BookingsController < ApiController
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_booking, only: [ :show, :extend_booking, :tickets, :consolidated_ticket ]

  def show
    authorize @booking, :show?
    render json: @booking
  end

  def create
    @booking = current_user.bookings.build(booking_params)
    authorize @booking, :create?

    if @booking.save
      render json: @booking, status: :created
    else
      render json: { errors: @booking.errors }, status: :unprocessable_entity
    end
  end

  def extend_booking
    authorize @booking, :extend?
    @booking_extension = @booking.booking_extensions.build(booking_extension_params)

    if @booking_extension.save
      render json: @booking_extension, status: :created
    else
      render json: { errors: @booking_extension.errors }, status: :unprocessable_entity
    end
  end

  def tickets
    authorize @booking, :show?
    @tickets = @booking.tickets
    @booking_extensions = @booking.booking_extensions
    render json: { tickets: @tickets, booking_extensions: @booking_extensions.map(&:tickets) }
  end

  def consolidated_ticket
    authorize @booking, :show?
    @tickets = @booking.tickets.includes(:ticketable)
    @booking_extension_tickets = @booking.booking_extensions.map(&:tickets)
    @all_tickets = @tickets + @booking_extension_tickets

    consolidated = {
      booking_id: @booking.id,
      total_amount: @all_tickets.sum(&:total_amount),
      tickets: @all_tickets.map do |ticket|
        {
          id: ticket.id,
          type: ticket.ticketable_type,
          amount: ticket.total_amount,
          issue_date: ticket.issue_date,
          details: {
            rental_days: ticket.rental_days,
            daily_rate: ticket.daily_rate,
            subtotal_rent: ticket.subtotal_rent,
            additional_charges: ticket.additional_charges,
            discounts: ticket.discounts,
            taxes: ticket.taxes
          }
        }
      end
    }

    render json: consolidated
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:car_id, :start_date, :end_date)
  end

  def booking_extension_params
    params.require(:booking_extension).permit(:start_date, :end_date)
  end
end
