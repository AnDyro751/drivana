module TicketableCreation
  extend ActiveSupport::Concern

  included do
    after_create :schedule_ticket_creation
  end

  private

  def schedule_ticket_creation
    TicketService::Creator.call(ticketable: self)
  end
end
