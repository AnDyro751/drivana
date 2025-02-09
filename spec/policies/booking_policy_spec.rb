require 'rails_helper'

RSpec.describe BookingPolicy do
  subject { described_class.new(user, booking) }

  let(:host) { create(:user, :host) }
  let(:customer) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }
  let(:car) { create(:car, user: host) }
  let(:booking) { create(:booking, car: car, driver: customer) }

  context 'when user is not authenticated' do
    let(:user) { nil }

    context 'for instance actions' do
      it { is_expected.to forbid_actions(%i[show ticket cancel extend]) }
    end

    context 'for class actions' do
      subject { described_class.new(user, Booking) }
      it { is_expected.to permit_actions(%i[index]) }
    end
  end

  context 'when user is a customer' do
    context 'when is the booking owner' do
      let(:user) { customer }

      context 'with a pending booking' do
        let(:booking) { create(:booking, car: car, driver: customer) }
        it { is_expected.to permit_actions(%i[show ticket cancel]) }
      end

      context 'with a confirmed booking' do
        let(:booking) { create(:booking, :confirmed, car: car, driver: customer) }
        it { is_expected.to permit_actions(%i[show ticket extend]) }
      end

      context 'with a cancelled booking' do
        let(:booking) { create(:booking, :cancelled, car: car, driver: customer) }
        it { is_expected.to permit_actions(%i[show ticket]) }
        it { is_expected.to forbid_actions(%i[cancel extend]) }
      end
    end

    context 'when is not the booking owner' do
      let(:user) { other_customer }

      it { is_expected.to forbid_actions(%i[show ticket cancel extend]) }
    end

    context 'for class actions' do
      let(:booking) { create(:booking, car: car, driver: customer) }
      subject { described_class.new(user, booking) }
      let(:user) { customer }

      it { is_expected.to forbid_actions(%i[create]) }
      it { is_expected.to permit_actions(%i[index]) }
    end
  end
end
