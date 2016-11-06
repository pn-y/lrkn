class OrderPolicy < ApplicationPolicy
  def index?
    dispatcher?
  end

  def update?
    dispatcher?
  end

  def move_up?
    dispatcher?
  end

  def move_down?
    dispatcher?
  end

  def split?
    dispatcher?
  end
end
