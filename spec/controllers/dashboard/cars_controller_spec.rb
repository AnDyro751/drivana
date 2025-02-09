require 'rails_helper'

RSpec.describe Dashboard::CarsController, type: :controller do
  let(:host) { create(:user, :host) }
  let(:customer) { create(:user, :customer) }
  let(:valid_attributes) { attributes_for(:car).merge(user: host) }
  let(:invalid_attributes) { attributes_for(:car, brand: '', user: host) }
  describe 'GET #index' do
    context 'when user is not authenticated' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is a host' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in host
      end

      it 'returns a success response' do
        create(:car, user: host)
        get :index
        expect(response).to be_successful
      end
    end

    context 'when user is a customer' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in customer
      end

      it 'returns a success response' do
        get :index
        expect(response).to be_successful
      end
    end
  end

  describe 'GET #show' do
    let(:car) { create(:car, user: host) }

    context 'when user is a host' do
      before { sign_in host }

      it 'returns a success response for their own car' do
        get :show, params: { id: car.id }
        expect(response).to be_successful
      end

      it 'raises error for other host cars' do
        other_car = create(:car, user: create(:user, :host))
        expect {
          get :show, params: { id: other_car.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is a customer' do
      before { sign_in customer }

      it 'returns a success response for available cars' do
        get :show, params: { id: car.id }
        expect(response).to be_successful
      end
    end
  end

  describe 'GET #reserve' do
    let(:car) { create(:car, user: host) }

    context 'when user is not authenticated' do
      it 'redirects to login page' do
        get :reserve, params: { id: car.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is a customer' do
      before { sign_in customer }

      it 'returns a success response for available cars' do
        get :reserve, params: { id: car.id }
        expect(response).to be_successful
      end
    end

    context 'when user is a host' do
      before { sign_in host }

      it 'redirects to root with alert' do
        get :reserve, params: { id: car.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'GET #new' do
    context 'when user is a host' do
      before { sign_in host }

      it 'returns a success response' do
        get :new
        expect(response).to be_successful
      end
    end

    context 'when user is a customer' do
      before { sign_in customer }

      it 'redirects to root with alert' do
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'POST #create' do
    context 'when user is a host' do
      before { sign_in host }

      context 'with valid params' do
        it 'creates a new Car' do
          expect {
            post :create, params: { car: valid_attributes }
          }.to change(Car, :count).by(1)
        end

        it 'redirects to the created car' do
          post :create, params: { car: valid_attributes }
          expect(response).to redirect_to(dashboard_car_path(Car.last))
        end
      end

      context 'with invalid params' do
        it 'returns a success response (renders new form)' do
          post :create, params: { car: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is a customer' do
      before { sign_in customer }

      it 'does not create a new Car' do
        expect {
          post :create, params: { car: valid_attributes }
        }.not_to change(Car, :count)
      end

      it 'redirects to root with alert' do
        post :create, params: { car: valid_attributes }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
