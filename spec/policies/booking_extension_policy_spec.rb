require 'rails_helper'

RSpec.describe BookingExtensionPolicy do
  subject { described_class.new(user, booking_extension) }

  let(:host) { create(:user, :host) }
  let(:customer) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }
  let(:car) { create(:car, user: host) }
  let(:booking) { create(:booking, car: car, driver: customer) }
  let(:booking_extension) { build(:booking_extension, booking: booking) }

  describe 'permissions' do
    context 'when user is not authenticated' do
      let(:user) { nil }

      it { is_expected.to forbid_action(:create) }
    end

    context 'when user is the booking owner' do
      let(:user) { customer }

      context 'with a pending booking' do
        let(:booking) { create(:booking, car: car, driver: customer, status: :pending) }

        it { is_expected.to permit_action(:create) }
      end

      context 'with a confirmed booking' do
        let(:booking) { create(:booking, car: car, driver: customer, status: :confirmed) }

        it { is_expected.to permit_action(:create) }
      end

      context 'with a cancelled booking' do
        let(:booking) { create(:booking, car: car, driver: customer, status: :cancelled) }

        it { is_expected.to forbid_action(:create) }
      end
    end

    context 'when user is another customer' do
      let(:user) { other_customer }

      context 'with a pending booking' do
        let(:booking) { create(:booking, car: car, driver: customer, status: :pending) }

        it { is_expected.to forbid_action(:create) }
      end

      context 'with a confirmed booking' do
        let(:booking) { create(:booking, car: car, driver: customer, status: :confirmed) }

        it { is_expected.to forbid_action(:create) }
      end
    end

    context 'when user is the host' do
      let(:user) { host }

      context 'with a pending booking' do
        let(:booking) { create(:booking, car: car, driver: customer, status: :pending) }

        it { is_expected.to forbid_action(:create) }
      end

      context 'with a confirmed booking' do
        let(:booking) { create(:booking, car: car, driver: customer, status: :confirmed) }

        it { is_expected.to forbid_action(:create) }
      end
    end
  end
end
