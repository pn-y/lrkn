require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:load) }
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
