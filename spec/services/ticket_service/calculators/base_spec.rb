require 'rails_helper'

RSpec.describe TicketService::Calculators::Base do
  let(:booking) { create(:booking) }
  subject(:calculator) { described_class.new(booking) }

  describe '#initialize' do
    it 'sets the ticketable attribute' do
      expect(calculator.instance_variable_get(:@ticketable)).to eq(booking)
    end
  end

  describe '#calculate' do
    it 'raises a not implemented error' do
      expect { calculator.calculate }.to raise_error(RuntimeError, 'Not implemented')
    end
  end

  describe 'private methods' do
    describe '#ticketable' do
      it 'returns the ticketable object' do
        expect(calculator.send(:ticketable)).to eq(booking)
      end
    end
  end

  describe 'inheritance behavior' do
    let(:child_class) do
      Class.new(described_class) do
        def calculate
          'Custom calculation'
        end
      end
    end

    it 'allows child classes to override calculate method' do
      child_calculator = child_class.new(booking)
      expect(child_calculator.calculate).to eq('Custom calculation')
    end

    it 'maintains access to ticketable in child classes' do
      child_calculator = child_class.new(booking)
      expect(child_calculator.send(:ticketable)).to eq(booking)
    end
  end
end
