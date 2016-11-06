require 'rails_helper'

RSpec.describe Load, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:delivery_date) }
    it { should validate_presence_of(:truck_id) }
    it { should validate_inclusion_of(:delivery_shift).in_array(Order::DELIVERY_SHIFTS) }
    it { should validate_uniqueness_of(:delivery_shift).scoped_to(:delivery_date) }
  end
end
