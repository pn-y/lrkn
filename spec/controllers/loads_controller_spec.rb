require 'rails_helper'

RSpec.describe LoadsController, type: :controller do
  let(:user) { create :user }

  before { sign_in(user) }

  describe 'GET #index' do
    subject { get :index }

    it { is_expected.to have_http_status(200) }
  end

  describe 'GET #show' do
    let!(:load) { create :load }

    subject { get :show, id: load.id }

    it { is_expected.to have_http_status(200) }
  end

  describe 'GET #new' do
    subject { get :new }

    it { is_expected.to have_http_status(200) }
  end

  describe 'POST #create' do
    subject { post :create, load: attributes_for(:load_attrs) }

    it { is_expected.to have_http_status(302) }
  end

  describe do
    let(:load) { create :load }
    describe 'GET #edit' do
      subject { get :edit, id: load.id }

      it { is_expected.to have_http_status(200) }
    end

    describe 'PATCH #update' do
      subject { patch :update, id: load.id, load: attributes_for(:load_attrs) }

      it { is_expected.to have_http_status(302) }
    end

    describe 'DELETE #destroy' do
      subject { delete :destroy, id: load.id }

      it { is_expected.to redirect_to(loads_path) }
    end
  end
end
