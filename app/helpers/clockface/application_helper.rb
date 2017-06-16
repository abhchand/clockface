module Clockface
  module ApplicationHelper
    def flash_messages(opts = {})
      flash.each do |flash_type, message|
        concat(
          content_tag(:div, message, class: "flash active alert #{bootstrap_class_for(flash_type)} fade in") do
            concat content_tag(:button, "x", class: "close", data: { dismiss: "alert" })
            concat message
          end
        )
      end
      nil
    end

    def bootstrap_class_for(flash_type)
      {
        success: "alert-success",
        error: "alert-danger",
        alert: "alert-warning",
        notice: "alert-info"
      }[flash_type.to_sym] || flash_type.to_s
    end
  end
end
