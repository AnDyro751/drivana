module Dashboard
  class TicketsController < DashboardBaseController
    layout false, only: [ :show ]
    before_action :set_ticket, only: [ :show ]
    def show
      authorize @ticket
    end

    private

    def set_ticket
      @ticket = Ticket.find(params[:id])
    end
  end
end
