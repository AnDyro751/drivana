module TicketService
  module MetadataStrategies
    class Base
      def initialize(ticketable)
        @ticketable = ticketable
      end

      def build
        {}
      end

      private

      attr_reader :ticketable
    end
  end
end
