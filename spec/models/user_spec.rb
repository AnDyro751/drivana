require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:bookings).with_foreign_key(:driver_id).dependent(:destroy) }
    it { should have_many(:cars).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe '#jwt_payload' do
    let(:user) { create(:user, :customer, email: 'test@example.com') }

    it 'returns a hash with user information' do
      payload = user.jwt_payload

      expect(payload).to be_a(Hash)
      expect(payload).to include(
        'role' => 'customer',
        'email' => 'test@example.com'
      )
    end

    context 'when user is a host' do
      let(:user) { create(:user, :host, email: 'host@example.com') }

      it 'returns correct role in payload' do
        payload = user.jwt_payload

        expect(payload['role']).to eq('host')
        expect(payload['email']).to eq('host@example.com')
      end
    end

    context 'when user is a customer' do
      let(:user) { create(:user, :customer, email: 'customer@example.com') }

      it 'returns correct role in payload' do
        payload = user.jwt_payload

        expect(payload['role']).to eq('customer')
        expect(payload['email']).to eq('customer@example.com')
      end
    end
  end
end
