FactoryGirl.define do
  factory :load do
    delivery_shift 'E'
    delivery_date Date.current
    truck
  end
end
