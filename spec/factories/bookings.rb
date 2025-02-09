FactoryBot.define do
  factory :booking do
    association :car
    association :driver, factory: [ :user, :customer ]

    start_date { 1.day.from_now }
    end_date { 3.days.from_now }
    total_price { Money.new(30000) }
    status { :pending }

    trait :confirmed do
      status { :confirmed }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :with_extensions do
      after(:create) do |booking|
        create_list(:booking_extension, 2, booking: booking)
      end
    end

    trait :with_tickets do
      after(:create) do |booking|
        create(:ticket, ticketable: booking)
      end
    end

    trait :with_ticket do
      after(:create) do |booking|
        create(:ticket, ticketable: booking)
      end
    end

    trait :past_booking do
      start_date { 1.week.ago }
      end_date { 4.days.ago }
    end

    trait :future_booking do
      start_date { 1.week.from_now }
      end_date { 10.days.from_now }
    end
  end
end
