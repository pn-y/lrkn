require 'rails_helper'

RSpec.describe Load, type: :operation do
  let(:user) { create :user }

  describe 'validations' do
    subject { Load::Create.present(attributes_for(:load_attrs).merge(current_user: user)).contract }

    it { is_expected.to validate_presence_of :delivery_shift }
    it { is_expected.to validate_presence_of :delivery_date }

    describe 'truck_volume' do
      let(:params) { { load: load_attrs, current_user: user } }

      subject { Load::Create.call(params) }

      context 'when not enough volume for orders' do
        let!(:order) { create :order, volume: 1_401 }
        let(:load_attrs) do
          attributes_for(:load_attrs).merge('orders_attributes' =>
          {
            1 => { 'id' => order.id }
          })
        end

        it 'raises invalid contract exception' do
          expect { subject }.
            to raise_exception(Trailblazer::Operation::InvalidContract, /Remove orders/)
        end
      end

      context 'when not enough volume for return orders' do
        let!(:return_order) { create :order_returning, volume: 1_401 }
        let(:load_attrs) do
          attributes_for(:load_attrs).merge('orders_attributes' =>
          {
            1 => { 'id' => return_order.id }
          })
        end

        it 'raises invalid contract exception' do
          expect { subject }.
            to raise_exception(Trailblazer::Operation::InvalidContract, /Remove returning orders/)
        end
      end

      context 'when complex case' do
        let!(:order_1) { create :order, volume: 400 }
        let!(:order_2) { create :order, volume: 400 }
        let!(:order_3) { create :order, volume: 400 }
        let!(:return_order_1) { create :order_returning, volume: 601 }
        let!(:return_order_2) { create :order_returning, volume: 601 }

        context 'if not enough volume for one of returns' do
          let(:load_attrs) do
            attributes_for(:load_attrs).merge('orders_attributes' =>
            {
              0 => { 'id' => order_1.id },
              1 => { 'id' => return_order_1.id },
              2 => { 'id' => order_2.id },
              3 => { 'id' => order_3.id },
              4 => { 'id' => return_order_2.id },
            })
          end

          it 'raises invalid contract exception' do
            expect { subject }.
              to raise_exception(Trailblazer::Operation::InvalidContract,
                                 /not enough volume after 2nd waypoint./)
          end
        end

        context 'if enough volume for any' do
          let(:load_attrs) do
            attributes_for(:load_attrs).merge('orders_attributes' =>
            {
              0 => { 'id' => order_1.id },
              2 => { 'id' => order_2.id },
              1 => { 'id' => return_order_1.id },
              3 => { 'id' => order_3.id },
              4 => { 'id' => return_order_2.id },
            })
          end

          it { is_expected.to be_valid }
        end
      end
    end

    describe 'shift_availability' do
      let!(:existing_load) { create :load }
      let(:params) do
        { load: attributes_for(:load_attrs, truck_id: existing_load.truck_id), current_user: user }
      end
      let(:inst) { Load::Create.call(params) }

      it 'checks orders volume' do
        expect { inst }.
          to raise_exception(Trailblazer::Operation::InvalidContract, /There is an existing load/)
      end
    end
  end

  describe '::Create' do
    let(:params) { { load: attrs, current_user: user } }

    subject { described_class::Create.call(params) }

    context 'with correct attributes' do
      let(:attrs) { attributes_for(:load_attrs) }

      it { is_expected.to be_valid }

      describe 'orders delivery_order' do
        let(:first_order) { create :order }
        let(:second_order) { create :order }
        let(:orders_attributes) do
          { 'orders_attributes' =>
            {
              '0' => { '_destroy' => '', 'id' => first_order.id },
              '1' => { '_destroy' => '', 'id' => second_order.id },
            } }
        end
        let(:attrs) { attributes_for(:load_attrs).merge(orders_attributes) }

        it do
          subject
          expect(first_order.reload.delivery_order).to eq(1)
          expect(second_order.reload.delivery_order).to eq(2)
        end
      end
    end

    context 'when invalid attributes' do
      let(:attrs) { { delivery_shift: '' } }

      it 'raises Trailblazer::Operation::InvalidContract' do
        expect { subject }.to raise_exception(Trailblazer::Operation::InvalidContract)
      end
    end
  end

  describe '::Update' do
    let!(:instance) { create :load }
    let(:params) { { load: attrs, current_user: user, id: instance.to_param } }

    subject { described_class::Update.call(params) }

    context 'with correct attributes' do
      let(:attrs) { attributes_for(:load_attrs) }

      it { is_expected.to be_valid }
    end

    context 'when invalid attributes' do
      let(:attrs) { { delivery_shift: '' } }

      it 'raises Trailblazer::Operation::InvalidContract' do
        expect { subject }.to raise_exception(Trailblazer::Operation::InvalidContract)
      end
    end
  end

  describe '::Index' do
    let!(:first_load) { create :load, delivery_shift: 'E' }
    let!(:second_load) { create :load, delivery_shift: 'N' }

    subject { described_class::Index.present(current_user: user).model }

    it { is_expected.to eq([first_load, second_load]) }
  end

  describe '::Show' do
    let!(:load) { create :load }

    subject { described_class::Show.present(current_user: user, id: load.id).model }

    it { is_expected.to eq(load) }
  end

  describe '::Destroy' do
    let!(:load) { create :load }

    subject { described_class::Destroy.call(current_user: user, id: load.id) }

    it { expect { subject }.to change(Load, :count).by(-1) }
  end

  describe 'changing delivery_order' do
    let(:load) { create :load }
    let!(:first_order) { create :order, load: load, delivery_order: 1 }
    let!(:second_order) { create :order, load: load, delivery_order: 2 }
    let!(:third_order) { create :order, load: load, delivery_order: 3 }
    let(:params) { { current_user: user, id: load.id, order_id: second_order.id } }

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
