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
      javascript_include_tag('jquery.dimensions.min.js', :plugin => "billing_plugin") +
      javascript_include_tag('billing-timesheet.js', :plugin => "billing_plugin") +
      javascript_tag("jQuery.noConflict();") +
      stylesheet_link_tag("facebox.css", :plugin => "billing_plugin", :media => "screen") +
      javascript_include_tag('facebox', :plugin => "billing_plugin") +
      stylesheet_link_tag("billing-timesheet.css", :plugin => "billing_plugin", :media => "screen") +
      javascript_tag("var time_counter_url = '#{formatted_time_counter_accounts_payables_path(:format => 'json')}'")

  end
  
  def plugin_timesheet_view_timesheets_report_bottom(context = { })
    # TODO: Wish I could just render :partial in here
    inner_content = <<HTML
<a href='javascript:void(0)' id="minimize" onclick="jQuery('#counter-details').toggle(); return false;">-</a>
<h3>Selected Time Summary</h3>
<div id="counter-details">
<p id="total-time">
</p>
<p id="time-entry-count">
</p>
<hr />
<ul>
</ul>
</div>
HTML
    o = ''
    o << content_tag(:div, inner_content, :id => 'floating-counter', :style => 'display:none;')
    return o
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
