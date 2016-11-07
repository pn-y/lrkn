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

  def address_string(order)
    it_is_return = returning_order?(order)
    if it_is_return
      "#{order.origin_address}, #{order.origin_city}, #{order.origin_state}, #{order.origin_zip}"
    else
      "#{order.destination_address}, #{order.destination_city}, "\
      "#{order.destination_state}, #{order.destination_zip}"
    end
  end

  def cargo_string(order)
    it_is_return = returning_order?(order)

    verb = it_is_return ? 'load ' : 'unload '
    verb + pluralize(order.handling_unit_quantity, order.handling_unit_type)
  end

  def routing_list_address_string(order)
    it_is_return = returning_order?(order)
    if it_is_return
      "#{order.origin_address}, #{order.origin_city}, #{order.origin_state}, #{order.origin_zip}"
    else
      "#{order.destination_address}, #{order.destination_city}, "\
      "#{order.destination_state}, #{order.destination_zip}"
    end
  end

  def contacts_string(order)
    it_is_return = returning_order?(order)

    client_name = it_is_return ? order.origin_name : order.client_name
    "#{client_name},  #{order.phone_number}"
  end
end
