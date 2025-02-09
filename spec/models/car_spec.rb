require 'rails_helper'

RSpec.describe Car, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:car) }

    it { should validate_presence_of(:brand) }
    it { should validate_presence_of(:model) }
    it { should validate_presence_of(:year) }

    it { should validate_length_of(:brand).is_at_most(100) }
    it { should validate_length_of(:model).is_at_most(100) }
  end

  describe 'year validations' do
    let(:car) { build(:car) }

    it 'is invalid with a non-numeric year' do
      car.year = 'abcd'
      expect(car).not_to be_valid
      expect(car.errors[:year]).to include("debe estar entre 1900 y #{Time.current.year + 1}")
    end

    it 'is invalid with a year before 1900' do
      car.year = 1899
      expect(car).not_to be_valid
      expect(car.errors[:year]).to include("debe estar entre 1900 y #{Time.current.year + 1}")
    end

    it 'is invalid with a year after next year' do
      car.year = Time.current.year + 2
      expect(car).not_to be_valid
      expect(car.errors[:year]).to include("debe estar entre 1900 y #{Time.current.year + 1}")
    end

    it 'is valid with a year between 1900 and next year' do
      car.year = Time.current.year
      expect(car).to be_valid
    end
  end

  describe 'money-rails' do
    it { should monetize(:daily_rate_cents) }

    it 'validates daily_rate is greater than 0' do
      car = build(:car, daily_rate: 0)
      expect(car).not_to be_valid
      expect(car.errors[:daily_rate]).to include('debe estar entre 1 y 50,000 MXN')
    end

    it 'validates daily_rate is less than 50,000' do
      car = build(:car, daily_rate: 50_001)
      expect(car).not_to be_valid
      expect(car.errors[:daily_rate]).to include('debe estar entre 1 y 50,000 MXN')
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(available: 0, unavailable: 1).with_prefix(true) }
  end

  describe 'user_is_host validation' do
    context 'when user is a host' do
      let(:host) { create(:user, :host) }

      it 'is valid' do
        car = build(:car, user: host)
        expect(car).to be_valid
      end
    end

    context 'when user is a customer' do
      let(:customer) { create(:user, :customer) }

      it 'is invalid' do
        car = build(:car, user: customer)
        expect(car).not_to be_valid
        expect(car.errors[:user]).to include('must be a host')
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:car)).to be_valid
    end

    it 'has a valid factory for available status' do
      expect(build(:car, :available)).to be_valid
    end

    it 'has a valid factory for unavailable status' do
      expect(build(:car, :unavailable)).to be_valid
    end
  end
end
