module TicketService
  class MetadataStrategyFactory
    def self.for(ticketable)
      strategy_class = "TicketService::MetadataStrategies::#{ticketable.class.name}".safe_constantize
      strategy_class&.new(ticketable) || MetadataStrategies::Base.new(ticketable)
    rescue NameError
      raise "Ticketable type not supported: #{ticketable.class.name}"
    rescue => e
      raise "Ticketable type not supported: #{e.message}"
    end
  end
end
