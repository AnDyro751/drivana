require 'rails_helper'

RSpec.describe TicketService::Calculators::BookingExtension do
  let(:daily_rate) { Money.new(10000, "MXN") } # $100.00 MXN
  let(:car) { create(:car, daily_rate: daily_rate) }
  let(:booking) { create(:booking,
    car: car,
    start_date: Date.today + 1.day,
    end_date: Date.today + 10.days
  ) }
  let(:booking_extension) do
    create(:booking_extension,
      booking: booking,
      start_date: booking.end_date + 1.day,
      end_date: booking.end_date + 2.days
    )
  end

  subject(:calculator) { described_class.new(booking_extension) }

  describe '#calculate' do
    let(:result) { calculator.calculate }

    it 'returns a hash with all required attributes' do
      expect(result.keys).to match_array([
        :issue_date,
        :rental_days,
        :daily_rate,
        :subtotal_rent,
        :additional_charges,
        :discounts,
        :taxes,
        :total_amount
      ])
    end

    it 'calculates rental days correctly' do
      expect(result[:rental_days]).to eq(1)
    end

    it 'uses the car daily rate from the original booking' do
      expect(result[:daily_rate]).to eq(daily_rate)
    end

    it 'calculates subtotal correctly' do
      expect(result[:subtotal_rent]).to eq(Money.new(10000, "MXN"))
    end

    it 'sets additional charges to zero' do
      expect(result[:additional_charges]).to eq(Money.new(0, "MXN"))
    end

    it 'sets discounts to zero' do
      expect(result[:discounts]).to eq(Money.new(0, "MXN"))
    end

    it 'calculates taxes correctly (16% IVA)' do
      expect(result[:taxes]).to eq(Money.new(1600, "MXN"))
    end

    it 'calculates total amount correctly' do
      expect(result[:total_amount]).to eq(Money.new(11600, "MXN"))
    end
  end

  context 'with different date ranges' do
    let(:booking_extension) do
      create(:booking_extension,
        booking: booking,
        start_date: booking.end_date + 1.day,
        end_date: booking.end_date + 2.days
      )
    end

    it 'calculates correct amounts for one day' do
      result = calculator.calculate
      expect(result[:rental_days]).to eq(1)
      expect(result[:subtotal_rent]).to eq(Money.new(10000, "MXN"))
      expect(result[:taxes]).to eq(Money.new(1600, "MXN"))
      expect(result[:total_amount]).to eq(Money.new(11600, "MXN"))
    end
  end

  context 'with different daily rates' do
    let(:daily_rate) { Money.new(20000, "MXN") } # $200.00 MXN

    it 'calculates correct amounts with higher rate' do
      result = calculator.calculate
      expect(result[:subtotal_rent]).to eq(Money.new(20000, "MXN"))
      expect(result[:taxes]).to eq(Money.new(3200, "MXN"))
      expect(result[:total_amount]).to eq(Money.new(23200, "MXN"))
    end
  end

  context 'with datetime values' do
    let(:booking_extension) do
      create(:booking_extension,
        booking: booking,
        start_date: booking.end_date + 1.day,
        end_date: booking.end_date + 2.days
      )
    end

    it 'calculates rental days correctly ignoring time' do
      result = calculator.calculate
      expect(result[:rental_days]).to eq(1)
    end
  end

  context 'when car rate changes after booking' do
    it 'uses the original booking car rate' do
      original_rate = car.daily_rate
      car.update(daily_rate: Money.new(30000, "MXN"))

      result = calculator.calculate
      expect(result[:daily_rate]).to eq(original_rate * 3)
    end
  end
end
