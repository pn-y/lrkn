class OrderPolicy < ApplicationPolicy
  def index?
    dispatcher?
  end

  def update?
    dispatcher? && record.load_id.nil?
  end

  def move_up?
    dispatcher?
  end

  def move_down?
    dispatcher?
  end

  def split?
    dispatcher? && record.load_id.nil?
  end

  def remove_from_load?
    dispatcher?
  end
end
