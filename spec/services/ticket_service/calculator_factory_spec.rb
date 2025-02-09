require 'rails_helper'

RSpec.describe TicketService::CalculatorFactory do
  describe '.for' do
    let(:booking) { create(:booking) }
    let(:booking_extension) { create(:booking_extension) }

    let(:valid_calculation) do
      {
        issue_date: Time.current,
        rental_days: 3,
        daily_rate: Money.new(10000),
        subtotal_rent: Money.new(30000),
        additional_charges: Money.new(0),
        discounts: Money.new(0),
        taxes: Money.new(4800),
        total_amount: Money.new(34800)
      }
    end

    context 'when a specific calculator exists' do
      before do
        stub_const('TicketService::Calculators::Booking', Class.new do
          def initialize(ticketable)
            @ticketable = ticketable
          end

          def calculate
            {
              issue_date: Time.current,
              rental_days: 3,
              daily_rate: Money.new(10000),
              subtotal_rent: Money.new(30000),
              additional_charges: Money.new(0),
              discounts: Money.new(0),
              taxes: Money.new(4800),
              total_amount: Money.new(34800)
            }
          end
        end)

        stub_const('TicketService::Calculators::BookingExtension', Class.new do
          def initialize(ticketable)
            @ticketable = ticketable
          end

          def calculate
            {
              issue_date: Time.current,
              rental_days: 3,
              daily_rate: Money.new(10000),
              subtotal_rent: Money.new(30000),
              additional_charges: Money.new(0),
              discounts: Money.new(0),
              taxes: Money.new(4800),
              total_amount: Money.new(34800)
            }
          end
        end)
      end

      it 'returns the corresponding calculator for Booking' do
        calculator = described_class.for(booking)
        expect(calculator).to be_a(TicketService::Calculators::Booking)
      end

      it 'returns the corresponding calculator for BookingExtension' do
        calculator = described_class.for(booking_extension)
        expect(calculator).to be_a(TicketService::Calculators::BookingExtension)
      end
    end

    context 'when no specific calculator exists' do
      before do
        hide_const('TicketService::Calculators::Booking')
        hide_const('TicketService::Calculators::BookingExtension')

        stub_const('TicketService::Calculators::Base', Class.new do
          def initialize(ticketable)
            @ticketable = ticketable
          end

          def calculate
            {
              issue_date: Time.current,
              rental_days: 3,
              daily_rate: Money.new(10000),
              subtotal_rent: Money.new(30000),
              additional_charges: Money.new(0),
              discounts: Money.new(0),
              taxes: Money.new(4800),
              total_amount: Money.new(34800)
            }
          end
        end)
      end

      it 'returns the base calculator' do
        calculator = described_class.for(booking)
        expect(calculator).to be_a(TicketService::Calculators::Base)
      end
    end

    context 'when there is an error loading the calculator' do
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

      before do
        stub_const('TicketService::Calculators::Base', Class.new do
          def initialize(ticketable)
            @ticketable = ticketable
          end

          def calculate
            {
              issue_date: Time.current,
              rental_days: 3,
              daily_rate: Money.new(10000),
              subtotal_rent: Money.new(30000),
              additional_charges: Money.new(0),
              discounts: Money.new(0),
              taxes: Money.new(4800),
              total_amount: Money.new(34800)
            }
          end
        end)
      end

      it 'falls back to base calculator' do
        calculator = described_class.for(invalid_object)
        expect(calculator).to be_a(TicketService::Calculators::Base)
      end
    end
  end
end
