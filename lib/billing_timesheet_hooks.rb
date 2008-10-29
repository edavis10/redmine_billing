class BillingTimesheetooks < Redmine::Hook::ViewListener

  def plugin_timesheet_view_timesheets_context_menu(context={ })
    time_entries = context[:time_entries]
    
    o = ''
    o << "<ul>"
    if time_entries.size <= 0
      o << content_tag(:li,
                       context_menu_link(GLoc.l(:button_invoice),
                                         new_accounts_payable_path(:time_entry_ids => nil),
                                         :style => "background-image: url(#{image_path('invoice.png', :plugin => 'billing_plugin')});",
                                         :disabled => true))
    else
      o << content_tag(:li,
                       context_menu_link(GLoc.l(:button_invoice),
                                         new_accounts_payable_path(:time_entry_ids => time_entries.collect(&:id)),
                                         :style => "background-image: url(#{image_path('invoice.png', :plugin => 'billing_plugin')});"))
    end
    o << "</ul>"

    return o
  end
end
