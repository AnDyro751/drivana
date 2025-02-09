FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { "customer" }

    trait :host do
      role { "host" }
    end

    trait :customer do
      role { "customer" }
    end
  end
end
