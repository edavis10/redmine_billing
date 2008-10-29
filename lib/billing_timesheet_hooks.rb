class BillingTimesheetooks < Redmine::Hook::ViewListener

  def plugin_timesheet_view_timesheets_context_menu(context={ })
    time_entries = context[:time_entries]
    
    o = ''
    o << "<ul>"
    if time_entries.size <= 0
      o << content_tag(:li,
                       context_menu_link(GLoc.l(:button_invoice),
                                         timesheet_accounts_payables_path(:time_entry_ids => time_entries.collect(&:id)),
                                         :style => "background-image: url(#{image_path('invoice.png', :plugin => 'billing_plugin')});",
                                         :disabled => true))
    else
      o << content_tag(:li,
                       context_menu_link(GLoc.l(:button_invoice),
                                         timesheet_accounts_payables_path(:time_entry_ids => time_entries.collect(&:id)),
                                         :style => "background-image: url(#{image_path('invoice.png', :plugin => 'billing_plugin')});",
                                         :rel => 'facebox'));
      
    end
    o << javascript_tag("jQuery('a[rel*=facebox]').facebox();");

    return o
  end
  
  def plugin_timesheet_view_timesheets_report_header_tags(context = { })
    return javascript_include_tag('jquery-1.2.6.min.js', :plugin => "billing_plugin") +
      javascript_tag("jQuery.noConflict();") +
      stylesheet_link_tag("facebox.css", :plugin => "billing_plugin", :media => "screen") +
      javascript_include_tag('facebox', :plugin => "billing_plugin")

  end
end
