module VendorInvoicesHelper
  def vendor_invoice_number_for(invoice)
    link_to invoice.number, accounts_payable_path(invoice), :class => (invoice.billing_status.nil? ? '': 'billing-status-' + invoice.billing_status)
  end
  
  def bulk_edit_list_for_vendor_invoices(invoices)
    invoices.collect do |i|
      content_tag('li',
                  link_to(h("#{i.number}"), accounts_payable_path(i))) 
    end.join("\n")
  end
  
  def user_hours_for_vendor_invoice(invoice, user)
    total = invoice.hours
    return number_to_currency(total) if total == 0

    case invoice.users.count
    when 0
      # nothing
      return ''
    when 1
      return number_to_currency(total)
    else
      return number_to_currency(invoice.hours(user)) + ' of ' + number_to_currency(total)
    end
  end
end
