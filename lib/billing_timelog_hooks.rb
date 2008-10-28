class BillingTimelogHooks < Redmine::Hook::ViewListener
  include AutoCompleteMacrosHelper

  def view_timelog_edit_form_bottom(context={ })
    form = context[:form]

    o = ''
    # Create a text field for vendor_invoice_id
    o << "<p>"
    o << text_field_with_auto_complete(:time_entry,
                                       :vendor_invoice_id,
                                       { :autocomplete => "off", :size => 35 },
                                       { :url => {
                                           :controller => 'accounts_payables',
                                           :action => 'auto_complete_for_vendor_invoice_number',
                                           :protocol => Setting.protocol,
                                           :host => Setting.host_name
                                         }})
    
    
    o << "</p>"
    return o
  end
end
