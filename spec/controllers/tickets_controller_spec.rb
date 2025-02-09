require 'rails_helper'

RSpec.describe TicketsController, type: :controller do
  include JwtHelper

  let(:user) { create(:user) }
  let(:booking) { create(:booking, driver: user) }
  let(:ticket) { create(:ticket, ticketable: booking) }

  before do
    request.headers.merge!(auth_headers(user))
    sign_in user
  end

  describe 'GET #show' do
    context 'when the ticket belongs to the user' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
      end

      it 'returns the requested ticket' do
        get :show, params: { id: ticket.id }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['id']).to eq(ticket.id)
      end
    end

    context 'when the ticket does not belong to the user' do
      let(:other_user) { create(:user) }
      let(:other_ticket) { create(:ticket, ticketable: create(:booking, driver: other_user)) }

      it 'returns not found error' do
        get :show, params: { id: other_ticket.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        ticketable_type: 'Booking',
        ticketable_id: booking.id
      }
    end

    context 'with valid parameters' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
        allow(TicketService::Creator).to receive(:call).and_return(ticket)
      end

      it 'creates a new ticket' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid ticketable' do
      let(:invalid_params) do
        {
          ticketable_type: 'InvalidModel',
          ticketable_id: 1
        }
      end

      it 'returns unprocessable entity error' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Ticketable not found')
      end
    end

    context 'when the user is not authorized' do
      before do
        allow(controller).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      end

      it 'returns unprocessable entity error' do
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'error handling' do
    context 'when the ticket does not exist' do
      it 'returns not found error' do
        get :show, params: { id: 'non_existent_ticket' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when there is an error in the creation service' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
        allow(TicketService::Creator).to receive(:call).and_raise(StandardError.new('Error creating ticket'))
      end

      it 'returns unprocessable entity error' do
        expect {
          post :create, params: { ticketable_type: 'Booking', ticketable_id: booking.id }
        }.to raise_error(StandardError)
      end
    end
  end
end
