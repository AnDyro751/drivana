require 'rails_helper'

RSpec.describe TicketPolicy do
  subject { described_class.new(user, ticket) }

  let(:host) { create(:user, :host) }
  let(:customer) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }
  let(:booking) { create(:booking, driver: customer) }
  let(:ticket) { create(:ticket, ticketable: booking) }

  describe 'permissions' do
    context 'when user is not authenticated' do
      let(:user) { nil }

      it { is_expected.to forbid_action(:show) }
    end

    context 'when user is the ticket owner (driver of the booking)' do
      let(:user) { customer }

      it { is_expected.to permit_action(:show) }
    end

    context 'when user is another customer' do
      let(:user) { other_customer }

      it { is_expected.to forbid_action(:show) }
    end

    context 'when user is a host' do
      let(:user) { host }

      it { is_expected.to forbid_action(:show) }
    end

    context 'with different ticketable types' do
      let(:booking_extension) { create(:booking_extension, booking: booking) }
      let(:extension_ticket) { create(:ticket, ticketable: booking_extension) }
      let(:user) { customer }

      it 'permits show for ticket from booking extension' do
        policy = described_class.new(user, extension_ticket)
        expect(policy).to permit_action(:show)
      end
    end
  end
end
