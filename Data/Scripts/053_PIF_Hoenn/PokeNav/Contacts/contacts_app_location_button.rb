class ContactsAppLocationButton < PokenavButton
  BOTTOM_MARGIN = 8  # tune this

  def get_height
    return 40
  end

  def get_width
    return 200
  end

  def get_text
    return @id.to_s
  end

  def bottom_margin
    return BOTTOM_MARGIN
  end
end