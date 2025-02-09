require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#status_badge' do
    it 'returns a span with the correct base classes' do
      expect(helper.status_badge('test')).to have_css('span.px-3.py-1.rounded-full.text-white')
    end

    it 'uses bg-gray-500 variant by default' do
      expect(helper.status_badge('test')).to have_css('span.bg-gray-500')
    end

    context 'when an invalid variant is provided' do
      it 'uses bg-gray-500 variant' do
        expect(helper.status_badge('test', :invalid)).to have_css('span.bg-gray-500')
      end
    end
  end

  describe '#get_badge_variant' do
    it 'returns bg-green-500 for active' do
      expect(helper.get_badge_variant(:active)).to eq('bg-green-500')
    end

    it 'returns bg-blue-500 for pending' do
      expect(helper.get_badge_variant(:pending)).to eq('bg-blue-500')
    end

    it 'returns bg-red-500 for cancelled' do
      expect(helper.get_badge_variant(:cancelled)).to eq('bg-red-500')
    end

    it 'returns bg-red-500 for error' do
      expect(helper.get_badge_variant(:error)).to eq('bg-red-500')
    end

    it 'returns bg-blue-500 for info' do
      expect(helper.get_badge_variant(:info)).to eq('bg-blue-500')
    end

    it 'returns bg-yellow-500 for warning' do
      expect(helper.get_badge_variant(:warning)).to eq('bg-yellow-500')
    end

    it 'returns bg-gray-500 for unknown variants' do
      expect(helper.get_badge_variant(:unknown)).to eq('bg-gray-500')
    end
  end

  describe '#booking_status_badge' do
    it 'returns a success badge for active status' do
      expect(helper.booking_status_badge(:active)).to have_css('span.bg-green-500')
    end

    it 'returns an info badge for pending status' do
      expect(helper.booking_status_badge(:pending)).to have_css('span.bg-blue-500')
    end

    it 'returns an error badge for cancelled status' do
      expect(helper.booking_status_badge(:cancelled)).to have_css('span.bg-red-500')
    end

    it 'returns a warning badge for finished status' do
      expect(helper.booking_status_badge(:finished)).to have_css('span.bg-yellow-500')
    end

    it 'returns a default badge for other statuses' do
      expect(helper.booking_status_badge(:unknown)).to have_css('span.bg-gray-500')
    end
  end
end
