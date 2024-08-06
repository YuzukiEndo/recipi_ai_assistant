module ApplicationHelper
  def flash_message_class(flash_type)
    case flash_type.to_sym
    when :notice then 'flash-info'
    when :success then 'flash-success'
    when :error, :danger then 'flash-danger'
    when :alert then 'flash-warning'
    else "flash-#{flash_type}"
    end
  end
end
