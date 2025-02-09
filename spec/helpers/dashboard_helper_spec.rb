require 'rails_helper'

RSpec.describe DashboardHelper, type: :helper do
  let(:host) { create(:user, :host) }
  let(:customer) { create(:user, :customer) }
  let(:car) { create(:car, user: host) }

  describe '#navigation_menu_items' do
    context 'when user is a host' do
      before do
        allow(helper).to receive(:current_user).and_return(host)
        allow(helper).to receive(:controller_name).and_return('dashboard')
      end

      it 'includes the vehicles section' do
        menu_items = helper.navigation_menu_items
        expect(menu_items.map { |item| item[:title] }).to include('Mis Vehículos')
      end

      it 'marks the active item correctly' do
        menu_items = helper.navigation_menu_items
        expect(menu_items.find { |item| item[:title] == 'Dashboard' }[:active]).to be true
      end

      it 'includes all necessary items' do
        menu_items = helper.navigation_menu_items
        expect(menu_items.length).to eq(3)
      end
    end

    context 'when user is a customer' do
      before do
        allow(helper).to receive(:current_user).and_return(customer)
      end

      it 'does not include the vehicles section' do
        menu_items = helper.navigation_menu_items
        expect(menu_items.map { |item| item[:title] }).not_to include('Mis Vehículos')
      end

      it 'includes only basic items' do
        menu_items = helper.navigation_menu_items
        expect(menu_items.length).to eq(2)
      end
    end
  end

  describe '#render_icon' do
    it 'renders the home icon' do
      expect(helper.render_icon('home')).to include('svg')
      expect(helper.render_icon('home')).to include('viewBox="0 0 20 20"')
    end

    it 'renders the car icon' do
      expect(helper.render_icon('car')).to include('svg')
      expect(helper.render_icon('car')).to include('viewBox="0 0 20 20"')
    end

    it 'renders the calendar icon' do
      expect(helper.render_icon('calendar')).to include('svg')
      expect(helper.render_icon('calendar')).to include('viewBox="0 0 128 128"')
    end
  end

  describe '#user_has_active_booking?' do
    context 'when user has a pending booking' do
      let!(:booking) { create(:booking, car: car, driver: customer, status: :pending) }

      it 'returns true' do
        expect(helper.user_has_active_booking?(car, customer)).to be true
      end
    end

    context 'when user has a confirmed booking' do
      let!(:booking) { create(:booking, car: car, driver: customer, status: :confirmed) }

      it 'returns true' do
        expect(helper.user_has_active_booking?(car, customer)).to be true
      end
    end

    context 'when user has no active bookings' do
      let!(:booking) { create(:booking, car: car, driver: customer, status: :cancelled) }

      it 'returns false' do
        expect(helper.user_has_active_booking?(car, customer)).to be false
      end
    end
  end

  describe '#get_active_booking' do
    context 'when user has an active booking' do
      let!(:booking) { create(:booking, car: car, driver: customer, status: :pending) }

      it 'returns the active booking' do
        expect(helper.get_active_booking(car, customer)).to eq(booking)
      end
    end

    context 'when user has no active bookings' do
      let!(:booking) { create(:booking, car: car, driver: customer, status: :cancelled) }

      it 'returns nil' do
        expect(helper.get_active_booking(car, customer)).to be_nil
      end
    end

    context 'when there are multiple bookings' do
      let!(:cancelled_booking) { create(:booking, car: car, driver: customer, status: :cancelled) }
      let!(:pending_booking) { create(:booking, car: car, driver: customer, status: :pending) }

      it 'returns the first active booking' do
        expect(helper.get_active_booking(car, customer)).to eq(pending_booking)
      end
    end
  end
end
