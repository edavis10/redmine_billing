class BillingTimelogHooks < Redmine::Hook::ViewListener
  include AutoCompleteMacrosHelper

  def view_timelog_edit_form_bottom(context={ })
    form = context[:form]

    o = ''
    o << content_tag(:p,
                       text_field_with_auto_complete(:time_entry,
                                                     :vendor_invoice_id,
                                                     { :autocomplete => "off", :size => 35 },
                                                     { :url => {
                                                         :controller => 'accounts_payables',
                                                         :action => 'auto_complete_for_vendor_invoice_number',
                                                         :protocol => Setting.protocol,
                                                         :host => Setting.host_name
                                                       }}))
    
    
    return o
  end
end
