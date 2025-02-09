require 'rails_helper'

RSpec.describe Dashboard::BookingExtensionsController, type: :controller do
  let(:host) { create(:user, :host) }
  let(:customer) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }
  let(:car) { create(:car, user: host, status: :available) }
  let(:booking) { create(:booking, :confirmed, car: car, driver: customer) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let(:valid_attributes) {
      attributes_for(:booking_extension,
        start_date: booking.end_date + 1.day,
        end_date: booking.end_date + 3.days
      )
    }

    let(:invalid_attributes) {
      attributes_for(:booking_extension,
        start_date: booking.end_date - 1.day,
        end_date: booking.end_date + 1.day
      )
    }

    context 'when user is not authenticated' do
      it 'redirects to login page' do
        post :create, params: { booking_id: booking.id, booking_extension: valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is not the booking owner' do
      before do
        sign_in other_customer
      end

      it 'raises RecordNotFound' do
        expect {
          post :create, params: { booking_id: booking.id, booking_extension: valid_attributes }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is the booking owner' do
      before do
        sign_in customer
        allow_any_instance_of(BookingExtensionPolicy).to receive(:create?).and_return(true)
      end

      context 'with valid params' do
        it 'creates a new BookingExtension' do
          expect {
            post :create, params: { booking_id: booking.id, booking_extension: valid_attributes }
          }.to change(BookingExtension, :count).by(1)
        end

        it 'redirects to the booking with notice' do
          post :create, params: { booking_id: booking.id, booking_extension: valid_attributes }
          expect(response).to redirect_to(dashboard_booking_path(booking))
          expect(flash[:notice]).to be_present
        end

        it 'sets correct attributes' do
          post :create, params: { booking_id: booking.id, booking_extension: valid_attributes }
          extension = BookingExtension.last
          expect(extension.start_date.to_date).to eq(valid_attributes[:start_date].to_date)
          expect(extension.end_date.to_date).to eq(valid_attributes[:end_date].to_date)
        end
      end

      context 'with invalid params' do
        it 'does not create a new BookingExtension' do
          expect {
            post :create, params: { booking_id: booking.id, booking_extension: invalid_attributes }, as: :turbo_stream
          }.not_to change(BookingExtension, :count)
        end

        it 'returns turbo_stream response with form' do
          post :create, params: { booking_id: booking.id, booking_extension: invalid_attributes }, as: :turbo_stream
          expect(response.media_type).to eq Mime[:turbo_stream]
          expect(response.body).to include('booking_extension_form')
        end
      end

      context 'when car is not available' do
        before do
          booking.car.update(status: :unavailable)
        end

        it 'does not create a booking extension' do
          expect {
            post :create, params: { booking_id: booking.id, booking_extension: valid_attributes }, as: :turbo_stream
          }.not_to change(BookingExtension, :count)
        end
      end

      context 'when dates overlap with existing extension' do
        let!(:existing_extension) {
          create(:booking_extension,
            booking: booking,
            start_date: booking.end_date + 1.day,
            end_date: booking.end_date + 3.days
          )
        }

        let(:overlapping_attributes) {
          attributes_for(:booking_extension,
            start_date: existing_extension.start_date,
            end_date: existing_extension.end_date
          )
        }

        it 'does not create a booking extension' do
          expect {
            post :create, params: { booking_id: booking.id, booking_extension: overlapping_attributes }, as: :turbo_stream
          }.not_to change(BookingExtension, :count)
        end

        it 'returns error in form' do
          post :create, params: { booking_id: booking.id, booking_extension: overlapping_attributes }, as: :turbo_stream
          expect(response.body).to include('turbo-stream')
        end
      end
    end
  end
end
