FactoryBot.define do
  factory :ticket do
    association :ticketable, factory: :booking

    issue_date { Time.current }
    rental_days { 3 }
    daily_rate { Money.new(10000) }
    subtotal_rent { Money.new(30000) }
    additional_charges { Money.new(5000) }
    discounts { Money.new(2000) }
    taxes { Money.new(5280) }
    total_amount { Money.new(38280) }

    trait :for_booking do
      association :ticketable, factory: :booking
    end

    trait :for_booking_extension do
      association :ticketable, factory: :booking_extension
    end

    trait :with_high_amount do
      daily_rate { Money.new(20000) }
      subtotal_rent { Money.new(60000) }
      additional_charges { Money.new(10000) }
      discounts { Money.new(5000) }
      taxes { Money.new(10400) }
      total_amount { Money.new(75400) }
    end

    trait :with_low_amount do
      daily_rate { Money.new(5000) }
      subtotal_rent { Money.new(15000) }
      additional_charges { Money.new(2000) }
      discounts { Money.new(1000) }
      taxes { Money.new(2560) }
      total_amount { Money.new(18560) }
    end

    trait :with_long_rental do
      rental_days { 7 }
      after(:build) do |ticket|
        ticket.subtotal_rent = ticket.daily_rate * ticket.rental_days
        ticket.total_amount = ticket.subtotal_rent + ticket.additional_charges - ticket.discounts + ticket.taxes
      end
    end

    trait :with_short_rental do
      rental_days { 1 }
      after(:build) do |ticket|
        ticket.subtotal_rent = ticket.daily_rate * ticket.rental_days
        ticket.total_amount = ticket.subtotal_rent + ticket.additional_charges - ticket.discounts + ticket.taxes
      end
    end
  end
end
