class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :created_at

  attribute :role do |user|
    user.role
  end
end
