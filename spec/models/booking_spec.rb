require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:car) }
    it { should belong_to(:driver).class_name('User') }
    it { should have_many(:booking_extensions).dependent(:destroy) }
    it { should have_many(:tickets).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_numericality_of(:total_price).is_greater_than(0) }
    it { should monetize(:total_price) }
    it { should define_enum_for(:status).with_values(pending: 0, confirmed: 1, cancelled: 2).with_prefix }
  end

  describe 'custom validations' do
    let(:host) { create(:user, :host) }
    let(:customer) { create(:user, :customer) }
    let(:car) { create(:car, user: host, status: :available) }
    let(:booking) { build(:booking, car: car, driver: customer) }

    context 'driver_cannot_be_car_owner validation' do
      it 'is valid when driver is not the car owner' do
        expect(booking).to be_valid
      end

      it 'is invalid when driver is the car owner' do
        booking.driver = host
        expect(booking).not_to be_valid
        expect(booking.errors[:driver]).to include('no puede reservar su propio auto')
      end
    end
  end

  describe 'callbacks' do
    let(:host) { create(:user, :host) }
    let(:customer) { create(:user, :customer) }
    let(:car) { create(:car, user: host, status: :available, daily_rate: Money.new(10000)) }
    let(:booking) {
      build(:booking,
        car: car,
        driver: customer,
        start_date: 1.day.from_now,
        end_date: 3.days.from_now
      )
    }

    it 'calculates total price before validation on create' do
      rental_days = (booking.end_date.to_date - booking.start_date.to_date).to_i
      expected_price = booking.car.daily_rate * rental_days

      booking.save
      expect(booking.total_price).to eq(expected_price)
    end
  end

  describe 'instance methods' do
    let(:booking) { create(:booking) }

    describe '#cancelled!' do
      it 'updates status to cancelled' do
        booking.cancelled!
        expect(booking.reload).to be_status_cancelled
      end
    end

    describe '#confirmed!' do
      it 'updates status to confirmed' do
        booking.confirmed!
        expect(booking.reload).to be_status_confirmed
      end
    end
  end

  describe 'validaciones' do
    let!(:user) { create(:user) }
    let!(:car) { create(:car, status: :available) }
    let(:valid_attributes) do
      {
        driver: user,
        car: car,
        start_date: Date.tomorrow,
        end_date: Date.tomorrow + 3.days,
        status: :pending
      }
    end

    context 'cuando el usuario ya tiene una reserva activa' do
      before do
        create(:booking, driver: user, status: :confirmed, car: car)
      end

      it 'no permite crear una nueva reserva' do
        booking = Booking.new(valid_attributes)
        expect(booking.save).to be_falsey
        expect(booking.errors[:base]).to include("Ya tienes una reserva activa o pendiente. No puedes crear otra hasta que finalice o canceles la actual.")
      end
    end

    context 'cuando el usuario ya tiene una reserva pendiente' do
      before do
        create(:booking, driver: user, status: :pending, car: car)
      end

      it 'no permite crear una nueva reserva' do
        booking = Booking.new(valid_attributes)
        expect(booking.save).to be_falsey
        expect(booking.errors[:base]).to include("Ya tienes una reserva activa o pendiente. No puedes crear otra hasta que finalice o canceles la actual.")
      end
    end

    context 'cuando el usuario tiene una reserva cancelada' do
      before do
        create(:booking, driver: user, status: :cancelled, car: car)
      end

      it 'permite crear una nueva reserva' do
        booking = Booking.new(valid_attributes)
        expect(booking.save).to be_truthy
      end
    end

    context 'cuando el usuario no tiene reservas previas' do
      it 'permite crear una nueva reserva' do
        booking = Booking.new(valid_attributes)
        expect(booking.save).to be_truthy
      end
    end
  end
end
