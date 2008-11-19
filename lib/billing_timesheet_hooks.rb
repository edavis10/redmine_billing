class BillingTimesheetHooks < Redmine::Hook::ViewListener

  def plugin_timesheet_view_timesheets_context_menu(context={ })
    time_entries = context[:time_entries]
    
    o = ''
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
  
  def plugin_timesheet_controller_report_pre_fetch_time_entries(context = { })
    if !context[:params][:timesheet].nil? && !context[:params][:timesheet][:vendor_invoice].nil?
      # Extend time an insane amount
      context[:timesheet].date_from = 100.years.ago.strftime("%Y-%m-%d")
      context[:timesheet].date_to = 100.years.from_now.strftime("%Y-%m-%d")
      # Add vendor_invoice
      context[:timesheet].vendor_invoice = context[:params][:timesheet][:vendor_invoice]
    end
  end
  
  def plugin_timesheet_model_timesheet_conditions(context = { })
    unless context[:timesheet].vendor_invoice.nil?
      vendor_invoice_id = context[:timesheet].vendor_invoice
      context[:conditions][0] << " AND vendor_invoice_id IN (?) "
      context[:conditions] << vendor_invoice_id
    end
  end
end
