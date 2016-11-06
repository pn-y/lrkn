require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it { should validate_inclusion_of(:delivery_shift).in_array(%w(E N M)).allow_nil }
  end

  describe '#decrease_delivery_order_in_load!' do
    let(:load) { create :load }
    let!(:first_order) { create :order, delivery_order: 1, load_id: load.id }
    let!(:second_order) { create :order, delivery_order: 2, load_id: load.id }

    it 'decreases delivery order' do
      second_order.decrease_delivery_order_in_load!
      expect(second_order.reload.delivery_order).to eq(1)
      expect(first_order.reload.delivery_order).to eq(2)
    end
  end

  describe '#increase_delivery_order_in_load!' do
    let(:load) { create :load }
    let!(:first_order) { create :order, delivery_order: 1, load_id: load.id }
    let!(:second_order) { create :order, delivery_order: 2, load_id: load.id }

    it 'decreases delivery order' do
      first_order.increase_delivery_order_in_load!
      expect(first_order.reload.delivery_order).to eq(2)
      expect(second_order.reload.delivery_order).to eq(1)
    end
  end

  describe '#split!' do
    context 'when quantity <= 1' do
      let!(:order) { create :order, handling_unit_quantity: 1 }

      it { expect { order.split! }.not_to change(Order, :count) }
      it { expect(order.handling_unit_quantity).to eq(1) }
    end

    context 'when quantity > 1' do
      let!(:order) { create :order, handling_unit_quantity: 7, volume: 19 }

      it { expect { order.split! }.to change(Order, :count).by(1) }

      it do
        order.split!
        expect(order.handling_unit_quantity).to eq(4)
        expect(order.volume.round(2)).to eq(10.86)

        expect(Order.last.handling_unit_quantity).to eq(3)
        expect(Order.last.volume.round(2)).to eq(8.14)

        expect(order.handling_unit_quantity + Order.last.handling_unit_quantity).to eq(7)
        expect(order.volume.round(2) + Order.last.volume.round(2)).to eq(19)
      end
    end
  end
end
