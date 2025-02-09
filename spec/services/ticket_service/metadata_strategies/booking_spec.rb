require 'rails_helper'

RSpec.describe TicketService::MetadataStrategies::Booking do
  let(:driver) { create(:user, :customer, email: 'driver@example.com') }
  let(:car) { create(:car, brand: 'Toyota', model: 'Corolla', year: 2020) }
  let(:booking) do
    create(:booking,
      driver: driver,
      car: car,
      start_date: Date.today + 1.day,
      end_date: Date.today + 10.days
    )
  end

  subject(:strategy) { described_class.new(booking) }

  describe '#build' do
    let(:metadata) { strategy.build }

    it 'returns a hash with all required sections' do
      expect(metadata.keys).to match_array([ :car, :dates, :driver ])
    end

    describe 'car data' do
      let(:car_data) { metadata[:car] }

      it 'includes car brand' do
        expect(car_data[:brand]).to eq('Toyota')
      end

      it 'includes car model' do
        expect(car_data[:model]).to eq('Corolla')
      end

      it 'includes car year' do
        expect(car_data[:year]).to eq("2020")
      end
    end

    describe 'dates data' do
      let(:dates_data) { metadata[:dates] }

      it 'includes start date' do
        expect(dates_data[:start_date]).to eq(Date.today + 1.day)
      end

      it 'includes end date' do
        expect(dates_data[:end_date]).to eq(Date.today + 10.days)
      end
    end

    describe 'driver data' do
      let(:driver_data) { metadata[:driver] }

      it 'includes driver email' do
        expect(driver_data[:email]).to eq('driver@example.com')
      end
    end
  end

  context 'with different date formats' do
    let(:booking) do
      create(:booking,
        driver: driver,
        car: car,
        start_date: Date.today + 1.day,
        end_date: Date.today + 10.days
      )
    end
  end
end
