require 'rails_helper'

RSpec.describe Order, type: :operation do
  let(:user) { create :user }

  describe 'validations' do
    let(:order) { create :order }

    subject { described_class::Update.present(id: order.id, current_user: user).contract }

    it { should validate_inclusion_of(:delivery_shift).in_array(%w(E N M)).allow_nil }

    describe 'volume numericality' do
      context 'with wrong volume' do
        context 'when volume bigger then allowed' do
          before { subject.volume = 100_000 }

          it { is_expected.not_to be_valid }
        end

        context 'when volume smaller then allowed' do
          before { subject.volume = -1 }

          it { is_expected.not_to be_valid }
        end
      end

      context 'with correct volume' do
        context 'when volume nil' do
          before { subject.volume = nil }

          it { is_expected.to be_valid }
        end

        context 'when volume within allowed range' do
          before { subject.volume = 987 }

          it { is_expected.to be_valid }
        end
      end
    end
  end

  describe '::Index' do
    let!(:first_order) { create :order, delivery_shift: 'N' }
    let!(:second_order) { create :order, delivery_shift: 'M' }

    subject { described_class::Index.present(current_user: user).model }

    it { is_expected.to eq([second_order, first_order]) }
  end

  describe '::Update' do
    let!(:instance) { create :order }
    let(:params) { { order: attrs, current_user: user, id: instance.to_param } }

    subject { described_class::Update.call(params) }

    context 'with correct attributes' do
      let(:attrs) { attributes_for(:order) }

      it { is_expected.to be_valid }
    end

    context 'when invalid attributes' do
      let(:attrs) { { volume: '' } }

      it 'raises Trailblazer::Operation::InvalidContract' do
        expect { subject }.to raise_exception(Trailblazer::Operation::InvalidContract)
      end
    end
  end

  describe '::Split!' do
    subject { described_class::Split.call(id: order.id, current_user: user) }
    context 'when quantity <= 1' do
      let!(:order) { create :order, handling_unit_quantity: 1 }

      it 'raises exception' do
        expect { subject }.
          to raise_exception(Trailblazer::Operation::InvalidContract, /must be greater than 1/)
      end
    end

    context 'when quantity > 1' do
      let!(:order) { create :order, handling_unit_quantity: 7, volume: 21 }

      it { expect { subject }.to change(Order, :count).by(1) }

      it 'splits order' do
        subject
        order.reload
        expect(order.handling_unit_quantity).to eq(4)
        expect(order.volume).to eq(12)

        expect(Order.last.handling_unit_quantity).to eq(3)
        expect(Order.last.volume).to eq(9)

        expect(order.handling_unit_quantity + Order.last.handling_unit_quantity).to eq(7)
        expect(order.volume + Order.last.volume).to eq(21)
      end
    end
  end

  describe '::RemoveFromLoad' do
    subject { described_class::RemoveFromLoad.call(id: order.id, current_user: user) }

    context 'when has load' do
      let(:order) { create :order, load: (create :load) }

      it 'clears load_id' do
        subject
        expect(order.reload.load_id).to be_nil
      end
    end

    context 'when has no load' do
      let(:order) { create :order }

      it 'raises exception' do
        expect { subject }.
          to raise_exception(Trailblazer::Operation::InvalidContract, /can't be blank/)
      end
    end
  end

  describe 'changing delivery_order' do
    let(:load) { create :load }
    let!(:first_order) { create :order, load: load, delivery_order: 1 }
    let!(:second_order) { create :order, load: load, delivery_order: 2 }
    let!(:third_order) { create :order, load: load, delivery_order: 3 }
    let(:params) { { current_user: user, load_id: load.id, order_id: second_order.id } }

    describe '::DecreaseDeliveryOrder' do
      subject { described_class::DecreaseDeliveryOrder.call(params) }

      it 'swaps delivery order' do
        subject
        expect(first_order.reload.delivery_order).to eq(2)
        expect(second_order.reload.delivery_order).to eq(1)
      end
    end

    describe '::IncreaseDeliveryOrder' do
      subject { described_class::IncreaseDeliveryOrder.call(params) }

      it 'swaps delivery order' do
        subject
        expect(third_order.reload.delivery_order).to eq(2)
        expect(second_order.reload.delivery_order).to eq(3)
      end
    end
  end
end
