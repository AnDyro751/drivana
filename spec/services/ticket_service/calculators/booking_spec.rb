require 'rails_helper'

RSpec.describe TicketService::Calculators::Booking do
  let(:daily_rate) { Money.new(10000, "MXN") } # $100.00 MXN
  let(:car) { create(:car, daily_rate: daily_rate) }
  let(:booking) do
    create(:booking,
      car: car,
      start_date: Date.today + 1.day,
      end_date: Date.today + 10.days
    )
  end

  subject(:calculator) { described_class.new(booking) }

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
      expect(result[:rental_days]).to eq(9)
    end

    it 'uses the car daily rate' do
      expect(result[:daily_rate]).to eq(daily_rate)
    end

    it 'calculates subtotal correctly' do
      expect(result[:subtotal_rent]).to eq(Money.new(90000, "MXN"))
    end

    it 'sets additional charges to zero' do
      expect(result[:additional_charges]).to eq(Money.new(0, "MXN"))
    end

    it 'sets discounts to zero' do
      expect(result[:discounts]).to eq(Money.new(0, "MXN"))
    end

    it 'calculates taxes correctly (16% IVA)' do
      expect(result[:taxes]).to eq(Money.new(14400, "MXN"))
    end

    it 'calculates total amount correctly' do
      expect(result[:total_amount]).to eq(Money.new(104400, "MXN"))
    end
  end

  context 'with different date ranges' do
    let(:booking) do
      create(:booking,
        car: car,
        start_date: Date.today + 1.day,
        end_date: Date.today + 2.days
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
      expect(result[:subtotal_rent]).to eq(Money.new(180000, "MXN"))
      expect(result[:taxes]).to eq(Money.new(28800, "MXN"))
      expect(result[:total_amount]).to eq(Money.new(208800, "MXN"))
    end
  end

  context 'with datetime values' do
    let(:booking) do
      create(:booking,
        car: car,
        start_date: Date.today + 1.day,
        end_date: Date.today + 10.days
      )
    end

    it 'calculates rental days correctly ignoring time' do
      result = calculator.calculate
      expect(result[:rental_days]).to eq(9)
    end
  end
end
