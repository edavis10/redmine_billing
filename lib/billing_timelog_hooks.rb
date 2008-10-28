class BillingTimelogHooks < Redmine::Hook::ViewListener
  def view_timelog_edit_form_bottom(context={ })
    form = context[:form]
    
    return content_tag(:p, form.text_field(:vendor_invoice_id, :size => 15))
  end
end
