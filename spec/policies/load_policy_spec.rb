require 'rails_helper'

RSpec.describe LoadPolicy do
  subject { described_class }

  let(:dispatcher) { build :user }
  let(:driver) { build :user_driver }

  permissions :update?, :edit?, :destroy? do
    it { is_expected.to permit(dispatcher, Load.new) }
    it { is_expected.not_to permit(driver, Load.new) }
  end

  describe 'scope' do
    let(:resolved_scope) { described_class::Scope.new(user, Load.all).resolve }

    context 'when dispatcher' do
      let(:user) { dispatcher }

      it { expect(resolved_scope).to eq(Load.all) }
    end

    context 'when driver' do
      let(:user) { driver }

      it { expect(resolved_scope).to eq(Load.joins(:truck).where(trucks: { user_id: user.id })) }

      describe do
        let(:user) { create :user, truck: load_1.truck }
        let(:load_1) { create :load }
        let(:load_2) { create :load }

        it { expect(resolved_scope).to eq([load_1]) }
      end
    end
  end
end
