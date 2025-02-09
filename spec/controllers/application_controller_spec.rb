require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'index'
    end
  end

  describe 'Pundit integration' do
    it 'includes Pundit::Authorization' do
      expect(controller.class.ancestors).to include(Pundit::Authorization)
    end
  end

  describe '#after_sign_in_path_for' do
    let(:user) { create(:user) }

    it 'redirects to dashboard path' do
      expect(controller.after_sign_in_path_for(user)).to eq(dashboard_path)
    end
  end

  context 'with different user roles' do
    let(:host) { create(:user, :host) }
    let(:customer) { create(:user, :customer) }

    it 'redirects hosts to dashboard after sign in' do
      expect(controller.after_sign_in_path_for(host)).to eq(dashboard_path)
    end

    it 'redirects customers to dashboard after sign in' do
      expect(controller.after_sign_in_path_for(customer)).to eq(dashboard_path)
    end
  end

  context 'with invalid user' do
    it 'still redirects to dashboard path' do
      expect(controller.after_sign_in_path_for(nil)).to eq(dashboard_path)
    end
  end
end
