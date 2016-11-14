FactoryGirl.define do
  factory :order do
    delivery_date '01.11.2016'
    delivery_shift 'E'
    origin_name 'Larkin LLC'
    origin_address '1505 S BLOUNT ST'
    origin_city 'RALEIGH'
    origin_state 'NC'
    origin_zip '27603'
    origin_country 'US'
    client_name 'Andrew Reilly'
    destination_address '627 GARFIELD DRIVE'
    destination_city 'FORT BRAGG'
    destination_state 'NC'
    destination_zip '28304'
    destination_country 'US'
    phone_number '(845)236-7280 x922'
    mode 'TRUCKLOAD'
    purchase_order_number '500394170'
    volume 15.53
    handling_unit_quantity 7
    handling_unit_type 'box'

    trait :returning do
      client_name 'Larkin LLC'
      origin_name 'Andrew Reilly'
      returning true
    end

    factory :order_returning, traits: [:returning]
  end
end
