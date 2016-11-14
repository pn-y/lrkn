class OrderPolicy < ApplicationPolicy
  def change?
    dispatcher?
  end

  def view?
    dispatcher?
  end

  def update?
    dispatcher? && record.load_id.blank?
  end
end
