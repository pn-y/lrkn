class OrderPolicy < ApplicationPolicy
  def change?
    dispatcher?
  end

  def view?
    dispatcher?
  end
end
