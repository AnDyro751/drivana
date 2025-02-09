FactoryBot.define do
  factory :booking_extension do
    association :booking, :confirmed

    start_date { booking.end_date + 1.day }
    end_date { booking.end_date + 3.days }
    total_price { Money.new(30000) }

    trait :with_tickets do
      after(:create) do |extension|
        create(:ticket, ticketable: extension)
      end
    end

    trait :overlapping do
      start_date { booking.end_date - 1.day }
    end

    trait :invalid_dates do
      start_date { booking.end_date - 2.days }
      end_date { booking.end_date - 1.day }
    end
  end
end
