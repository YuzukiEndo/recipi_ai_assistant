module ApplicationHelper
  def bootstrap_class_for_flash(flash_type)
    case flash_type.to_sym
    when :notice then 'alert-info'
    when :success then 'alert-success'
    when :error, :danger then 'alert-danger'
    when :alert then 'alert-warning'
    else flash_type.to_s
    end
  end
end  
