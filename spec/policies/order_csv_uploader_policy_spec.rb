require 'rails_helper'

RSpec.describe OrderCsvUploaderPolicy do
  subject { described_class }

  let(:dispatcher) { build :user }
  let(:driver) { build :user_driver }

  permissions :new?, :create? do
    it { is_expected.to permit(dispatcher) }
    it { is_expected.not_to permit(driver) }
  end
end
