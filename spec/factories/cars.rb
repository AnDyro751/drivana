FactoryBot.define do
  factory :car do
    brand { "Toyota" }
    model { "Corolla" }
    year { Time.current.year }
    daily_rate { 1000 }
    status { :available }
    association :user, factory: [ :user, :host ]

    trait :available do
      status { :available }
    end

    trait :unavailable do
      status { :unavailable }
    end
  end
end
