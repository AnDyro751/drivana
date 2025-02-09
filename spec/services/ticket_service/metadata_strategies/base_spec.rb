require 'rails_helper'

RSpec.describe TicketService::MetadataStrategies::Base do
  let(:booking) { create(:booking) }
  subject(:strategy) { described_class.new(booking) }

  describe '#initialize' do
    it 'sets the ticketable attribute' do
      expect(strategy.instance_variable_get(:@ticketable)).to eq(booking)
    end
  end

  describe '#build' do
    it 'returns an empty hash by default' do
      expect(strategy.build).to eq({})
    end
  end

  describe 'inheritance behavior' do
    let(:child_class) do
      Class.new(described_class) do
        def build
          {
            car_model: ticketable.car.model,
            driver_name: ticketable.driver.name
          }
        end
      end
    end

    it 'maintains access to ticketable in child classes' do
      child_strategy = child_class.new(booking)
      expect(child_strategy.send(:ticketable)).to eq(booking)
    end
  end

  describe 'private methods' do
    describe '#ticketable' do
      it 'returns the ticketable object' do
        expect(strategy.send(:ticketable)).to eq(booking)
      end
    end
  end

  context 'with different ticketable types' do
    let(:booking_extension) { create(:booking_extension) }

    it 'works with booking extensions' do
      strategy = described_class.new(booking_extension)
      expect(strategy.build).to eq({})
    end

    it 'sets the correct ticketable' do
      strategy = described_class.new(booking_extension)
      expect(strategy.send(:ticketable)).to eq(booking_extension)
    end
  end
end
