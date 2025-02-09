require 'rails_helper'

RSpec.describe Dashboard::BookingsController, type: :controller do
  let(:host) { create(:user, :host) }
  let(:customer) { create(:user, :customer) }
  let(:car) { create(:car, user: host) }
  let(:booking) { create(:booking, car: car, driver: customer) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before do
        sign_in customer
        allow_any_instance_of(BookingPolicy).to receive(:index?).and_return(true)
      end

      it 'assigns bookings' do
        get :index
        expect(response).to be_successful
      end
    end
  end

  describe 'GET #ticket' do
    context 'when user is not authenticated' do
      it 'redirects to login page' do
        get :ticket, params: { id: booking.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before do
        sign_in customer
        allow_any_instance_of(BookingPolicy).to receive(:ticket?).and_return(true)
      end
    end
  end

  describe 'GET #show' do
    context 'when user is not authenticated' do
      it 'redirects to login page' do
        get :show, params: { id: booking.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before do
        sign_in customer
        allow_any_instance_of(BookingPolicy).to receive(:show?).and_return(true)
      end

      it 'is successful' do
        get :show, params: { id: booking.id }
        expect(response).to be_successful
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { attributes_for(:booking).merge(car_id: car.id) }
    let(:invalid_attributes) { attributes_for(:booking, start_date: nil, car_id: car.id) }

    context 'when user is not authenticated' do
      it 'redirects to login page' do
        post :create, params: { booking: valid_attributes }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before do
        sign_in customer
        allow_any_instance_of(BookingPolicy).to receive(:create?).and_return(true)
      end

      context 'with valid params' do
        it 'creates a new Booking' do
          expect {
            post :create, params: { booking: valid_attributes }
          }.to change(Booking, :count).by(1)
        end

        it 'assigns the current user as driver' do
          post :create, params: { booking: valid_attributes }
          expect(Booking.last.driver).to eq(customer)
        end

        it 'redirects to the created booking' do
          post :create, params: { booking: valid_attributes }
          expect(response).to redirect_to([ :dashboard, Booking.last ])
          expect(flash[:notice]).to be_present
        end

        it 'sets correct attributes' do
          post :create, params: { booking: valid_attributes }
          booking = Booking.last
          expect(booking.car_id).to eq(car.id)
          expect(booking.driver_id).to eq(customer.id)
          expect(booking.start_date).to be_present
          expect(booking.end_date).to be_present
        end
      end

      context 'with invalid params' do
        it 'does not create a new Booking' do
          expect {
            post :create, params: { booking: invalid_attributes }, as: :turbo_stream
          }.not_to change(Booking, :count)
        end

        it 'returns turbo_stream response with form' do
          post :create, params: { booking: invalid_attributes }, as: :turbo_stream
          expect(response.media_type).to eq Mime[:turbo_stream]
          expect(response.body).to include('booking_form')
        end
      end

      context 'with unavailable car' do
        before do
          car.update(status: :unavailable)
        end

        it 'does not create a booking' do
          expect {
            post :create, params: { booking: valid_attributes }, as: :turbo_stream
          }.not_to change(Booking, :count)
        end
      end

      context 'with invalid date range' do
        let(:invalid_dates) {
          attributes_for(:booking,
            start_date: 1.day.from_now,
            end_date: 1.day.ago,
            car_id: car.id
          )
        }

        it 'does not create a booking' do
          expect {
            post :create, params: { booking: invalid_dates }, as: :turbo_stream
          }.not_to change(Booking, :count)
        end
      end
    end
  end

  describe 'DELETE #cancel' do
    context 'when booking is pending' do
      let(:booking) { create(:booking, driver: customer, status: :pending) }

      before do
        sign_in customer
        allow_any_instance_of(BookingPolicy).to receive(:cancel?).and_return(true)
      end

      it 'cancels the booking' do
        delete :cancel, params: { id: booking.id }
        expect(booking.reload).to be_status_cancelled
      end

      it 'redirects with success notice' do
        delete :cancel, params: { id: booking.id }
        expect(response).to redirect_to([ :dashboard, booking ])
        expect(flash[:notice]).to be_present
      end

      it 'raises error when booking is not pending' do
        booking.update(status: :confirmed)
        delete :cancel, params: { id: booking.id }
        expect(response).to redirect_to([ :dashboard, booking ])
        expect(flash[:alert]).to be_present
      end
    end

    context 'when booking is already cancelled' do
      let(:booking) { create(:booking, :cancelled, driver: customer, status: :cancelled) }
      let(:customer_2) { create(:user, :customer) }

      before do
        sign_in customer_2
        allow_any_instance_of(BookingPolicy).to receive(:cancel?).and_return(false)
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          delete :cancel, params: { id: booking.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #extend_booking' do
    context 'when booking is confirmed' do
      let(:booking) { create(:booking, :confirmed, driver: customer) }

      before do
        sign_in customer
        allow_any_instance_of(BookingPolicy).to receive(:extend?).and_return(true)
      end

      it 'returns success response' do
        get :extend_booking, params: { id: booking.id }
        expect(response).to be_successful
      end
    end

    context 'when booking is not confirmed' do
      let(:booking) { create(:booking, driver: customer) }
      let(:customer_2) { create(:user, :customer) }

      before do
        sign_in customer_2
        allow_any_instance_of(BookingPolicy).to receive(:extend?).and_return(false)
      end

      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :extend_booking, params: { id: booking.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #ticket' do
    let(:booking) { create(:booking, driver: customer) }

    before do
      sign_in customer
      allow_any_instance_of(BookingPolicy).to receive(:ticket?).and_return(true)
    end

    it 'returns success response without layout' do
      get :ticket, params: { id: booking.id }
      expect(response).to be_successful
    end
  end
end
