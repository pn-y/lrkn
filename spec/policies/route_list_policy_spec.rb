require 'rails_helper'

RSpec.describe RouteListPolicy do
  subject { described_class }

  permissions :index?, :show? do
    it { is_expected.to permit(User.new) }
    it { is_expected.to permit(User.new) }
  end
end
