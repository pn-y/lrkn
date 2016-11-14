require 'rails_helper'

RSpec.describe RouteList, type: :operation do
  describe '::Index' do
    subject { described_class::Index.present(current_user: user).model }

    context 'when current_user is a driver' do
      let(:truck) { create :truck }
      let(:user) { create :user_driver, truck: truck }
      let!(:first_load) { create :load, truck_id: truck.id }
      let!(:second_load) { create :load }

      it { is_expected.to eq([first_load]) }
    end

    context 'when current_user is a dispatcher' do
      let!(:first_load) { create :load }
      let!(:second_load) { create :load }
      let(:user) { create :user }

      it { is_expected.to eq([first_load, second_load]) }
    end
  end

  describe '::Show' do
    subject { described_class::Show.present(current_user: user, id: load.id).model }

    context 'when current_user is a driver' do
      let(:truck) { create :truck }
      let(:user) { create :user_driver, truck: truck }

      context 'when load is allowed for driver' do
        let!(:load) { create :load, truck_id: truck.id }

        it { is_expected.to eq(load) }
      end

      context 'when load is not allowed for driver' do
        let!(:load) { create :load }

        it { expect { subject }.to raise_exception(ActiveRecord::RecordNotFound) }
      end
    end

    context 'when current_user is a dispatcher' do
      let!(:load) { create :load }
      let(:user) { create :user }

      it { is_expected.to eq(load) }
    end
  end
end
