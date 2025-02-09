require 'rails_helper'

RSpec.describe CarsQuery do
  describe '.for_user' do
    let!(:host) { create(:user, :host) }
    let!(:another_host) { create(:user, :host) }
    let!(:customer) { create(:user, :customer) }

    let!(:host_available_car) { create(:car, :available, user: host) }
    let!(:host_unavailable_car) { create(:car, :unavailable, user: host) }
    let!(:another_host_available_car) { create(:car, :available, user: another_host) }
    let!(:another_host_unavailable_car) { create(:car, :unavailable, user: another_host) }

    context 'when user is a host' do
      it 'returns only their own cars' do
        result = described_class.for_user(host)

        expect(result).to include(host_available_car, host_unavailable_car)
        expect(result).not_to include(another_host_available_car, another_host_unavailable_car)
        expect(result.count).to eq(2)
      end

      it 'returns an empty collection if host has no cars' do
        new_host = create(:user, :host)
        result = described_class.for_user(new_host)

        expect(result).to be_empty
      end
    end

    context 'when user is a customer' do
      it 'returns only available cars from all hosts' do
        result = described_class.for_user(customer)

        expect(result).to include(host_available_car, another_host_available_car)
        expect(result).not_to include(host_unavailable_car, another_host_unavailable_car)
        expect(result.count).to eq(2)
      end

      it 'returns an empty collection if no cars are available' do
        Car.status_available.update_all(status: :unavailable)
        result = described_class.for_user(customer)

        expect(result).to be_empty
      end
    end

    context 'when user has an invalid role' do
      it 'returns none' do
        user = build_stubbed(:user)
        allow(user).to receive(:role).and_return('invalid_role')

        result = described_class.for_user(user)
        expect(result).to be_empty
      end
    end
  end
end
