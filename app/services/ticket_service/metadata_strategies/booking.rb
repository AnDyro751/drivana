module TicketService
  module MetadataStrategies
    class Booking < Base
      def build
        {
          car: car_data,
          dates: dates_data,
          driver: driver_data
        }
      end

      private

      def car_data
        {
          brand: ticketable.car.brand,
          model: ticketable.car.model,
          year: ticketable.car.year
        }
      end

      def dates_data
        {
          start_date: ticketable.start_date,
          end_date: ticketable.end_date
        }
      end

      def driver_data
        {
          email: ticketable.driver.email
        }
      end
    end
  end
end
