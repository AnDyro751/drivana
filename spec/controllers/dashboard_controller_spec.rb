require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe "GET #index" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "returns successful response" do
        get :index
        expect(response).to be_successful
      end

      context "with different user roles" do
        it "allows access to customer users" do
          user = create(:user, :customer)
          sign_in user
          get :index
          expect(response).to be_successful
        end

        it "allows access to host users" do
          user = create(:user, :host)
          sign_in user
          get :index
          expect(response).to be_successful
        end
      end
    end
  end
end
