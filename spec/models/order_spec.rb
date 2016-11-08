require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'validations' do
    it { should validate_inclusion_of(:delivery_shift).in_array(%w(E N M)).allow_nil }
    it do
      should validate_numericality_of(:volume).
        is_less_than(100_000).is_greater_than_or_equal_to(0).allow_nil
    end
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
      let!(:order) { create :order, handling_unit_quantity: 7, volume: 21 }

      it { expect { order.split! }.to change(Order, :count).by(1) }

      it do
        order.split!
        expect(order.handling_unit_quantity).to eq(4)
        expect(order.volume).to eq(12)

        expect(Order.last.handling_unit_quantity).to eq(3)
        expect(Order.last.volume).to eq(9)

        expect(order.handling_unit_quantity + Order.last.handling_unit_quantity).to eq(7)
        expect(order.volume + Order.last.volume).to eq(21)
      end
    end
  end

  describe 'scopes' do
    describe '.scheduled' do
      let!(:scheduled_order) { create :order, load_id: (create :load).id }
      let!(:not_scheduled_order) { create :order }

      context 'when scheduled true' do
        it { expect(described_class.scheduled('true')).to eq([scheduled_order]) }
      end

      context 'when scheduled false' do
        it { expect(described_class.scheduled('false')).to eq([not_scheduled_order]) }
      end

      context 'when sheduled blank' do
        it { expect(described_class.scheduled(nil)).to match_array([not_scheduled_order, scheduled_order]) }
      end
    end

    describe '.with_shift_order' do
      subject { described_class.with_shift_order }

      let(:order_e) { create :order, delivery_shift: 'E', delivery_date: '02.11.2015' }
      let(:order_m) { create :order, delivery_shift: 'M', delivery_date: '02.11.2015' }
      let(:order_n) { create :order, delivery_shift: 'N', delivery_date: '02.11.2015' }
      let(:older_order_m) { create :order, delivery_shift: 'M', delivery_date: '01.11.2015' }
      let(:newer_order_m) { create :order, delivery_shift: 'N', delivery_date: '03.11.2015' }

      it do
        expect(subject).to eq([older_order_m, order_m, order_n, order_e, newer_order_m])
      end
    end
  end
end
