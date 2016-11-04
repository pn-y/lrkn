module OrdersHelper
  def returning_order?(order)
    order.client_name == 'Larkin LLC'
  end
end
