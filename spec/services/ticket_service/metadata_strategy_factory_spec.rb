require 'rails_helper'

RSpec.describe TicketService::MetadataStrategyFactory do
  describe '.for' do
    let(:booking) { create(:booking) }
    let(:booking_extension) { create(:booking_extension) }

    context 'when a specific strategy exists' do
      before do
        stub_const('TicketService::MetadataStrategies::Booking', Class.new do
          def initialize(ticketable); end
        end)

        stub_const('TicketService::MetadataStrategies::BookingExtension', Class.new do
          def initialize(ticketable); end
        end)
      end

      it 'returns the corresponding strategy for Booking' do
        strategy = described_class.for(booking)
        expect(strategy).to be_a(TicketService::MetadataStrategies::Booking)
      end

      it 'returns the corresponding strategy for BookingExtension' do
        strategy = described_class.for(booking_extension)
        expect(strategy).to be_a(TicketService::MetadataStrategies::BookingExtension)
      end
    end

    context 'when no specific strategy exists' do
      before do
        hide_const('TicketService::MetadataStrategies::Booking')
        hide_const('TicketService::MetadataStrategies::BookingExtension')
      end

      it 'returns the base strategy' do
        strategy = described_class.for(booking)
        expect(strategy).to be_a(TicketService::MetadataStrategies::Base)
      end
    end

    context 'when there is an error loading the strategy' do
      before do
        allow_any_instance_of(String).to receive(:safe_constantize).and_raise(NameError)
      end

      it 'raises an appropriate error' do
        expect {
          described_class.for(booking)
        }.to raise_error(RuntimeError)
      end
    end

    context 'with invalid ticketable objects' do
      let(:invalid_object) { double('InvalidObject', class: Class.new { def name; 'Invalid'; end }) }

      it 'falls back to base strategy' do
        strategy = described_class.for(invalid_object)
        expect(strategy).to be_a(TicketService::MetadataStrategies::Base)
      end
    end

    context 'when there is an unexpected error' do
      before do
        allow_any_instance_of(String).to receive(:safe_constantize).and_raise(StandardError, "Unexpected error")
      end

      it 'raises a ticketable type not supported error' do
        expect {
          described_class.for(booking)
        }.to raise_error(RuntimeError)
      end
    end
  end
end
