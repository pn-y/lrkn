module OrdersHelper
  def order_label_for_load(order)
    label = "#{order.delivery_date}, #{order.delivery_shift}"
    if order.returning
      label << " #{order.origin_address}, #{order.origin_city}"
      label << ", #{order.origin_state}, #{order.origin_zip}"
    else
      label << " #{order.destination_address}, #{order.destination_city}"
      label << ", #{order.destination_state}, #{order.destination_zip}"
    end
    label << "#{order.handling_unit_quantity}, #{order.handling_unit_type}, #{order.volume}"
    label << ', Return' if order.returning
    label
  end

  def address_string(order)
    if order.returning
      "#{order.origin_address}, #{order.origin_city}, #{order.origin_state}, #{order.origin_zip}"
    else
      "#{order.destination_address}, #{order.destination_city}, "\
      "#{order.destination_state}, #{order.destination_zip}"
    end
  end

  def load_cargo_string(order)
    return unless order.handling_unit_quantity && order.handling_unit_type

    verb = order.returning ? 'load ' : 'unload '
    verb + cargo_string(order)
  end

  def cargo_string(order)
    return unless order.handling_unit_quantity && order.handling_unit_type
    pluralize(order.handling_unit_quantity, order.handling_unit_type)
  end

  def route_list_address_string(order)
    if order.returning
      "#{order.origin_address}, #{order.origin_city}, #{order.origin_state}, #{order.origin_zip}"
    else
      "#{order.destination_address}, #{order.destination_city}, "\
      "#{order.destination_state}, #{order.destination_zip}"
    end
  end

  def contacts_string(order)
    client_name = order.returning ? order.origin_name : order.client_name
    "#{client_name},  #{order.phone_number}"
  end

  def order_row_style(order)
    if order.load_id
      'info'
    elsif order.returning
      'warning'
    elsif danger_order?(order)
      'danger'
    end
  end

  def danger_order?(order)
    order.handling_unit_quantity.blank? ||
      order.handling_unit_quantity.zero? ||
      order.volume.blank? ||
      order.volume.zero? ||
      order.delivery_date.blank?
  end
end
