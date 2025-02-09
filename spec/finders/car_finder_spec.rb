require 'rails_helper'

RSpec.describe CarFinder do
  describe '.find_for_user' do
    let(:host) { create(:user, :host) }
    let(:another_host) { create(:user, :host) }
    let(:customer) { create(:user, :customer) }
    let(:car) { create(:car, user: host) }

    context 'when user is a host' do
      it 'finds their own car' do
        result = described_class.find_for_user(user: host, id: car.id)
        expect(result).to eq(car)
      end

      it 'raises RecordNotFound for other host cars' do
        other_car = create(:car, user: another_host)
        expect {
          described_class.find_for_user(user: host, id: other_car.id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises RecordNotFound for non-existent cars' do
        expect {
          described_class.find_for_user(user: host, id: 999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is a customer' do
      it 'finds any existing car' do
        result = described_class.find_for_user(user: customer, id: car.id)
        expect(result).to eq(car)
      end

      it 'raises RecordNotFound for non-existent cars' do
        expect {
          described_class.find_for_user(user: customer, id: 999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user has invalid role' do
      let(:invalid_user) { build_stubbed(:user) }

      before do
        allow(invalid_user).to receive(:role).and_return('invalid_role')
      end

      it 'raises RecordNotFound' do
        expect {
          described_class.find_for_user(user: invalid_user, id: car.id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
