require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    context "when user is authenticated" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "still allows access to home page" do
        get :index
        expect(response).to have_http_status(:success)
      end

      context "with different roles" do
        it "allows access to customer users" do
          user = create(:user, :customer)
          sign_in user
          get :index
          expect(response).to have_http_status(:success)
        end

        it "allows access to host users" do
          user = create(:user, :host)
          sign_in user
          get :index
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
