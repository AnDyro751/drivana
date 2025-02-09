module TicketService
  module Calculators
    class Base
      def initialize(ticketable)
        @ticketable = ticketable
      end

      def calculate
        raise "Not implemented"
      end

      private

      attr_reader :ticketable
    end
  end
end
