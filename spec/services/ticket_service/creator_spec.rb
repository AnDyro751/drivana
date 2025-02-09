require 'rails_helper'

RSpec.describe TicketService::Creator do
  describe '.call' do
    let(:booking) { create(:booking) }
    let(:calculator) { instance_double('TicketService::Calculators::Base') }
    let(:ticket_attributes) do
      {
        issue_date: Time.current,
        rental_days: 3,
        daily_rate: Money.new(10000),
        subtotal_rent: Money.new(30000),
        additional_charges: Money.new(5000),
        discounts: Money.new(2000),
        taxes: Money.new(5280),
        total_amount: Money.new(38280)
      }
    end

    subject(:service) { described_class.new(ticketable: booking) }

    before do
      allow(TicketService::CalculatorFactory).to receive(:for)
        .with(booking)
        .and_return(calculator)

      allow(calculator).to receive(:calculate)
        .and_return(ticket_attributes)
    end

    context 'when successful' do
      it 'creates a new ticket' do
        expect { service.call }.to change(Ticket, :count).by(1)
      end

      it 'associates the ticket with the ticketable' do
        ticket = service.call
        expect(ticket.ticketable).to eq(booking)
      end

      it 'sets the correct attributes' do
        ticket = service.call
        ticket_attributes.each do |key, value|
          expect(ticket.send(key)).to eq(value)
        end
      end
    end

    context 'when calculator fails' do
      before do
        allow(calculator).to receive(:calculate)
          .and_raise(StandardError.new('Calculator error'))
      end

      it 'raises an error with calculator message' do
        expect { service.call }.to raise_error(
          RuntimeError
        )
      end
    end

    context 'when ticket creation fails' do
      before do
        allow_any_instance_of(Ticket).to receive(:save!)
          .and_raise(ActiveRecord::RecordInvalid.new(Ticket.new))
      end

      it 'raises an error with save message' do
        expect { service.call }.to raise_error(
          RuntimeError,
          /Error creating ticket: Validation failed/
        )
      end
    end
  end
end
