require 'rails_helper'

RSpec.describe UserSerializer do
  let(:user) { create(:user) }
  let(:serializer) { described_class.new(user) }
  let(:serialization) { JSON.parse(serializer.to_json) }

  it 'includes the expected attributes' do
    expect(serialization['data']['attributes']).to include(
      'id' => user.id,
      'email' => user.email,
      'created_at' => user.created_at.as_json,
      'role' => user.role
    )
  end

  context 'when user has different roles' do
    let(:host_user) { create(:user, :host) }
    let(:host_serializer) { described_class.new(host_user) }
    let(:host_serialization) { JSON.parse(host_serializer.to_json) }

    it 'correctly serializes the role attribute' do
      expect(host_serialization['data']['attributes']['role']).to eq('host')
    end
  end
end
