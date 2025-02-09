class TicketsController < ApiController
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_ticket, only: [ :show ]

  def show
    authorize @ticket
    render json: @ticket
  end

  def create
    @ticketable = find_ticketable
    authorize @ticketable, :show?

    @ticket = TicketService::Creator.call(ticketable: @ticketable)
    render json: @ticket, status: :created
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def find_ticketable
    params[:ticketable_type].constantize.find(params[:ticketable_id])
  rescue NameError, ActiveRecord::RecordNotFound => _e
    raise "Ticketable not found"
  end
end
