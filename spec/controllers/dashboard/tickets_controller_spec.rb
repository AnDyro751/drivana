require 'rails_helper'

RSpec.describe Dashboard::TicketsController, type: :controller do
  let(:host) { create(:user, :host) }
  let(:customer) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }
  let(:booking) { create(:booking, driver: customer) }
  let(:ticket) { create(:ticket, ticketable: booking) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET #show' do
    context 'when user is not authenticated' do
      it 'redirects to login page' do
        get :show, params: { id: ticket.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      context 'when user is the ticket owner (customer)' do
        before do
          sign_in customer
          allow_any_instance_of(TicketPolicy).to receive(:show?).and_return(true)
        end

        it 'returns a success response when authorized' do
          get :show, params: { id: ticket.id }
          expect(response).to be_successful
        end
      end
    end
  end
end
