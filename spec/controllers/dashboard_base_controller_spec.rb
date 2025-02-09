require 'rails_helper'

RSpec.describe DashboardBaseController, type: :controller do
  controller do
    def index
      authorize :dashboard
      policy_scope(:dashboard)
      render plain: "OK"
    end
  end

  describe "authentication" do
    it "redirects to sign in when user is not authenticated" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    it "allows access when user is authenticated" do
      user = create(:user)
      sign_in user
      get :index
      expect(response).to be_successful
    end
  end


  describe "authorization" do
    let(:user) { create(:user) }

    before { sign_in user }

    context "when action is not authorized" do
      controller do
        def index
          authorize :dashboard, :invalid?
          render plain: "OK"
        end
      end

      class DashboardPolicy
        def invalid?
          false
        end
      end

      it "redirects back with error message" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("No tienes permiso para realizar esta acción.")
      end
    end
  end
end
