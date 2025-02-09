module ApplicationHelper
  def status_badge(text, variant = :primary)
    variant = variant.to_sym
    valid_variants = [ :primary, :info, :success, :warning, :error ]
    variant = :primary unless valid_variants.include?(variant)
    content_tag :span, text, class: "px-3 py-1 rounded-full text-white #{get_badge_variant(variant)}"
  end

  def get_badge_variant(variant)
    case variant.to_sym
    when :active
      "bg-green-500"
    when :pending
      "bg-blue-500"
    when :cancelled
      "bg-red-500"
    when :error
      "bg-red-500"
    when :info
      "bg-blue-500"
    when :success
      "bg-green-500"
    when :warning
      "bg-yellow-500"
    else
      "bg-gray-500"
    end
  end

  def booking_status_badge(status)
    case status.to_sym
    when :active
      status_badge(status, :success)
    when :pending
      status_badge(status, :info)
    when :cancelled
      status_badge(status, :error)
    when :finished
      status_badge(status, :warning)
    else
      status_badge(status)
    end
  end
end
