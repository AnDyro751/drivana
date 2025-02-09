module TicketService
  class CalculatorFactory
    def self.for(ticketable)
      calculator_class = "TicketService::Calculators::#{ticketable.class.name}".safe_constantize
      calculator_class&.new(ticketable) || Calculators::Base.new(ticketable)
    rescue NameError
      raise "Calculator not found for #{ticketable.class.name}"
    end
  end
end
