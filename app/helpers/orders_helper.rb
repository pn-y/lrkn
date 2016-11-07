module OrdersHelper
  def returning_order?(order)
    order.client_name == 'Larkin LLC'
  end

  def order_label_for_load(order)
    it_is_return = returning_order?(order)
    label = "#{order.delivery_date}, #{order.delivery_shift}"
    if it_is_return
      label << " #{order.origin_address}, #{order.origin_city}"
      label << ", #{order.origin_state}, #{order.origin_zip}"
    else
      label << " #{order.destination_address}, #{order.destination_city}"
      label << ", #{order.destination_state}, #{order.destination_zip}"
    end
    label << "#{order.handling_unit_quantity}, #{order.handling_unit_type}, #{order.volume}"
  end
end
