class OrderCsvUploaderPolicy < ApplicationPolicy
  def create?
    dispatcher?
  end
end
