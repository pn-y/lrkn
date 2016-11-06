require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it { should validate_inclusion_of(:delivery_shift).in_array(%w(E N M)).allow_nil }
  end

  describe '#decrease_delivery_order!' do
    let!(:first_order) { create :order, delivery_order: 1 }
    let!(:second_order) { create :order, delivery_order: 2 }

    it 'decreases delivery order' do
      second_order.decrease_delivery_order!
      expect(second_order.reload.delivery_order).to eq(1)
      expect(first_order.reload.delivery_order).to eq(2)
    end
  end

  describe '#increase_delivery_order!' do
    let!(:first_order) { create :order, delivery_order: 1 }
    let!(:second_order) { create :order, delivery_order: 2 }

    it 'decreases delivery order' do
      first_order.increase_delivery_order!
      expect(first_order.reload.delivery_order).to eq(2)
      expect(second_order.reload.delivery_order).to eq(1)
    end
  end
end
