require 'rails_helper'

RSpec.describe BookingExtension, type: :model do
  describe 'associations' do
    it { should belong_to(:booking) }
    it { should have_many(:tickets).dependent(:destroy) }
  end

  describe 'delegations' do
    let(:booking_extension) { create(:booking_extension) }

    it 'delegates driver to booking' do
      expect(booking_extension.driver).to eq(booking_extension.booking.driver)
    end

    it 'delegates car to booking' do
      expect(booking_extension.car).to eq(booking_extension.booking.car)
    end
  end

  describe 'validations' do
    it { should monetize(:total_price) }
    it { should validate_numericality_of(:total_price).is_greater_than(0) }

    describe 'date validations' do
      let(:booking) { create(:booking, :confirmed) }
      let(:extension) { build(:booking_extension, booking: booking) }

      it 'is valid with valid dates' do
        expect(extension).to be_valid
      end

      it 'is invalid when start_date is before booking end_date' do
        extension.start_date = booking.end_date - 1.day
        extension.valid?
        expect(extension).not_to be_valid
      end

      it 'is invalid when start_date is after end_date' do
        extension.start_date = extension.end_date + 1.day
        expect(extension).not_to be_valid
      end
    end

    describe 'car availability validation' do
      let(:booking) { create(:booking, :confirmed) }
      let(:extension) { build(:booking_extension, booking: booking) }

      it 'is valid when car is available' do
        booking.car.update(status: :available)
        expect(extension).to be_valid
      end

      it 'is invalid when car is not available' do
        booking.car.update(status: :unavailable)
        extension.valid?
        expect(extension).not_to be_valid
        expect(extension.errors[:booking]).to include(
          "el auto ya no está disponible"
        )
      end
    end

    describe 'overlapping extensions validation' do
      let(:booking) { create(:booking, :confirmed) }
      let!(:existing_extension) {
        create(:booking_extension,
          booking: booking,
          start_date: booking.end_date + 1.day,
          end_date: booking.end_date + 3.days
        )
      }

      context 'when dates overlap with existing extension' do
        it 'is invalid with exact same dates' do
          new_extension = build(:booking_extension,
            booking: booking,
            start_date: existing_extension.start_date,
            end_date: existing_extension.end_date
          )
          expect(new_extension).not_to be_valid
          expect(new_extension.errors[:base]).to include(
            "Ya tienes una extensión para alguna de estas fechas"
          )
        end

        it 'is invalid with partial overlap at start' do
          new_extension = build(:booking_extension,
            booking: booking,
            start_date: existing_extension.start_date - 1.day,
            end_date: existing_extension.start_date + 1.day
          )
          expect(new_extension).not_to be_valid
        end

        it 'is invalid with partial overlap at end' do
          new_extension = build(:booking_extension,
            booking: booking,
            start_date: existing_extension.end_date - 1.day,
            end_date: existing_extension.end_date + 1.day
          )
          expect(new_extension).not_to be_valid
        end

        it 'is invalid when completely contained' do
          new_extension = build(:booking_extension,
            booking: booking,
            start_date: existing_extension.start_date + 1.day,
            end_date: existing_extension.end_date - 1.day
          )
          expect(new_extension).not_to be_valid
        end
      end

      context 'when dates do not overlap' do
        it 'is valid with dates after existing extension' do
          new_extension = build(:booking_extension,
            booking: booking,
            start_date: existing_extension.end_date + 1.day,
            end_date: existing_extension.end_date + 3.days
          )
          expect(new_extension).to be_valid
        end
      end
    end
  end

  describe 'callbacks' do
    let(:booking) { create(:booking, :confirmed) }
    let(:extension) { build(:booking_extension, booking: booking) }

    it 'calculates total price before validation on create' do
      rental_days = (extension.end_date.to_date - extension.start_date.to_date).to_i
      expected_price = extension.car.daily_rate * rental_days

      extension.save
      expect(extension.total_price).to eq(expected_price)
    end
  end
end
