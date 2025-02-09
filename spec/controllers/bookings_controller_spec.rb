require 'rails_helper'

RSpec.describe BookingsController, type: :controller do
  include JwtHelper

  let(:user) { create(:user) }
  let(:car) { create(:car) }
  let(:booking) { create(:booking, driver: user, car: car) }
  let(:valid_attributes) do
    {
      car_id: car.id,
      start_date: Date.tomorrow,
      end_date: Date.tomorrow + 3.days
    }
  end

  before do
    request.headers.merge!(auth_headers(user))
    sign_in user
  end

  describe 'GET #show' do
    context 'when the booking belongs to the user' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
      end

      it 'returns the requested booking' do
        get :show, params: { id: booking.id }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['id']).to eq(booking.id)
      end
    end

    context 'when the booking does not exist' do
      it 'returns not found error' do
        get :show, params: { id: 'non_existent_booking' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
        sign_in user
      end

      it 'creates a new booking' do
        expect {
          post :create, params: { booking: valid_attributes }
        }.to change(Booking, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { car_id: car.id, start_date: nil, end_date: nil } }

      it 'does not create a new booking' do
        expect {
          post :create, params: { booking: invalid_attributes }
        }.not_to change(Booking, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #extend_booking' do
    let(:extension_params) do
      {
        booking_extension: {
          start_date: booking.end_date + 1.day,
          end_date: booking.end_date + 4.days
        }
      }
    end

    context 'with valid parameters' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
      end

      it 'creates an extension of the booking' do
        expect {
          post :extend_booking, params: { id: booking.id }.merge(extension_params)
        }.to change(BookingExtension, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_extension_params) do
        {
          booking_extension: {
            start_date: nil,
            end_date: nil
          }
        }
      end

      it 'does not create an extension' do
        expect {
          post :extend_booking, params: { id: booking.id }.merge(invalid_extension_params)
        }.not_to change(BookingExtension, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #tickets' do
    before do
      allow(controller).to receive(:authorize).and_return(true)
      # create(:booking, driver: user, car: car)
    end

    it 'returns the tickets of the booking' do
      get :tickets, params: { id: booking.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe 'GET #consolidated_ticket' do
    before do
      allow(controller).to receive(:authorize).and_return(true)
      create_list(:ticket, 2, ticketable: booking)
    end

    it 'returns the consolidated ticket of the booking' do
      get :consolidated_ticket, params: { id: booking.id }
      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response['booking_id']).to eq(booking.id)
      expect(json_response['tickets']).to be_present
      expect(json_response['total_amount']).to be_present
    end
  end

  describe 'error handling' do
    context 'when the booking does not belong to the user' do
      let(:another_user) { create(:user) }
      let(:another_booking) { create(:booking, driver: another_user) }

      it 'returns not found error' do
        get :show, params: { id: another_booking.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
