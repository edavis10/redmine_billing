class BillingTimesheetHooks < Redmine::Hook::ViewListener

  def plugin_timesheet_view_timesheets_context_menu(context={ })
    time_entries = context[:time_entries]
    
    o = ''
    if time_entries.size <= 0
      o << content_tag(:li,
                       context_menu_link(l(:button_invoice),
                                         {:controller=>"accounts_payables", :action=>"timesheet", :time_entry_ids => time_entries.collect(&:id)},
                                         :style => "background-image: url(#{image_path('invoice.png', :plugin => 'redmine_billing')});",
                                         :disabled => true))
    else
      o << content_tag(:li,
                       context_menu_link(l(:button_invoice),
                                         {:controller=>"accounts_payables", :action=>"timesheet", :time_entry_ids => time_entries.collect(&:id)},
                                         :style => "background-image: url(#{image_path('invoice.png', :plugin => 'redmine_billing')});",
                                         :rel => 'facebox'));
      
    end
    o << javascript_tag("jQuery('a[rel*=facebox]').facebox();");

    return o
  end
  
  def plugin_timesheet_view_timesheets_report_header_tags(context = { })
    js_libs = []
    jquery_included = begin
                        ChiliProject::Compatibility && ChiliProject::Compatibility.using_jquery?
                      rescue NameError
                        # No compatibilty test
                        false
                      end
    unless jquery_included
      js_libs << javascript_include_tag('jquery-1.2.6.min.js', :plugin => "redmine_billing")
      js_libs << javascript_tag("jQuery.noConflict();")
    end
    
    js_libs << javascript_include_tag('jquery.dimensions.min.js', :plugin => "redmine_billing")
    js_libs << javascript_include_tag('billing-timesheet.js', :plugin => "redmine_billing")
    js_libs << javascript_include_tag('jquery.js-link.js', :plugin => "redmine_billing")
    js_libs << stylesheet_link_tag("facebox.css", :plugin => "redmine_billing", :media => "screen")
    js_libs << javascript_include_tag('facebox', :plugin => "redmine_billing")
    js_libs << stylesheet_link_tag("billing-timesheet.css", :plugin => "redmine_billing", :media => "screen")
    js_libs << javascript_tag("var time_counter_url = '#{formatted_time_counter_accounts_payables_path(:format => 'json')}'")
    js_libs << javascript_tag("jQuery(document).ready(function() {
                          jQuery('.invoice-button').show().jsLink({
                             basePath: '#{url_for(:controller => 'accounts_payables', :action => 'timesheet')}',
                             selector: '#time_entries :checkbox:checked',
                             selectorFieldNames: 'time_entry_ids[]=',
                             errorMessage: 'Please select some time entries before trying to invoice them'
                           })});")

    return js_libs.join(' ')
  end
  
  def plugin_timesheet_view_timesheets_report_bottom(context = { })
    # TODO: Wish I could just render :partial in here
    # Floating time counter
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
#{invoice_button(context[:timesheet])}
HTML
    o = ''
    o << content_tag(:div, inner_content, :id => 'floating-counter', :style => 'display:none;')
    # Invoice button
    o << invoice_button(context[:timesheet])
    return o
  end

  def plugin_timesheet_views_timesheets_report_before_time_entries(context = { })
    return invoice_button(context[:timesheet])
  end
  
  # Adds a CSS class to the row on the Timesheet if a time_entry is missing a 
  # rate (based on it's cost).
  def plugin_timesheet_view_timesheets_time_entry_row_class(context = { })
    time_entry = context[:time_entry]
    if time_entry.cost && time_entry.cost <= 0 && time_entry.hours > 0
      return "missing-rate"
    else
      return ""
    end
  end

  # Cost and Invoice header columns
  def plugin_timesheet_views_timesheet_group_header(context = {})
    return "<th width='8%'>#{l(:billing_invoice_title)}</th>"
  end

  def plugin_timesheet_views_timesheet_time_entry(context = {})
    time_entry = context[:time_entry]
    o = ''
    o << invoice_cell(time_entry)
    
    return o
  end

  def plugin_timesheet_views_timesheet_time_entry_sum(context = {})
    time_entries = context[:time_entries]
    o = ''
    costs = time_entries.collect {|time_entry| cost_item(time_entry)}.compact.sum
    o << td_cell(number_to_currency(costs))
    o << td_cell("&nbsp;") # Can't sum invoices
    
    return o
  end
  
  def plugin_timesheet_controller_report_pre_fetch_time_entries(context = { })
    # Specific Vendor Invoice
    if !context[:params][:timesheet].nil? && !context[:params][:timesheet][:vendor_invoice].nil?
      # Extend time an insane amount
      context[:timesheet].date_from = 100.years.ago.strftime("%Y-%m-%d")
      context[:timesheet].date_to = 100.years.from_now.strftime("%Y-%m-%d")
      # Add vendor_invoice
      context[:timesheet].vendor_invoice = context[:params][:timesheet][:vendor_invoice]
    end

    # Billing Status Filters
    if !context[:params][:timesheet].nil? && !context[:params][:timesheet][:billing_status_type].nil?
      if context[:params][:timesheet][:billing_status_type] == '2'
        # Specific status
        context[:timesheet].billing_statuses = context[:params][:timesheet][:billing_status]
      else
        # General group
        case context[:params][:timesheet][:billing_status_group]
        when ""
          # Any, no filter
        when "unassigned" # Not invoiced
          context[:timesheet].billing_statuses = ['unassigned']
        when "invoiced"
          context[:timesheet].billing_statuses = BillingStatus.names
        end
      end
    end
  end
  
  def plugin_timesheet_model_timesheet_conditions(context = { })
    unless context[:timesheet].vendor_invoice.nil?
      vendor_invoice_id = context[:timesheet].vendor_invoice
      context[:conditions][0] << " AND vendor_invoice_id IN (:vendor_invoice) "
      context[:conditions][1][:vendor_invoice] = vendor_invoice_id
    end

    if context[:timesheet].billing_statuses && !context[:timesheet].billing_statuses.empty?
      if context[:timesheet].billing_statuses.include?("unassigned")
        # No status
        context[:conditions][0] << " AND #{TimeEntry.table_name}.vendor_invoice_id IS NULL "
      else
        # Specific statuses
        context[:conditions][0] << " AND #{VendorInvoice.table_name}.billing_status IN (:billing_statuses) "
        context[:conditions][1][:billing_statuses] = context[:timesheet].billing_statuses.collect(&:to_s)
      end
    end
  end

  def plugin_timesheet_model_timesheet_includes(context = { })
    if context[:timesheet].billing_statuses && !context[:timesheet].billing_statuses.empty?
      context[:includes] << :vendor_invoice
    end
  end

  # Add the Billing Status as a Filter to the Timesheet form
  def plugin_timesheet_view_timesheet_form(context = {})
    if context[:params] && context[:params][:timesheet] && context[:params][:timesheet][:billing_status]
      billing_statuses = context[:params][:timesheet][:billing_status]
    else
      billing_statuses = ['unassigned']
    end

    if context[:params] && context[:params][:timesheet] && context[:params][:timesheet][:billing_status_type]
      billing_status_type = context[:params][:timesheet][:billing_status_type].to_s
    else
      billing_status_type = "1"
    end

    return context[:controller].send(:render_to_string, {
                                       :partial => 'timesheets/billing',
                                       :locals => {
                                         :context => context,
                                         :billing_statuses => billing_statuses,
                                         :params => context[:params],
                                         :billing_status_type => billing_status_type

                                       }
                                     })
  end

  ### Helpers
  
  # Returns the cost of a time entry, checking user permissions
  def cost_item(time_entry)
    if User.current.logged? && (User.current.allowed_to?(:view_rate, time_entry.project) || User.current.admin?)
      return time_entry.cost
    else
      return nil
    end
  end

  # Returns a td cell of the time_entry's cost
  def cost_cell(time_entry)
    cost = cost_item(time_entry)
    if cost
      return td_cell(number_to_currency(cost))
    else
      return td_cell('&nbsp;')
    end
  end

  # Returns a td cell of the time_entry's invoice
  def invoice_cell(time_entry)
    if User.current.logged? && User.current.allowed_to?(:use_accounts_payable, nil, :global => true) && time_entry.vendor_invoice
      invoice = link_to(h(time_entry.vendor_invoice.number),
                        {:controller=>"accounts_payables", :action=>"show", :id => time_entry.vendor_invoice})
    else
      invoice = '&nbsp;'
    end
    return td_cell(invoice)
  end

  def td_cell(html)
    return content_tag(:td, html, :align => 'right')
  end

  def invoice_button(timesheet)
    if timesheet && timesheet.time_entries && timesheet.time_entries.size > 0
      return content_tag(:div,
                         "<a href='' style='display:none' class='invoice-button'>#{l(:button_invoice)}</a>",
                         :class => 'invoice-menu')
    else
      return ''
    end
  end
end
