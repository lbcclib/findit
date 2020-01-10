module IconHelper
  def white_icon icon
    mdi_svg(icon, style: 'fill:#FFF;').html_safe
  end
end
