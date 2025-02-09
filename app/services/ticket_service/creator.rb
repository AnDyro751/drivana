module TicketService
  class Creator
    include Callable

    def initialize(ticketable:)
      @ticketable = ticketable
    end

    def call
      create_ticket
      ticket
    end

    private

    attr_reader :ticketable, :ticket

    def create_ticket
      @ticket = ticketable.tickets.new(calculate_ticket_attributes)
      @ticket.save!
    rescue => e
      raise "Error creating ticket: #{e.message}"
    end

    def calculate_ticket_attributes
      CalculatorFactory.for(ticketable).calculate
    rescue => e
      raise "Error calculating ticket attributes: #{e.message}"
    end
  end
end
