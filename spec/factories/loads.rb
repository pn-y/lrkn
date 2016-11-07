FactoryGirl.define do
  factory :load do
    delivery_shift 'E'
    delivery_date Date.current

    after(:build) do |load|
      load.truck = build(:truck) if load.truck_id.nil?
    end

    factory :load_attrs do
      truck_id { create(:truck).id }
    end
  end
end
