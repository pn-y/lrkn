require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  render_views

  describe 'GET #dashboard' do
    subject { get :dashboard }

    context 'when signed-in' do
      let(:user) { create :user }

      before { sign_in(user) }

      it { is_expected.to have_http_status(200) }
    end

    context 'when not signed-in' do
      it { is_expected.to redirect_to(new_user_session_url) }
    end
  end
end
