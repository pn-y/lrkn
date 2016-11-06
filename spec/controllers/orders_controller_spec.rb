require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  let(:user) { create :user }
  let(:load) { create :load }
  let!(:order_1) { create :order, load_id: load.id, delivery_order: 1 }
  let!(:order_2) { create :order, load_id: load.id, delivery_order: 2 }
  let!(:order_3) { create :order, load_id: load.id, delivery_order: 3 }

  before { sign_in(user) }

  describe 'GET #index' do
    subject { get :index }

    it { is_expected.to have_http_status(200) }
  end

  describe do
    describe 'GET #edit' do
      subject { get :edit, id: order_1.id }

      it { is_expected.to have_http_status(200) }
    end

    describe 'PATCH #update' do
      subject { patch :update, id: order_1.id, order: attributes_for(:order) }

      it { is_expected.to have_http_status(302) }
    end
  end

  describe 'POST #split' do
    let(:order) { create :order }

    subject { post :split, id: order.id }

    it { is_expected.to redirect_to(orders_url) }
  end

  describe 'POST #move_up' do
    subject { post :move_up, load_id: load.id, order_id: order_2.id }

    it { is_expected.to redirect_to(load_url(load)) }
    it 'decreases delivery order' do
      subject
      expect(Order.find(order_2.id).delivery_order).to eq(1)
    end
  end

  describe 'POST #move_down' do
    subject { post :move_down, load_id: load.id, order_id: order_2.id }

    it { is_expected.to redirect_to(load_url(load)) }
    it 'increases delivery order' do
      subject
      expect(Order.find(order_2.id).delivery_order).to eq(3)
    end
  end
end
