module TicketService
  module Calculators
    class BookingExtension < Base
      def calculate
        {
          issue_date: Time.current,
          rental_days: calculate_rental_days,
          daily_rate: ticketable.booking.car.daily_rate,
          subtotal_rent: calculate_subtotal,
          additional_charges: calculate_additional_charges,
          discounts: calculate_discounts,
          taxes: calculate_taxes,
          total_amount: calculate_total_amount
        }
      end

      private

      def calculate_rental_days
        (ticketable.end_date.to_date - ticketable.start_date.to_date).to_i
      end

      def calculate_subtotal
        ticketable.booking.car.daily_rate * calculate_rental_days
      end

      def calculate_additional_charges
        Money.new(0, "MXN") # Por ahora no hay cargos adicionales
      end

      def calculate_discounts
        Money.new(0, "MXN") # Por ahora no hay descuentos
      end

      def calculate_taxes
        # IVA 16%
        calculate_subtotal * 0.16
      end

      def calculate_total_amount
        subtotal = calculate_subtotal
        additional_charges = calculate_additional_charges
        discounts = calculate_discounts
        taxes = calculate_taxes

        ((subtotal + additional_charges) - discounts) + taxes
      end
    end
  end
end
