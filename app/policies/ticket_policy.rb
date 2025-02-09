class TicketPolicy < ApplicationPolicy
  def show?
    record.ticketable.driver == user
  end
end
