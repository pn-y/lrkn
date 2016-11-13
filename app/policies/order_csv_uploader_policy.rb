class OrderCsvUploaderPolicy < ApplicationPolicy
  def upload?
    dispatcher?
  end
end
