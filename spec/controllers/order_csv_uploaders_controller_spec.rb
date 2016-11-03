require 'rails_helper'

RSpec.describe OrderCsvUploadersController, type: :controller do
  render_views

  let(:user) { create :user }

  before { sign_in user }

  describe 'GET #new' do
    it { expect(get(:new)).to have_http_status(200) }
  end

  describe 'POST #new' do
    subject { post :create, csv_file: file }

    context 'with correct file' do
      let(:file) { fixture_file_upload('correct_file.csv', 'text/csv') }

      it { is_expected.to redirect_to(orders_url) }
    end

    context 'with incorrect file' do
      let(:file) { fixture_file_upload('incorrect_file.csv', 'text/csv') }

      it { is_expected.to render_template(:new) }
    end
  end
end
