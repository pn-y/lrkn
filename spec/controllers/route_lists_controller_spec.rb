require 'rails_helper'

RSpec.describe RouteListsController, type: :controller do
  render_views

  let(:user) { create :user }

  before { sign_in(user) }

  describe 'GET #index' do
    subject { get :index }

    it { is_expected.to have_http_status(200) }
  end

  describe 'GET #show' do
    let(:load) { create :load }

    before { 5.times { |n| create :order, load_id: load.id, delivery_order: n + 1 } }

    context 'when format: :html' do
      subject(:get_html) { get :show, id: load.id }

      it { is_expected.to have_http_status(200) }
    end

    context 'when format: :pdf' do
      subject(:get_html) { get :show, id: load.id, format: :pdf }

      it 'responses with pdf' do
        is_expected.to have_http_status(200)
        expect(response.headers['Content-Type']).to eq('application/pdf')
        expect(response.headers['Content-Disposition']).
          to eq('attachment; filename="route list for '\
                "#{load.delivery_shift} #{load.delivery_date}.pdf\"")
      end
    end
  end
end
