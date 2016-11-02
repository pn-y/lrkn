FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "login#{n}" }
    password '12345678'
    role 'dispatcher'

    trait :driver do
      role 'driver'
    end

    factory :user_driver, traits: [:driver]
  end
end
