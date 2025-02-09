module TicketService
  module Calculators
    class Booking < Base
      def calculate
        {
          issue_date: Time.current,
          rental_days: calculate_rental_days,
          daily_rate: ticketable.car.daily_rate,
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
        ticketable.car.daily_rate * calculate_rental_days
      end

      def calculate_additional_charges
        Money.new(0, "MXN") # Por ahora no hay cargos adicionales, o al menos eso entendí jaja
      end

      def calculate_discounts
        # Por ahora no hay descuentos, pero aquí sería el lugar para agregarlos
        Money.new(0, "MXN")
      end

      def calculate_taxes
        # Aquí podríamos agregar el cálculo de impuestos
        # Dependiendo de la región, podríamos agregar otros impuestos
        # Por ahora se maneja para México, un 16% de IVA, y solo para la prueba
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
